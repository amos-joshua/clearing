import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/notifications/native.dart';
import '../../../services/storage/database.dart';
import '../../../services/storage/db_events.dart';
import '../../call/model/call_event.dart';
import '../../contacts/model/group.dart';
import '../model/enums.dart';
import '../model/preset.dart';
import '../model/schedule.dart';
import 'state.dart';

class PresetsCubit extends Cubit<PresetsState> {
  final Database database;
  final NativeNotifications nativeNotifications;
  final _cubits = <int, PresetCubit>{};
  StreamSubscription<DBEvent>? _eventSubscription;

  PresetsCubit({required this.database, required this.nativeNotifications})
    : super(const PresetsState()) {
    _eventSubscription = database.events.listen(onDBEvent);
  }

  @override
  Future<void> close() async {
    await _eventSubscription?.cancel();
    _eventSubscription = null;
    super.close();
  }

  void onDBEvent(DBEvent event) {
    if (event is DBEventGroupRemoved) {
      removePresetSettingsForGroup(event.group);
      presetsModified();
    }
    if (event is DBEventGroupAdded) {
      addPresetSettingsForGroup(event.group);
      presetsModified();
    }
    if (event is DBEventGroupModified || event is DBEventPresetModified) {
      presetsModified();
    }
  }

  Future<void> presetsModified() async {
    //nativeNotifications.updatePresets();
  }

  Future<void> list() async {
    emit(state.copyWith(loading: true));
    final presets = await database.presets();
    emit(state.copyWith(loading: false, presets: _sort(presets)));
  }

  Future<void> save(Preset preset) async {
    emit(state.copyWith(loading: true));
    database.savePresetSync(preset);
    final exists = state.presets.any((existing) => existing.id == preset.id);
    if (exists) {
      emit(state.copyWith(loading: false, presets: _sort(state.presets)));
    } else {
      emit(
        state.copyWith(
          presets: _sort([...state.presets, preset]),
          loading: false,
        ),
      );
    }
    unawaited(presetsModified());
  }

  Future<void> remove(Preset preset) async {
    await database.removePreset(preset);
    emit(
      state.copyWith(
        presets: state.presets
            .where((existing) => existing.id != preset.id)
            .toList(),
      ),
    );
    unawaited(presetsModified());
  }

  Future<void> removePresetSettingsForGroup(ContactGroup group) async {
    final presets = await database.presets();
    for (final preset in presets) {
      final badSettings = <PresetSetting>[];
      for (final setting in preset.settings) {
        if (setting.group.targetId == group.id) {
          badSettings.add(setting);
        }
      }
      badSettings.forEach(preset.settings.remove);
      badSettings.forEach(database.removePresetSetting);
      database.savePresetSync(preset);
    }
  }

  Future<void> addPresetSettingsForGroup(ContactGroup group) async {
    final presets = await database.presets();
    for (final preset in presets) {
      if (!preset.settings.any(
        (setting) => setting.group.targetId == group.id,
      )) {
        final existingSetting = preset.settings.lastOrNull;
        final newPreset = PresetSetting()..group.target = group;
        if (existingSetting != null) {
          newPreset.leisureRingType = existingSetting.leisureRingType;
          newPreset.importantRingType = existingSetting.importantRingType;
          newPreset.urgentRingType = existingSetting.urgentRingType;
        }
        preset.settings.add(newPreset);
        database.savePresetSync(preset);
      }
    }
  }

  PresetCubit cubitFor(Preset preset) {
    final existingCubit = _cubits[preset.id];
    if (existingCubit != null) return existingCubit;
    final cubit = PresetCubit(preset, database: database);
    _cubits[preset.id] = cubit;
    return cubit;
  }

  List<Preset> _sort(List<Preset> presets) {
    presets.sort((a, b) => a.name.compareTo(b.name));
    return presets;
  }

  Future<String> nextPresetName() => database.nextPresetName();

  Future<bool> hasPresetNamed(String name) => database.hasPresetNamed(name);
}

class PresetSettingCubit extends Cubit<PresetSettingState> {
  final Database database;
  //final PresetsCubit presetsCubit;

  final Preset preset;
  PresetSettingCubit(
    this.preset,
    PresetSetting presetSetting, {
    required this.database,
    //required this.presetsCubit,
  }) : super(PresetSettingState(presetSetting, ringTypesNonce: 0));

  void setRingTypeFor(CallUrgency urgency, {required RingType ringType}) {
    state.presetSetting.setRingTypeFor(urgency, ringType: ringType);
    database.savePresetSync(preset);
    emit(state.copyWith(ringTypesNonce: state.ringTypesNonce + 1));
  }
}

class PresetCubit extends Cubit<PresetState> {
  final Database database;
  final _presetSettingCubits = <int, PresetSettingCubit>{};

  PresetCubit(Preset preset, {required this.database})
    : super(PresetState(preset: preset));

  void updateName(String name) {
    state.preset.name = name;
    database.savePresetSync(state.preset);
    emit(state.copyWith(nameNonce: state.nameNonce + 1));
  }

  void addSchedule() {
    state.preset.schedules.add(Schedule(days: [1, 2, 3, 4, 5, 6, 7]));
    database.savePresetSync(state.preset);
    emit(state.copyWith(schedulesNonce: state.schedulesNonce + 1));
  }

  void removeSchedule(Schedule schedule) {
    state.preset.schedules.removeWhere((other) => other.id == schedule.id);
    database.savePresetSync(state.preset);
    emit(state.copyWith(schedulesNonce: state.schedulesNonce + 1));
  }

  void syncSettingsWithGroups() {
    database.syncSettingsWithGroups(state.preset);
    emit(state.copyWith(settingsNonce: state.settingsNonce + 1));
  }

  PresetSetting _newSettingForGroup(ContactGroup group) {
    final newSetting = PresetSetting()..group.target = group;
    state.preset.settings.add(newSetting);
    database.savePresetSync(state.preset);
    return newSetting;
  }

  PresetSetting settingForGroup(ContactGroup group) {
    return state.preset.settingForGroup(group) ?? _newSettingForGroup(group);
  }

  PresetSettingCubit presetSettingCubitFor(ContactGroup group) {
    final setting = settingForGroup(group);
    final existingCubit = _presetSettingCubits[setting.id];
    if (existingCubit != null) return existingCubit;
    final cubit = PresetSettingCubit(state.preset, setting, database: database);
    _presetSettingCubits[setting.id] = cubit;
    return cubit;
  }

  static BlocBuilder builder(
    Widget Function(BuildContext, PresetState) cubitBuilder,
  ) => BlocBuilder<PresetCubit, PresetState>(builder: cubitBuilder);
}
