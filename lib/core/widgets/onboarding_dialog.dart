import 'package:flutter/material.dart';

import '../../features/settings/presentation/cubits/settings_cubit.dart';
import '../di/injection.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import 'ms_icon.dart';

/// Abre o assistente de primeiro uso (boas-vindas + nome). Ao fechar,
/// o tour guiado pela interface assume a apresentação do app.
Future<void> showOnboarding(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const OnboardingDialog(),
  );
}

/// Assistente de primeiro uso: um passo único que dá boas-vindas e pede o
/// nome do usuário; o restante da apresentação é feito pelo tour guiado.
class OnboardingDialog extends StatefulWidget {
  const OnboardingDialog({super.key});

  @override
  State<OnboardingDialog> createState() => _OnboardingDialogState();
}

class _OnboardingDialogState extends State<OnboardingDialog> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
                  const Text(
                    'Bem-vindo ao FlowDesk',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Organize janelas em layouts completos de trabalho.',
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
                  TextField(
                    controller: _nameController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    onSubmitted: (_) => _finish(),
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
                        borderRadius: BorderRadius.circular(
                          AppDimens.radiusButton,
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Em seguida, um tour rápido mostra onde fica cada coisa.',
                    style: TextStyle(fontSize: 11.5, color: colors.text3),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: _finish,
                      icon: const MsIcon(
                        'rocket_launch',
                        size: 14,
                        color: Colors.white,
                      ),
                      label: const Text('Começar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Conclui o assistente gravando o nome e a flag de onboarding.
  Future<void> _finish() async {
    Navigator.of(context).pop();
    final name = _nameController.text.trim();
    await getIt<SettingsCubit>().completeOnboarding(
      userName: name.isEmpty ? null : name,
    );
  }
}
