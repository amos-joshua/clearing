import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cubit.dart';
import '../model/preset.dart';
import 'preset_list_widgets.dart';

class PresetListTitle extends StatelessWidget {
  const PresetListTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final presetsCubit = context.read<PresetsCubit>();

    return ListTile(
      title: const Text('Profiles'),
      trailing: IconButton(
        icon: const Icon(Icons.add),
        onPressed: () async {
          final newPresetName = await presetsCubit.nextPresetName();
          final newPreset = Preset(name: newPresetName);
          presetsCubit.save(newPreset);
        },
      ),
    );
  }
}

class PresetsListWithAddButton extends StatelessWidget {
  const PresetsListWithAddButton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PresetListTitle(),
        Expanded(child: PresetsList()),
      ],
    );
  }
}
