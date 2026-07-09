import 'package:equatable/equatable.dart';

/// Plano efetivo do usuário.
enum LicensePlan { free, premium }

/// Estado da licença desta instalação, derivado do entitlement assinado
/// em cache local.
class License extends Equatable {
  const License({
    this.plan = LicensePlan.free,
    this.key = '',
    this.premiumUntil,
    this.lastValidatedAt,
    this.inGracePeriod = false,
  });

  /// Licença padrão de quem nunca ativou (plano grátis).
  static const License free = License();

  final LicensePlan plan;
  final String key;

  /// Fim do período pago vigente (próxima cobrança + folga do servidor).
  final DateTime? premiumUntil;
  final DateTime? lastValidatedAt;

  /// Premium mantido apenas pela tolerância offline — o período pago já
  /// venceu e não foi possível revalidar com o servidor.
  final bool inGracePeriod;

  bool get isPremium => plan == LicensePlan.premium;

  License copyWith({
    LicensePlan? plan,
    String? key,
    DateTime? premiumUntil,
    DateTime? lastValidatedAt,
    bool? inGracePeriod,
  }) {
    return License(
      plan: plan ?? this.plan,
      key: key ?? this.key,
      premiumUntil: premiumUntil ?? this.premiumUntil,
      lastValidatedAt: lastValidatedAt ?? this.lastValidatedAt,
      inGracePeriod: inGracePeriod ?? this.inGracePeriod,
    );
  }

  @override
  List<Object?> get props => [
    plan,
    key,
    premiumUntil,
    lastValidatedAt,
    inGracePeriod,
  ];
}
