import 'package:injectable/injectable.dart';

import '../../../../core/platform/platform_channel.dart';

/// Acesso ao WorkspaceManager (Swift) via MethodChannel.
abstract interface class WorkspacePlatformDatasource {
  Future<bool> launchApp(String bundleId);
}

@LazySingleton(as: WorkspacePlatformDatasource)
class WorkspacePlatformDatasourceImpl implements WorkspacePlatformDatasource {
  const WorkspacePlatformDatasourceImpl(
    @Named('workspaceChannel') this._channel,
  );

  final PlatformChannel _channel;

  @override
  Future<bool> launchApp(String bundleId) async {
    final launched = await _channel.invoke<bool>('launchApp', {
      'bundleId': bundleId,
    });
    return launched ?? false;
  }
}
