import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/ms_icon.dart';
import '../../../windows/presentation/cubits/windows_cubit.dart';
import '../cubits/layout_editor_cubit.dart';
import '../cubits/layout_editor_state.dart';
import '../widgets/editor_canvas.dart';
import '../widgets/region_inspector.dart';

/// Editor visual de layouts: toolbar, canvas com grade e inspector.
class LayoutEditorPage extends StatefulWidget {
  const LayoutEditorPage({super.key});

  @override
  State<LayoutEditorPage> createState() => _LayoutEditorPageState();
}

class _LayoutEditorPageState extends State<LayoutEditorPage> {
  final LayoutEditorCubit _cubit = getIt<LayoutEditorCubit>();
  final WindowsCubit _windowsCubit = getIt<WindowsCubit>();

  @override
  void initState() {
    super.initState();
    // Apps em execução para o seletor "App associado" do inspector.
    _windowsCubit.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocListener<LayoutEditorCubit, LayoutEditorState>(
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
      child: BlocBuilder<LayoutEditorCubit, LayoutEditorState>(
        bloc: _cubit,
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 22,
              horizontal: AppDimens.pagePaddingHorizontal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Toolbar(cubit: _cubit, state: state, colors: colors),
                const SizedBox(height: 16),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: EditorCanvas(
                            state: state,
                            onSelect: _cubit.select,
                            onSetFrame: (index, x, y, width, height) =>
                                _cubit.setFrame(
                                  index,
                                  x: x,
                                  y: y,
                                  width: width,
                                  height: height,
                                ),
                            onCreate: _cubit.addRegionAt,
                            onBringToFront: _cubit.bringRegionToFront,
                            onSendToBack: _cubit.sendRegionToBack,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimens.gridGap),
                      RegionInspector(
                        state: state,
                        onRename: (name) =>
                            _cubit.renameRegion(state.selectedIndex!, name),
                        onSetFrame: ({x, y, width, height}) => _cubit.setFrame(
                          state.selectedIndex!,
                          x: x,
                          y: y,
                          width: width,
                          height: height,
                        ),
                        onSetColor: (hex) =>
                            _cubit.setRegionColor(state.selectedIndex!, hex),
                        onSetApp: ({bundleId, appName, windowTitle}) =>
                            _cubit.setRegionApp(
                              state.selectedIndex!,
                              bundleId: bundleId,
                              appName: appName,
                              windowTitle: windowTitle,
                            ),
                        onDelete: () =>
                            _cubit.deleteRegion(state.selectedIndex!),
                        onApplyPreset: _cubit.applyPreset,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Campo do nome do layout com controller persistente, que atualiza o
/// estado a cada tecla (não só no Enter) e reflete mudanças externas do
/// nome sem interromper a digitação.
class _LayoutNameField extends StatefulWidget {
  const _LayoutNameField({
    super.key,
    required this.initialName,
    required this.currentName,
    required this.onChanged,
    required this.colors,
  });

  final String initialName;
  final String currentName;
  final ValueChanged<String> onChanged;
  final FlowDeskColors colors;

  @override
  State<_LayoutNameField> createState() => _LayoutNameFieldState();
}

class _LayoutNameFieldState extends State<_LayoutNameField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void didUpdateWidget(_LayoutNameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reflete mudanças de nome vindas de fora (ex.: preencher com o app),
    // sem sobrescrever enquanto o usuário digita o mesmo valor.
    if (widget.currentName != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.currentName,
        selection: TextSelection.collapsed(offset: widget.currentName.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      style: TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: widget.colors.text,
      ),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: widget.colors.hover,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusIconButton),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.cubit,
    required this.state,
    required this.colors,
  });

  final LayoutEditorCubit cubit;
  final LayoutEditorState state;
  final FlowDeskColors colors;

  @override
  Widget build(BuildContext context) {
    final regions = state.layout.regions.length;

    return Row(
      children: [
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: SizedBox(
              height: 34,
              child: _LayoutNameField(
                // A key força reinicializar o controller quando outro layout
                // é carregado no editor.
                key: ValueKey('layout-name-${state.layout.id}'),
                initialName: state.layout.name,
                currentName: state.layout.name,
                onChanged: cubit.setName,
                colors: colors,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            '$regions ${regions == 1 ? 'região' : 'regiões'}'
            '${state.isDirty ? ' · não salvo' : ''}',
            style: TextStyle(fontSize: 12, color: colors.text3),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Spacer(),
        _ToolbarIcon(
          icon: 'grid_4x4',
          tooltip: 'Grade',
          active: state.gridVisible,
          onPressed: cubit.toggleGrid,
        ),
        _ToolbarIcon(
          icon: 'align_space_even',
          tooltip: 'Snap na grade',
          active: state.snapEnabled,
          onPressed: cubit.toggleSnap,
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: cubit.newLayout,
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.text,
            side: BorderSide(color: colors.cardBorder),
            textStyle: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          icon: MsIcon('note_add', size: 15, color: colors.text2),
          label: const Text('Novo'),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: cubit.addRegion,
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.text,
            side: BorderSide(color: colors.cardBorder),
            textStyle: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          icon: MsIcon('add_box', size: 15, color: colors.text2),
          label: const Text('Adicionar região'),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: cubit.save,
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.text,
            side: BorderSide(color: colors.cardBorder),
            textStyle: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          icon: MsIcon('save', size: 15, color: colors.text2),
          label: const Text('Salvar'),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: cubit.saveAndApply,
          icon: const MsIcon('play_arrow', size: 15, color: Colors.white),
          label: const Text('Salvar e aplicar'),
        ),
      ],
    );
  }
}

class _ToolbarIcon extends StatelessWidget {
  const _ToolbarIcon({
    required this.icon,
    required this.tooltip,
    required this.active,
    required this.onPressed,
  });

  final String icon;
  final String tooltip;
  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 400),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimens.radiusIconButton),
        hoverColor: colors.hover,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: active ? colors.blueSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimens.radiusIconButton),
          ),
          child: Center(
            child: MsIcon(
              icon,
              size: 16,
              color: active ? colors.blue : colors.text2,
            ),
          ),
        ),
      ),
    );
  }
}
