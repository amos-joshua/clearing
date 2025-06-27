import 'package:equatable/equatable.dart';

import '../../presets/model/preset.dart';
import '../model/app_settings.dart';

class AppSettingsState extends Equatable {
  final AppSettings appSettings;
  final ActivePresetData activePresetData;
  final int activePresetNonce;
  final int notificationPolicyAccessAllowedNonce;
  final int developerSettingsNonce;

  const AppSettingsState(
    this.appSettings, {
    required this.activePresetData,
    this.activePresetNonce = 0,
    this.notificationPolicyAccessAllowedNonce = 0,
    this.developerSettingsNonce = 0,
  });

  AppSettingsState copyWith({
    ActivePresetData? activePresetData,
    int? notificationPolicyAccessAllowedNonce,
    int? activePresetNonce,
    int? developerSettingsNonce,
  }) => AppSettingsState(
    appSettings,
    activePresetData: activePresetData ?? this.activePresetData,
    notificationPolicyAccessAllowedNonce:
        notificationPolicyAccessAllowedNonce ??
        this.notificationPolicyAccessAllowedNonce,
    activePresetNonce: activePresetNonce ?? this.activePresetNonce,
    developerSettingsNonce: developerSettingsNonce ?? this.developerSettingsNonce,
  );

  @override
  List<Object> get props => [
    appSettings,
    activePresetData.preset.id,
    activePresetNonce,
    notificationPolicyAccessAllowedNonce,
    developerSettingsNonce,
  ];
}
