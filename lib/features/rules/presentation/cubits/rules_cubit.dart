import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../history/domain/entities/history_entry.dart';
import '../../../history/domain/usecases/history_usecases.dart';
import '../../../layouts/presentation/cubits/applied_layouts_cubit.dart';
import '../../../monitors/presentation/cubits/monitors_cubit.dart';
import '../../../settings/presentation/cubits/settings_cubit.dart';
import '../../../windows/domain/entities/managed_window.dart';
import '../../../windows/domain/usecases/get_windows.dart';
import '../../domain/entities/rule.dart';
import '../../domain/repositories/rules_repository.dart';
import '../../domain/usecases/apply_rule_to_window.dart';
import '../../domain/usecases/delete_rule.dart';
import '../../domain/usecases/get_rules.dart';
import '../../domain/usecases/save_rule.dart';
import 'rules_state.dart';

/// CRUD das regras e o rules engine: ao abrir um app com regra ativa,
/// aguarda a janela aparecer e executa a ação configurada.
@lazySingleton
class RulesCubit extends Cubit<RulesState> {
  RulesCubit(
    this._getRules,
    this._saveRule,
    this._deleteRule,
    this._applyRule,
    this._repository,
    this._getWindows,
    this._monitorsCubit,
    this._settingsCubit,
    this._appliedLayoutsCubit,
    this._addHistoryEntry,
  ) : super(const RulesState());

  final GetRules _getRules;
  final SaveRule _saveRule;
  final DeleteRule _deleteRule;
  final ApplyRuleToWindow _applyRule;
  final RulesRepository _repository;
  final GetWindows _getWindows;
  final MonitorsCubit _monitorsCubit;
  final SettingsCubit _settingsCubit;
  final AppliedLayoutsCubit _appliedLayoutsCubit;
  final AddHistoryEntry _addHistoryEntry;

  StreamSubscription<AppLaunchEvent>? _subscription;

  /// Janelas já posicionadas pelo engine — evita reaplicar a regra quando o
  /// mesmo windowId chega de novo (launch + window-created, restore etc.).
  final _handledWindowIds = <int>{};

  /// Limite do histórico de janelas tratadas (HWND pode ser reusado no
  /// Windows em sessões longas).
  static const int maxHandledWindowIds = 512;

  /// Intervalo/limite do polling que aguarda a janela do app recém-aberto.
  static const Duration pollInterval = Duration(milliseconds: 600);
  static const int maxPollAttempts = 10;

  /// Polling quando já sabemos o windowId — a janela acabou de ser criada,
  /// mas transições (ex.: animação de fullscreen de uma sessão RDP) podem
  /// atrasar a entrada dela na listagem em alguns segundos.
  static const Duration pollByIdInterval = Duration(milliseconds: 400);
  static const int maxPollByIdAttempts = 10;

  /// Espera antes de conferir se a janela ficou no frame da regra — apps que
  /// restauram o próprio frame após carregar podem desfazer o posicionamento.
  static const Duration verifyDelay = Duration(milliseconds: 1500);

  /// Tolerância (px) na comparação do frame aplicado com o alvo da regra.
  static const double frameTolerance = 8;

  /// Carrega as regras e liga o engine.
  Future<void> start() async {
    await load();
    _subscription ??= _repository.appLaunches().listen(onAppLaunched);
  }

  Future<void> load() async {
    final result = await _getRules(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: RulesStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (rules) => emit(state.copyWith(status: RulesStatus.ready, rules: rules)),
    );
    await _syncWatchedApps();
  }

  /// Informa ao nativo quais apps têm regra ativa, para que novas janelas
  /// deles sejam observadas mesmo com o app já em execução.
  Future<void> _syncWatchedApps() async {
    final bundleIds = state.rules
        .where((rule) => rule.isActive)
        .map((rule) => rule.bundleId)
        .toSet()
        .toList(growable: false);
    await _repository.setRuleApps(bundleIds);
  }

  Future<void> save(Rule rule) async {
    final result = await _saveRule(rule);
    await result.fold(
      (failure) async => emit(state.copyWith(feedback: failure.message)),
      (_) async => load(),
    );
  }

  Future<void> toggle(Rule rule) =>
      save(rule.copyWith(isActive: !rule.isActive));

  Future<void> delete(Rule rule) async {
    await _deleteRule(rule.id);
    await load();
  }

  void clearFeedback() {
    if (state.feedback != null) emit(state.copyWith());
  }

  /// Engine: reage à abertura de um app ou à criação de uma nova janela.
  Future<void> onAppLaunched(AppLaunchEvent event) async {
    final matching = state.rules
        .where((rule) => rule.isActive && rule.bundleId == event.bundleId)
        .toList(growable: false);
    if (matching.isEmpty) return;

    final windowId = event.windowId;
    if (windowId != null && _handledWindowIds.contains(windowId)) return;

    final window = windowId != null
        ? await _waitForWindowById(windowId)
        : await _waitForWindow(event.bundleId);
    if (window == null) return;

    // O evento de launch (sem windowId) pode chegar depois do evento por
    // janela do mesmo app — não reaplicar na janela já tratada.
    if (_handledWindowIds.contains(window.id)) return;
    _markWindowHandled(window.id);

    // Geometria fresca dos monitores (Dock/menu bar podem ter migrado de tela).
    await _monitorsCubit.refresh();
    final settings = _settingsCubit.state.settings;
    for (final rule in matching) {
      final params = ApplyRuleParams(
        rule: rule,
        window: window,
        monitors: _monitorsCubit.state.monitors,
        appliedLayouts: _appliedLayoutsCubit.state,
        gap: settings.windowGap,
        margin: settings.screenMargin,
      );
      final result = await _applyRule(params);
      if (result.getOrElse((_) => false)) {
        await _addHistoryEntry(
          AddHistoryParams(
            type: HistoryEntryType.rule,
            title: 'Regra aplicada a ${rule.appName}',
            subtitle: rule.actionType.label,
          ),
        );
        await _verifyAndReapply(params);
      }
    }
  }

  /// Confere, após o app assentar, se a janela permaneceu no frame da regra;
  /// reaplica uma única vez se o app a moveu/redimensionou de volta.
  Future<void> _verifyAndReapply(ApplyRuleParams params) async {
    final target = await _applyRule.targetFrame(params);
    if (target == null) return;

    await Future<void>.delayed(verifyDelay);
    final windows = (await _getWindows(
      const NoParams(),
    )).getOrElse((_) => const []);
    final window = windows
        .where((candidate) => candidate.id == params.window.id)
        .firstOrNull;
    if (window == null) return;

    final converged =
        (window.x - target.x).abs() <= frameTolerance &&
        (window.y - target.y).abs() <= frameTolerance &&
        (window.width - target.width).abs() <= frameTolerance &&
        (window.height - target.height).abs() <= frameTolerance;
    if (converged) return;

    await _applyRule(
      ApplyRuleParams(
        rule: params.rule,
        window: window,
        monitors: params.monitors,
        appliedLayouts: params.appliedLayouts,
        gap: params.gap,
        margin: params.margin,
      ),
    );
  }

  /// Registra uma janela tratada, descartando os ids mais antigos ao passar
  /// do limite.
  void _markWindowHandled(int windowId) {
    _handledWindowIds.add(windowId);
    if (_handledWindowIds.length > maxHandledWindowIds) {
      _handledWindowIds.remove(_handledWindowIds.first);
    }
  }

  /// Aguarda uma janela específica (recém-criada) aparecer na listagem.
  Future<ManagedWindow?> _waitForWindowById(int windowId) async {
    for (var attempt = 0; attempt < maxPollByIdAttempts; attempt++) {
      final windows = (await _getWindows(
        const NoParams(),
      )).getOrElse((_) => const []);
      for (final window in windows) {
        if (window.id == windowId) return window;
      }
      await Future<void>.delayed(pollByIdInterval);
    }
    return null;
  }

  /// Aguarda a janela principal do app aparecer.
  Future<ManagedWindow?> _waitForWindow(String bundleId) async {
    for (var attempt = 0; attempt < maxPollAttempts; attempt++) {
      final windows = (await _getWindows(
        const NoParams(),
      )).getOrElse((_) => const []);
      final candidates =
          windows.where((window) => window.bundleId == bundleId).toList()..sort(
            (a, b) => (b.width * b.height).compareTo(a.width * a.height),
          );
      if (candidates.isNotEmpty) return candidates.first;
      await Future<void>.delayed(pollInterval);
    }
    return null;
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
