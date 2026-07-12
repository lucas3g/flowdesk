import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ms_icon.dart';
import '../../../settings/presentation/widgets/settings_group.dart';
import '../cubits/license_cubit.dart';
import '../cubits/license_state.dart';

/// Grupo "Licença" das Configurações: status do plano, ativação por
/// chave e assinatura via checkout do Paddle.
class LicenseSection extends StatefulWidget {
  const LicenseSection({super.key});

  @override
  State<LicenseSection> createState() => _LicenseSectionState();
}

class _LicenseSectionState extends State<LicenseSection> {
  final LicenseCubit _cubit = getIt<LicenseCubit>();
  final TextEditingController _keyController = TextEditingController();

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LicenseCubit, LicenseState>(
      bloc: _cubit,
      builder: (context, state) {
        return SettingsGroup(
          title: 'LICENÇA',
          children: [
            _statusRow(context, state),
            if (!state.isPremium) _activationRow(context, state),
          ],
        );
      },
    );
  }

  Widget _statusRow(BuildContext context, LicenseState state) {
    final colors = context.colors;
    final license = state.license;

    final String subtitle;
    if (license.isPremium) {
      final until = license.premiumUntil;
      final formatted = until != null
          ? DateFormat('dd/MM/yyyy').format(until.toLocal())
          : '—';
      subtitle = license.inGracePeriod
          ? 'Renovação pendente — ativo até $formatted (tolerância offline)'
          : 'Assinatura ativa até $formatted';
    } else {
      subtitle = 'Assine para desbloquear os recursos premium';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: colors.hover,
              borderRadius: BorderRadius.circular(7),
            ),
            alignment: Alignment.center,
            child: MsIcon(
              license.isPremium ? 'workspace_premium' : 'lock',
              size: 15,
              color: colors.text2,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  license.isPremium ? 'FlowDesk Premium' : 'Plano Grátis',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11.5, color: colors.text3),
                ),
              ],
            ),
          ),
          if (license.isPremium)
            TextButton(
              onPressed: _cubit.deactivate,
              child: const Text(
                'Desativar nesta máquina',
                style: TextStyle(fontSize: 12),
              ),
            )
          else
            FilledButton(
              onPressed: () => launchUrl(Uri.parse(AppConstants.checkoutUrl)),
              child: const Text('Assinar', style: TextStyle(fontSize: 12.5)),
            ),
        ],
      ),
    );
  }

  Widget _activationRow(BuildContext context, LicenseState state) {
    final colors = context.colors;
    final activating = state.status == LicenseStatus.activating;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _keyController,
                  enabled: !activating,
                  style: const TextStyle(fontSize: 12.5),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Já assinou? Cole aqui sua chave de licença',
                    hintStyle: TextStyle(fontSize: 12.5, color: colors.text3),
                    filled: true,
                    fillColor: colors.hover,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: activating
                    ? null
                    : () => _cubit.activate(_keyController.text),
                child: activating
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Ativar', style: TextStyle(fontSize: 12.5)),
              ),
            ],
          ),
          if (state.status == LicenseStatus.error && state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                state.errorMessage!,
                style: TextStyle(
                  fontSize: 11.5,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
