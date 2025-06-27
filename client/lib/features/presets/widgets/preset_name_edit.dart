import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../utils/widgets/editable_text.dart';
import '../bloc/cubit.dart';
import '../model/preset.dart';

class PresetNameEditField extends StatelessWidget {
  const PresetNameEditField({super.key});

  Future<String?> validate(
    Preset preset,
    BuildContext context,
    String newName,
  ) async {
    final presetsCubit = context.read<PresetsCubit>();
    if (newName.trim().isEmpty) {
      return 'Cannot be empty';
    }
    if ((newName != preset.name) &&
        await presetsCubit.hasPresetNamed(newName)) {
      return 'A preset with this name already exists';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final presetCubit = context.watch<PresetCubit>();
    final preset = presetCubit.state.preset;
    return EditableTitle(
      value: preset.name,
      validate: (context, newName) => validate(preset, context, newName),
      onConfirm: (newName) {
        presetCubit.updateName(newName);
      },
    );
  }
}
