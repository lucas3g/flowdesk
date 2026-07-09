import 'package:equatable/equatable.dart';

import '../../domain/entities/license.dart';

enum LicenseStatus { initial, loading, ready, activating, error }

class LicenseState extends Equatable {
  const LicenseState({
    this.status = LicenseStatus.initial,
    this.license = License.free,
    this.errorMessage,
  });

  final LicenseStatus status;
  final License license;
  final String? errorMessage;

  bool get isPremium => license.isPremium;

  LicenseState copyWith({
    LicenseStatus? status,
    License? license,
    String? errorMessage,
  }) {
    return LicenseState(
      status: status ?? this.status,
      license: license ?? this.license,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, license, errorMessage];
}
