import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/fd_switch.dart';
import '../../../../core/widgets/ms_icon.dart';
import '../../../layouts/presentation/cubits/layouts_cubit.dart';
import '../../../windows/presentation/cubits/windows_cubit.dart';
import '../../domain/entities/rule.dart';
import '../cubits/rules_cubit.dart';
import '../cubits/rules_state.dart';
import '../widgets/rule_editor_dialog.dart';

/// Tela de Regras: "se abrir X, fazer Y", com toggle Ativa/Pausada.
class RulesPage extends StatefulWidget {
  const RulesPage({super.key});

  @override
  State<RulesPage> createState() => _RulesPageState();
}

class _RulesPageState extends State<RulesPage> {
  final RulesCubit _cubit = getIt<RulesCubit>();
  final WindowsCubit _windowsCubit = getIt<WindowsCubit>();
  final LayoutsCubit _layoutsCubit = getIt<LayoutsCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.load();
    // Dados usados pelo dialog de criação.
    _windowsCubit.refresh();
    _layoutsCubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocListener<RulesCubit, RulesState>(
      bloc: _cubit,
      listenWhen: (previous, current) =>
          current.feedback != null && previous.feedback != current.feedback,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(state.feedback!),
              behavior: SnackBarBehavior.floating,
              width: 420,
            ),
          );
        _cubit.clearFeedback();
      },
      child: BlocBuilder<RulesCubit, RulesState>(
        bloc: _cubit,
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimens.pagePaddingVertical,
              horizontal: AppDimens.pagePaddingHorizontal,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Regras',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Posicionamento automático quando um app '
                                'é aberto.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: () async {
                            final rule = await RuleEditorDialog.show(context);
                            if (rule != null) await _cubit.save(rule);
                          },
                          icon: const MsIcon(
                            'add',
                            size: 15,
                            color: Colors.white,
                          ),
                          label: const Text('Nova regra'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (state.rules.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            state.status == RulesStatus.loading
                                ? 'Carregando regras…'
                                : 'Nenhuma regra ainda — crie a primeira.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusCard,
                          ),
                          border: Border.all(color: colors.cardBorder),
                        ),
                        child: Column(
                          children: [
                            for (var i = 0; i < state.rules.length; i++) ...[
                              if (i > 0)
                                Divider(
                                  height: 1,
                                  indent: 52,
                                  color: colors.separator,
                                ),
                              _RuleRow(
                                rule: state.rules[i],
                                onToggle: () => _cubit.toggle(state.rules[i]),
                                onDelete: () => _cubit.delete(state.rules[i]),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  _RuleRow({required this.rule, required this.onToggle, required this.onDelete});

  final Rule rule;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  final LayoutsCubit _layoutsCubit = getIt<LayoutsCubit>();

  String get _description {
    final layouts = _layoutsCubit.state.layouts;
    switch (rule.actionType) {
      case RuleActionType.moveToMonitor:
        return 'Mover para o monitor ${rule.targetValue}';
      case RuleActionType.maximize:
        return 'Maximizar no monitor atual';
      case RuleActionType.center:
        return 'Centralizar no monitor atual';
      case RuleActionType.applyRegion:
        final target = rule.regionTarget;
        if (target == null) return 'Encaixar em região';
        // O monitorKey é `nome:LARGURAxALTURA` (o nome pode conter `:`) —
        // exibe só o nome, descartando o último segmento.
        final key = target.$3;
        final cut = key?.lastIndexOf(':') ?? -1;
        final suffix = key != null && cut > 0
            ? ' em ${key.substring(0, cut)}'
            : '';
        for (final layout in layouts) {
          if (layout.id == target.$1 && target.$2 < layout.regions.length) {
            return "Região '${layout.regions[target.$2].name}' "
                'de ${layout.name}$suffix';
          }
        }
        return 'Encaixar em região (removida)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: colors.purple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(7),
            ),
            alignment: Alignment.center,
            child: MsIcon('account_tree', size: 15, color: colors.purple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${rule.appName} → $_description',
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  rule.isActive ? 'Ativa' : 'Pausada',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: rule.isActive ? colors.green : colors.text3,
                  ),
                ),
              ],
            ),
          ),
          FdSwitch(value: rule.isActive, onChanged: (_) => onToggle()),
          const SizedBox(width: 4),
          Tooltip(
            message: 'Excluir',
            child: InkWell(
              onTap: onDelete,
              borderRadius: BorderRadius.circular(7),
              hoverColor: colors.hover,
              child: SizedBox(
                width: 30,
                height: 30,
                child: Center(
                  child: MsIcon('delete', size: 15, color: colors.text3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
