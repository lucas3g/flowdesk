import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/ms_icon.dart';
import '../../../layouts/presentation/cubits/applied_layouts_cubit.dart';
import '../../../layouts/presentation/cubits/layouts_cubit.dart';
import '../../../monitors/domain/entities/monitor.dart';
import '../../../monitors/presentation/cubits/monitors_cubit.dart';
import '../../../windows/presentation/cubits/windows_cubit.dart';
import '../../domain/entities/rule.dart';

/// Dialog de criação de regra: app em execução + ação + alvo.
class RuleEditorDialog extends StatefulWidget {
  const RuleEditorDialog({super.key});

  static Future<Rule?> show(BuildContext context) {
    return showDialog<Rule>(
      context: context,
      builder: (_) => const RuleEditorDialog(),
    );
  }

  @override
  State<RuleEditorDialog> createState() => _RuleEditorDialogState();
}

class _RuleEditorDialogState extends State<RuleEditorDialog> {
  final WindowsCubit _windowsCubit = getIt<WindowsCubit>();
  final MonitorsCubit _monitorsCubit = getIt<MonitorsCubit>();
  final LayoutsCubit _layoutsCubit = getIt<LayoutsCubit>();
  final AppliedLayoutsCubit _appliedLayoutsCubit = getIt<AppliedLayoutsCubit>();

  String? _bundleId;
  String? _appName;
  RuleActionType _actionType = RuleActionType.center;
  String? _monitorName;
  int? _layoutId;
  int _regionIndex = 0;

  /// Monitor de destino da região (chave estável, ver [monitorKey]).
  String? _regionMonitorKey;

  /// Monitor sugerido para o layout: onde ele está aplicado, senão o
  /// primário.
  String? _suggestedMonitorKey(int? layoutId) {
    final monitors = _monitorsCubit.state.monitors;
    if (monitors.isEmpty) return null;
    for (final monitor in monitors) {
      if (_appliedLayoutsCubit.state[monitorKey(monitor)] == layoutId) {
        return monitorKey(monitor);
      }
    }
    final primary = monitors.firstWhere(
      (monitor) => monitor.isPrimary,
      orElse: () => monitors.first,
    );
    return monitorKey(primary);
  }

  Map<String, ({String name, Uint8List? icon})> get _runningApps {
    final apps = <String, ({String name, Uint8List? icon})>{};
    for (final window in _windowsCubit.state.windows) {
      if (window.bundleId.isNotEmpty) {
        apps[window.bundleId] = (
          name: window.appName,
          icon: apps[window.bundleId]?.icon ?? window.icon,
        );
      }
    }
    return apps;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final monitors = _monitorsCubit.state.monitors;
    final layouts = _layoutsCubit.state.layouts;
    final selectedLayout = layouts
        .where((layout) => layout.id == _layoutId)
        .firstOrNull;

    return Dialog(
      backgroundColor: colors.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusCardLarge),
        side: BorderSide(color: colors.cardBorder),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nova regra',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Quando o app abrir, a ação é executada automaticamente.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _bundleId,
                items: [
                  for (final entry in _runningApps.entries)
                    DropdownMenuItem(
                      value: entry.key,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _AppIcon(icon: entry.value.icon, size: 18),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              entry.value.name,
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                onChanged: (value) => setState(() {
                  _bundleId = value;
                  _appName = value != null ? _runningApps[value]?.name : null;
                }),
                decoration: _decoration(colors, 'Aplicativo (em execução)'),
                dropdownColor: colors.panel2,
                style: TextStyle(fontSize: 13, color: colors.text),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<RuleActionType>(
                initialValue: _actionType,
                items: [
                  for (final type in RuleActionType.values)
                    DropdownMenuItem(
                      value: type,
                      child: Text(
                        type.label,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                ],
                onChanged: (value) => setState(
                  () => _actionType = value ?? RuleActionType.center,
                ),
                decoration: _decoration(colors, 'Ação'),
                dropdownColor: colors.panel2,
                style: TextStyle(fontSize: 13, color: colors.text),
              ),
              if (_actionType == RuleActionType.moveToMonitor) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _monitorName,
                  items: [
                    for (final monitor in monitors)
                      DropdownMenuItem(
                        value: monitor.name,
                        child: Text(
                          monitor.name,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                  ],
                  onChanged: (value) => setState(() => _monitorName = value),
                  decoration: _decoration(colors, 'Monitor de destino'),
                  dropdownColor: colors.panel2,
                  style: TextStyle(fontSize: 13, color: colors.text),
                ),
              ],
              if (_actionType == RuleActionType.applyRegion) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _layoutId,
                  items: [
                    for (final layout in layouts)
                      DropdownMenuItem(
                        value: layout.id,
                        child: Text(
                          layout.name,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                  ],
                  onChanged: (value) => setState(() {
                    _layoutId = value;
                    _regionIndex = 0;
                    _regionMonitorKey = _suggestedMonitorKey(value);
                  }),
                  decoration: _decoration(colors, 'Layout'),
                  dropdownColor: colors.panel2,
                  style: TextStyle(fontSize: 13, color: colors.text),
                ),
                if (selectedLayout != null) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: _regionIndex,
                    items: [
                      for (var i = 0; i < selectedLayout.regions.length; i++)
                        DropdownMenuItem(
                          value: i,
                          child: Text(
                            selectedLayout.regions[i].name,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                    ],
                    onChanged: (value) =>
                        setState(() => _regionIndex = value ?? 0),
                    decoration: _decoration(colors, 'Região'),
                    dropdownColor: colors.panel2,
                    style: TextStyle(fontSize: 13, color: colors.text),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _regionMonitorKey,
                    items: [
                      for (final monitor in monitors)
                        DropdownMenuItem(
                          value: monitorKey(monitor),
                          child: Text(
                            monitor.name,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                    ],
                    onChanged: (value) =>
                        setState(() => _regionMonitorKey = value),
                    decoration: _decoration(colors, 'Monitor de destino'),
                    dropdownColor: colors.panel2,
                    style: TextStyle(fontSize: 13, color: colors.text),
                  ),
                ],
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _canSubmit ? _submit : null,
                    child: const Text('Criar regra'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _canSubmit {
    if (_bundleId == null) return false;
    return switch (_actionType) {
      RuleActionType.moveToMonitor => _monitorName != null,
      RuleActionType.applyRegion =>
        _layoutId != null && _regionMonitorKey != null,
      _ => true,
    };
  }

  void _submit() {
    final targetValue = switch (_actionType) {
      RuleActionType.moveToMonitor => _monitorName!,
      RuleActionType.applyRegion =>
        '$_layoutId:$_regionIndex:$_regionMonitorKey',
      _ => '',
    };
    Navigator.of(context).pop(
      Rule(
        bundleId: _bundleId!,
        appName: _appName ?? _bundleId!,
        actionType: _actionType,
        targetValue: targetValue,
      ),
    );
  }

  InputDecoration _decoration(FlowDeskColors colors, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 11.5, color: colors.text3),
      isDense: true,
      filled: true,
      fillColor: colors.hover,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusIconButton),
        borderSide: BorderSide.none,
      ),
    );
  }
}

/// Ícone do app vindo do sistema, com fallback genérico.
class _AppIcon extends StatelessWidget {
  const _AppIcon({required this.icon, required this.size});

  final Uint8List? icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (icon == null) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: MsIcon('apps', size: size - 4, color: colors.text2),
        ),
      );
    }
    return Image.memory(
      icon!,
      width: size,
      height: size,
      gaplessPlayback: true,
    );
  }
}
