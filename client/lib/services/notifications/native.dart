import 'package:flutter/services.dart';

import '../../features/call/model/call_event.dart';
import '../../features/presets/model/enums.dart';
import '../storage/database.dart';

class NativeNotifications {
  late final bool hasNotificationPolicyAccessPermissions;

  final methodChannel = const MethodChannel(
    'net.swiftllama.clearing_client/notifications',
  );
  final Database database;

  NativeNotifications({required this.database});

  Future<void> init() async {
    hasNotificationPolicyAccessPermissions = await hasPermissions();
    /*
    if (!hasNotificationPolicyAccessPermissions) {
      await requestPermissions();
      hasNotificationPolicyAccessPermissions = await hasPermissions();
    }*/
  }

  Future<bool> requestPermissions() async {
    return await methodChannel.invokeMethod<bool>(
          'requestAccessNotificationPolicyPermissions',
        ) ??
        false;
  }

  Future<bool> hasPermissions() async {
    return await methodChannel.invokeMethod<bool>(
          'hasAccessNotificationPolicyPermissions',
        ) ??
        false;
  }

  Future<void> showCallNotification(
    String callUuid,
    String displayName,
    String subject,
    CallUrgency urgency,
    RingType ringType,
  ) async {
    return await methodChannel.invokeMethod('showCallNotification', [
      callUuid,
      displayName,
      subject,
      urgency.index,
      ringType.index,
    ]);
  }

  Future<void> cancelCallNotification(String callUuid) async {
    return await methodChannel.invokeMethod('cancelCallNotification', [
      callUuid,
      '',
      '',
      0,
      0,
    ]);
  }

  Future<void> showMissedCallNotification(
    String callUuid,
    String displayName,
    String subject,
    CallUrgency urgency,
    RingType ringType,
  ) async {
    return await methodChannel.invokeMethod('showMissedCallNotification', [
      callUuid,
      displayName,
      subject,
      urgency.index,
      ringType.index,
    ]);
  }
}
