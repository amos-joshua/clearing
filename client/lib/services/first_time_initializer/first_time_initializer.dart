import 'package:flutter/material.dart';

import '../../features/contacts/model/group.dart';
import '../../features/presets/model/enums.dart';
import '../../features/presets/model/preset.dart';
import '../../features/presets/model/schedule.dart';
import '../runtime_parameters/service.dart';
import '../storage/database.dart';

class FirstTimeInitializer {
  Future<void> init({
    required Database database,
    required RuntimeParameters runtimeParameters,
  }) async {
    final appSettings = database.appSettings();

    final familyAndFriends = ContactGroup(
      name: 'Family & Friends',
      catchAll: false,
    );
    final others = ContactGroup(
      name: ContactGroup.catchAllGroupName,
      catchAll: true,
    );

    if (appSettings.performedFirstTimeInit) {
      // Verify that we have an "Others" group
      final existingOthers = (await database.groups(
        '',
      )).where((group) => group.catchAll).firstOrNull;
      if (existingOthers == null) {
        await database.saveGroup(others);
      }
      return;
    }

    final allPresets = await database.presets();
    await database.saveGroup(familyAndFriends);
    await database.saveGroup(others);

    if (allPresets.length <= 1) {
      final nightSchedule = Schedule(
        days: Schedule.everyDay,
        startTime: const TimeOfDay(hour: 21, minute: 00),
        endTime: const TimeOfDay(hour: 08, minute: 00),
      );

      /*
      final workdaysSchedule = Schedule(
        days: Schedule.weekdays,
        startTime: const TimeOfDay(hour: 9, minute: 00),
        endTime: const TimeOfDay(hour: 17, minute: 00),
      );*/

      database.savePresetSync(
        Preset(name: 'Night')
          ..schedules.add(nightSchedule)
          ..settings.addAll([
            PresetSetting.forGroup(
              familyAndFriends,
              RingType.silent,
              RingType.silent,
              RingType.ring,
            ),
            /*
            PresetSetting.forGroup(
              friends,
              RingType.silent,
              RingType.silent,
              RingType.ring,
            ),*/
            PresetSetting.forGroup(
              others,
              RingType.silent,
              RingType.silent,
              RingType.silent,
            ),
          ]),
      );

      /*
      database.savePresetSync(
        Preset(name: 'Work')
          ..schedules.add(workdaysSchedule)
          ..settings.addAll([
            PresetSetting.forGroup(
              family,
              RingType.silent,
              RingType.vibrate,
              RingType.ring,
            ),
            PresetSetting.forGroup(
              friends,
              RingType.silent,
              RingType.vibrate,
              RingType.ring,
            ),
            PresetSetting.forGroup(
              others,
              RingType.silent,
              RingType.silent,
              RingType.silent,
            ),
          ]),
      );
      */

      database.savePresetSync(
        Preset(name: 'Busy')
          ..settings.addAll([
            PresetSetting.forGroup(
              familyAndFriends,
              RingType.silent,
              RingType.vibrate,
              RingType.ring,
            ),
            /*
            PresetSetting.forGroup(
              friends,
              RingType.silent,
              RingType.silent,
              RingType.vibrate,
            ),*/
            PresetSetting.forGroup(
              others,
              RingType.silent,
              RingType.silent,
              RingType.silent,
            ),
          ]),
      );

      appSettings.currentSchemaVersion = runtimeParameters.version;
      appSettings.performedFirstTimeInit = true;
      await database.saveAppSettings(appSettings);
    }
  }
}
