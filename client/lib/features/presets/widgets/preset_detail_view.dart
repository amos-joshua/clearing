import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../groups/groups.dart';
import '../../schedules/widgets/widgets.dart';
import '../bloc/cubit.dart';
import '../model/preset.dart';
import '../model/schedule.dart';
import 'preset_name_edit.dart';

class PresetDetailView extends StatelessWidget {
  const PresetDetailView({super.key});

  Iterable<Widget> scheduleTiles(List<Schedule> schedules) => schedules.map(
    (schedule) =>
        ScheduleTile(schedule, key: ValueKey('schedule_${schedule.id}')),
  );

  Iterable<Widget> presetSettingTiles(GroupsCubit groupsCubit, Preset preset) =>
      preset.settings.map(
        (setting) => Builder(
          builder: (context) {
            final group = setting.group.target;
            if (group == null) {
              return Text('unknown Group with id ${setting.group.targetId}');
            }
            return BlocProvider<GroupCubit>.value(
              value: groupsCubit.cubitFor(group),
              child: const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: GroupTilePriorities(readonly: false),
              ),
            );
          },
        ),
      );

  Widget schedulesTitle(PresetCubit presetCubit) => ListTile(
    title: const Text('Schedule'),
    trailing: IconButton(
      icon: const Icon(Icons.add),
      onPressed: () {
        presetCubit.addSchedule();
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return PresetCubit.builder((context, state) {
      final presetCubit = context.read<PresetCubit>();
      final groupsCubit = context.watch<GroupsCubit>();
      final schedules = presetCubit.state.preset.schedules;

      return ListView(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: PresetNameEditField(),
          ),
          const SizedBox(height: 16.0),
          ...presetSettingTiles(groupsCubit, state.preset),
          schedulesTitle(presetCubit),
          if (schedules.isEmpty)
            const Center(
              child: Text('(none)', style: TextStyle(color: Colors.blueGrey)),
            )
          else
            ...scheduleTiles(schedules),
        ],
      );
    });
  }
}
