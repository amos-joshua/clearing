import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/groups/widgets/widgets.dart';
import '../features/presets/bloc/cubit.dart';
import '../features/presets/widgets/active_preset_widgets.dart';
import '../features/settings/bloc/bloc.dart';


class GroupsListHomePage extends StatelessWidget {
  const GroupsListHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ActivePresetTitle(),
        Expanded(
          flex: 4,
          child: AppSettingsCubit.builder((context, appSettingsState) {
            final presetsCubit = context.watch<PresetsCubit>();
              return BlocProvider.value(
                value: presetsCubit.cubitFor(appSettingsState.activePresetData.preset),
                child: const GroupsList(
                  showPriorities: true,
                ),
              );
            }
          )
        ),
      ],
    );
  }
}