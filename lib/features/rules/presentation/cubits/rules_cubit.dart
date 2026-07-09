import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../history/domain/entities/history_entry.dart';
import '../../../history/domain/usecases/history_usecases.dart';
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
  final AddHistoryEntry _addHistoryEntry;

  StreamSubscription<({String bundleId, String appName})>? _subscription;

  /// Intervalo/limite do polling que aguarda a janela do app recém-aberto.
  static const Duration pollInterval = Duration(milliseconds: 600);
  static const int maxPollAttempts = 10;

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
  }

  Future<void> save(Rule rule) async {
    final result = await _saveRule(rule);
    await result.fold(
      (failure) async => emit(state.copyWith(feedback: failure.message)),
      (_) async => load(),
    );
  }

  Future<void> toggle(Rule rule) => save(rule.copyWith(isActive: !rule.isActive));

  Future<void> delete(Rule rule) async {
    await _deleteRule(rule.id);
    await load();
  }

  void clearFeedback() {
    if (state.feedback != null) emit(state.copyWith());
  }

  /// Engine: reage à abertura de um app.
  Future<void> onAppLaunched(({String bundleId, String appName}) event) async {
    final matching = state.rules
        .where((rule) => rule.isActive && rule.bundleId == event.bundleId)
        .toList(growable: false);
    if (matching.isEmpty) return;

    final window = await _waitForWindow(event.bundleId);
    if (window == null) return;

    // Geometria fresca dos monitores (Dock/menu bar podem ter migrado de tela).
    await _monitorsCubit.refresh();
    final settings = _settingsCubit.state.settings;
    for (final rule in matching) {
      final result = await _applyRule(
        ApplyRuleParams(
          rule: rule,
          window: window,
          monitors: _monitorsCubit.state.monitors,
          gap: settings.windowGap,
          margin: settings.screenMargin,
        ),
      );
      if (result.getOrElse((_) => false)) {
        await _addHistoryEntry(
          AddHistoryParams(
            type: HistoryEntryType.rule,
            title: 'Regra aplicada a ${rule.appName}',
            subtitle: rule.actionType.label,
          ),
        );
      }
    }
  }

  /// Aguarda a janela principal do app aparecer.
  Future<ManagedWindow?> _waitForWindow(String bundleId) async {
    for (var attempt = 0; attempt < maxPollAttempts; attempt++) {
      final windows = (await _getWindows(const NoParams())).getOrElse(
        (_) => const [],
      );
      final candidates =
          windows.where((window) => window.bundleId == bundleId).toList()
            ..sort(
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
