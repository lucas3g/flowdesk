import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/ms_icon.dart';
import '../../../layouts/presentation/cubits/layouts_cubit.dart';
import '../../../windows/presentation/cubits/windows_cubit.dart';
import '../../domain/entities/workspace.dart';
import '../cubits/workspaces_cubit.dart';
import '../cubits/workspaces_state.dart';
import '../widgets/workspace_card.dart';
import '../widgets/workspace_editor_dialog.dart';

/// Tela de Workspaces: cards com ativação em um clique e CRUD.
class WorkspacesPage extends StatefulWidget {
  const WorkspacesPage({super.key});

  @override
  State<WorkspacesPage> createState() => _WorkspacesPageState();
}

class _WorkspacesPageState extends State<WorkspacesPage> {
  final WorkspacesCubit _cubit = getIt<WorkspacesCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.load();
    // Layouts para o dropdown do editor e janelas para "Adicionar app".
    getIt<LayoutsCubit>().load();
    getIt<WindowsCubit>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WorkspacesCubit, WorkspacesState>(
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
              width: 480,
            ),
          );
        _cubit.clearFeedback();
      },
      child: BlocBuilder<WorkspacesCubit, WorkspacesState>(
        bloc: _cubit,
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimens.pagePaddingVertical,
              horizontal: AppDimens.pagePaddingHorizontal,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, state),
                    const SizedBox(height: 20),
                    _buildGrid(context, state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WorkspacesState state) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Workspaces',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 2),
              Text(
                '${state.workspaces.length} workspaces'
                ' · ativar abre os apps e aplica o layout',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: () => _openEditor(context),
          icon: const MsIcon('add', size: 15, color: Colors.white),
          label: const Text('Novo workspace'),
        ),
      ],
    );
  }

  Widget _buildGrid(BuildContext context, WorkspacesState state) {
    if (state.status == WorkspacesStatus.error) {
      return Text(
        state.errorMessage ?? 'Não foi possível carregar os workspaces.',
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
    if (state.workspaces.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            state.status == WorkspacesStatus.loading
                ? 'Carregando workspaces…'
                : 'Nenhum workspace ainda — crie o primeiro.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }

    final layoutsById = {
      for (final layout in getIt<LayoutsCubit>().state.layouts)
        layout.id: layout.name,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = AppDimens.gridGap;
        final columns = constraints.maxWidth > 720 ? 2 : 1;
        final cardWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final workspace in state.workspaces)
              SizedBox(
                width: cardWidth,
                child: WorkspaceCard(
                  workspace: workspace,
                  layoutName: layoutsById[workspace.layoutId],
                  isApplying: state.applyingId == workspace.id,
                  onApply: () => _cubit.apply(workspace),
                  onEdit: () => _openEditor(context, workspace: workspace),
                  onDelete: () => _cubit.delete(workspace),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _openEditor(BuildContext context, {Workspace? workspace}) async {
    final result = await WorkspaceEditorDialog.show(
      context,
      workspace: workspace,
    );
    if (result != null) await _cubit.save(result);
  }
}
