import 'package:objectbox/objectbox.dart';
import '../../presets/model/preset.dart';

@Entity()
class AppSettings {
  @Id()
  int id;

  bool hasNotificationPolicyAccessPermissions;
  bool hasReceivePushNotificationsPermissions;
  bool performedFirstTimeInit;
  String currentSchemaVersion;
  bool isDeveloper;
  bool enableServersideDebug;
  bool disableWebRTC;

  final presetOverride = ToOne<Preset>();

  @Transient()
  DateTime presetOverrideStart = DateTime(0);
  int get dbPresetOverrideStart => presetOverrideStart.millisecondsSinceEpoch;
  set dbPresetOverrideStart(int value) {
    presetOverrideStart = DateTime.fromMillisecondsSinceEpoch(
      value,
      isUtc: true,
    );
  }

  @Transient()
  DateTime presetOverrideEnd = DateTime(0);
  int get dbPresetOverrideEnd => presetOverrideEnd.millisecondsSinceEpoch;
  set dbPresetOverrideEnd(int value) {
    presetOverrideEnd = DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
  }

  AppSettings({
    this.id = 0,
    this.hasNotificationPolicyAccessPermissions = false,
    this.hasReceivePushNotificationsPermissions = false,
    this.performedFirstTimeInit = false,
    this.currentSchemaVersion = '',
    this.isDeveloper = false,
    this.enableServersideDebug = false,
    this.disableWebRTC = false,
  });

  @override
  String toString() =>
      'AppSetting($id, hasReceivedPushNotificationsPermissions: $hasReceivePushNotificationsPermissions, hasNotificationsReadPermissions: $hasNotificationPolicyAccessPermissions, presetOverride: ${presetOverride.target?.name} from ${presetOverrideStart.toIso8601String()} to ${presetOverrideEnd.toIso8601String()})';
}
