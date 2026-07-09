import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ms_icon.dart';
import '../cubits/license_cubit.dart';
import '../cubits/license_state.dart';

/// Envolve um recurso premium: renderiza o filho normalmente para
/// assinantes e um cartão de upsell para o plano grátis.
///
/// Uso: `PremiumGate(featureName: 'Regras automáticas', child: ...)`.
class PremiumGate extends StatelessWidget {
  PremiumGate({super.key, required this.featureName, required this.child});

  final String featureName;
  final Widget child;

  final LicenseCubit _cubit = getIt<LicenseCubit>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LicenseCubit, LicenseState>(
      bloc: _cubit,
      buildWhen: (previous, current) =>
          previous.isPremium != current.isPremium,
      builder: (context, state) {
        if (state.isPremium) return child;
        return _UpsellCard(featureName: featureName);
      },
    );
  }
}

class _UpsellCard extends StatelessWidget {
  const _UpsellCard({required this.featureName});

  final String featureName;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.cardBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MsIcon('workspace_premium', size: 34, color: colors.text2),
            const SizedBox(height: 12),
            Text(
              '$featureName é um recurso premium',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Assine o FlowDesk Premium para desbloquear este e outros '
              'recursos avançados.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: colors.text3),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => launchUrl(Uri.parse(AppConstants.checkoutUrl)),
              child: const Text('Assinar FlowDesk Premium'),
            ),
          ],
        ),
      ),
    );
  }
}
