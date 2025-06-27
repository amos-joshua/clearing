import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../logging/logging_service.dart';

class RuntimeParameters {
  String version = 'n/a';
  String supportDirectory = '/tmp';
  String phoneModel = '(unknown)';
  String osVersion = 'n/a';
}

class RuntimeParametersService {
  final runtimeParameters = RuntimeParameters();

  Future<void> init({required LoggingService logger}) async {
    final packageInfo = await PackageInfo.fromPlatform();

    runtimeParameters.version = packageInfo.version;

    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      runtimeParameters.phoneModel =
          '${deviceInfo.brand} (${deviceInfo.model})';
      runtimeParameters.osVersion = deviceInfo.version.release;
    } else {
      logger.error(
        'Skipping runtime parameter init for phone model and os version on unexpected platform ${Platform.operatingSystem}',
      );
    }

    final supportDirectory = await getApplicationSupportDirectory();
    runtimeParameters.supportDirectory = supportDirectory.path;
  }
}
