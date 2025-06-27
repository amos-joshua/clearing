import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../settings/bloc/bloc.dart';
import '../bloc/cubit.dart';
import '../bloc/state.dart';
import 'preset_tile.dart';

class PresetsList extends StatelessWidget {
  const PresetsList({super.key});

  Widget loadingSpinner() => const Center(child: CircularProgressIndicator());

  Widget listView(PresetsState state) => ListView.builder(
    itemCount: state.presets.length,
    itemBuilder: (context, index) {
      final presetsCubit = context.read<PresetsCubit>();
      final preset = state.presets[index];
      return BlocProvider.value(
        value: presetsCubit.cubitFor(preset),
        child: Builder(
          builder: (context) {
            return PresetTile(
              key: ValueKey('preset_${preset.name}_${preset.id}'),
            );
          },
        ),
      );
    },
  );

  Widget emptyList() => const Center(
    child: Text('(none)', style: TextStyle(color: Colors.black45)),
  );

  @override
  Widget build(BuildContext context) => BlocBuilder<PresetsCubit, PresetsState>(
    builder: (context, state) {
      return state.loading
          ? loadingSpinner()
          : state.presets.isEmpty
          ? emptyList()
          : listView(state);
    },
  );
}
