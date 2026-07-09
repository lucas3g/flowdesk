import 'package:flutter/material.dart';

import '../../features/layouts/domain/entities/layout.dart';
import '../../features/layouts/presentation/cubits/layouts_cubit.dart';
import '../../features/layouts/presentation/widgets/layout_preview.dart';
import '../../features/settings/presentation/cubits/settings_cubit.dart';
import '../di/injection.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import 'ms_icon.dart';

/// Abre o assistente de primeiro uso (4 passos).
Future<void> showOnboarding(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const OnboardingDialog(),
  );
}

/// Assistente de primeiro uso: boas-vindas, foco, layout inicial e resumo.
class OnboardingDialog extends StatefulWidget {
  const OnboardingDialog({super.key});

  @override
  State<OnboardingDialog> createState() => _OnboardingDialogState();
}

class _OnboardingDialogState extends State<OnboardingDialog> {
  int _step = 0;
  int _setupChoice = 0;
  int _focusChoice = 0;
  Layout? _chosenLayout;
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  List<Layout> get _suggestedLayouts {
    final layouts = getIt<LayoutsCubit>().state.layouts;
    final names = ['Código & Terminal', 'Grade Design 4×', 'Foco Central'];
    return [
      for (final name in names)
        ...layouts.where((layout) => layout.name == name),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Dialog(
      backgroundColor: colors.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusCardLarge),
        side: BorderSide(color: colors.cardBorder),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cabeçalho em gradiente.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colors.blue, colors.purple],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimens.radiusCardLarge),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MsIcon('auto_awesome', size: 26, color: Colors.white),
                  const SizedBox(height: 10),
                  Text(
                    _titleForStep,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitleForStep,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStep(colors),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // Indicador de progresso (o ponto ativo alonga).
                      for (var i = 0; i < 4; i++)
                        AnimatedContainer(
                          duration: AppDimens.transitionFast,
                          margin: const EdgeInsets.only(right: 5),
                          width: i == _step ? 22 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: i == _step ? colors.blue : colors.hover,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      const Spacer(),
                      if (_step > 0 && _step < 3)
                        TextButton(
                          onPressed: () => setState(() => _step--),
                          child: const Text('Voltar'),
                        ),
                      // Na última etapa: fechar sem aplicar o layout
                      // (mantém o nome e conclui o onboarding).
                      if (_step == 3)
                        TextButton(
                          onPressed: () => _finish(applyChosenLayout: false),
                          child: const Text('Fechar sem aplicar'),
                        ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: _step == 3
                            ? () => _finish(applyChosenLayout: true)
                            : () => setState(() => _step++),
                        icon: MsIcon(
                          _step == 3 ? 'rocket_launch' : 'arrow_forward',
                          size: 14,
                          color: Colors.white,
                        ),
                        label: Text(_step == 3 ? 'Começar' : 'Continuar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _titleForStep => switch (_step) {
    0 => 'Bem-vindo ao FlowDesk',
    1 => 'Qual seu foco principal?',
    2 => 'Escolha um layout inicial',
    _ => 'Tudo pronto!',
  };

  String get _subtitleForStep => switch (_step) {
    0 => 'Organize janelas em layouts completos de trabalho.',
    1 => 'Usamos isso para sugerir layouts.',
    2 => 'Você pode aplicá-lo agora mesmo.',
    _ => 'Dicas rápidas para começar bem.',
  };

  Widget _buildStep(FlowDeskColors colors) {
    switch (_step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
              style: TextStyle(fontSize: 14, color: colors.text),
              decoration: InputDecoration(
                labelText: 'Como podemos te chamar?',
                labelStyle: TextStyle(fontSize: 12, color: colors.text3),
                isDense: true,
                filled: true,
                fillColor: colors.hover,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusButton),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _ChoiceCards(
              selected: _setupChoice,
              onSelect: (index) => setState(() => _setupChoice = index),
              options: const [
                ('🖥️', 'Ultrawide', 'Uma tela grande, muitas colunas'),
                ('🖥️🖥️', 'Vários monitores', 'Workspaces por tela'),
              ],
            ),
          ],
        );
      case 1:
        return _ChoiceCards(
          selected: _focusChoice,
          onSelect: (index) => setState(() => _focusChoice = index),
          options: const [
            ('💻', 'Código', 'Editor, terminal e docs'),
            ('🎨', 'Design', 'Canvas e referências'),
            ('✍️', 'Escrita', 'Foco sem distração'),
          ],
        );
      case 2:
        final layouts = _suggestedLayouts;
        _chosenLayout ??= layouts.isNotEmpty ? layouts.first : null;
        return Column(
          children: [
            for (final layout in layouts)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => setState(() => _chosenLayout = layout),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.hover,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _chosenLayout == layout
                            ? colors.blue
                            : colors.cardBorder,
                        width: _chosenLayout == layout ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 64,
                          height: 40,
                          child: LayoutPreview(
                            layout: layout,
                            showLabels: false,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            layout.name,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        if (layout.shortcut != null)
                          Text(
                            layout.shortcut!,
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.text3,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            if (layouts.isEmpty)
              Text(
                'Os layouts padrão aparecem aqui após o primeiro uso.',
                style: TextStyle(fontSize: 12, color: colors.text3),
              ),
          ],
        );
      default:
        return Column(
          children: const [
            _TipRow(
              icon: 'keyboard_command_key',
              text: '⌥1–⌥9 aplicam layouts de qualquer app.',
            ),
            SizedBox(height: 8),
            _TipRow(icon: 'search', text: '⌘K abre a paleta de comandos.'),
            SizedBox(height: 8),
            _TipRow(
              icon: 'toolbar',
              text: 'O FlowDesk também vive na barra de menus.',
            ),
          ],
        );
    }
  }

  /// Conclui o onboarding: grava o nome e a flag; aplica o layout escolhido
  /// apenas quando [applyChosenLayout] for verdadeiro.
  Future<void> _finish({required bool applyChosenLayout}) async {
    Navigator.of(context).pop();
    final name = _nameController.text.trim();
    await getIt<SettingsCubit>().completeOnboarding(
      userName: name.isEmpty ? null : name,
    );
    final chosen = _chosenLayout;
    if (applyChosenLayout && chosen != null) {
      await getIt<LayoutsCubit>().apply(chosen);
    }
  }
}

class _ChoiceCards extends StatelessWidget {
  const _ChoiceCards({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final List<(String, String, String)> options;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: () => onSelect(i),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.hover,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected == i ? colors.blue : colors.cardBorder,
                    width: selected == i ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      options[i].$1,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      options[i].$2,
                      style: Theme.of(context).textTheme.titleSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      options[i].$3,
                      style: TextStyle(fontSize: 10.5, color: colors.text3),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.icon, required this.text});

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.hover,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          MsIcon(icon, size: 16, color: colors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12.5, color: colors.text),
            ),
          ),
        ],
      ),
    );
  }
}
