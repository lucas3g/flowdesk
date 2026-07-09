import '../../domain/entities/permissions_status.dart';

/// Conversão do payload do canal nativo para a entidade de domínio.
abstract final class PermissionsStatusModel {
  static PermissionsStatus fromMap(Map<String, dynamic> map) {
    return PermissionsStatus(
      accessibility: map['accessibility'] == true,
      screenRecording: map['screenRecording'] == true,
    );
  }
}

/// Nome da seção usado pelo PermissionManager (Swift) ao abrir as Ajustes.
extension PermissionTypeChannelName on PermissionType {
  String get channelName => switch (this) {
    PermissionType.accessibility => 'accessibility',
    PermissionType.screenRecording => 'screenRecording',
    PermissionType.automation => 'automation',
  };
}
