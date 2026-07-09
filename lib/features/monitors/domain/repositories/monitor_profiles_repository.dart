import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/monitor_profile.dart';

/// Contrato de persistência dos perfis por configuração de monitores.
abstract interface class MonitorProfilesRepository {
  Future<Either<Failure, List<MonitorProfile>>> getProfiles();

  /// Insere ou substitui o perfil da mesma configuração (fingerprint único).
  Future<Either<Failure, MonitorProfile>> saveProfile(MonitorProfile profile);

  Future<Either<Failure, Unit>> deleteProfile(int profileId);
}
