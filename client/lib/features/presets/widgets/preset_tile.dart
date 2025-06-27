import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../settings/bloc/bloc.dart';
import '../bloc/cubit.dart';

class PresetTile extends StatelessWidget {
  const PresetTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppSettingsCubit.builder((context, appSettingsState) {
      return PresetCubit.builder((context, presetState) {
        final presetCubit = context.read<PresetCubit>();
        final preset = presetState.preset;

        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: const Icon(Icons.list),
            title: Text(preset.name),
            trailing: preset.isDefault
                ? Text('default', style: theme.textTheme.bodySmall)
                : null,
            onTap: () async {
              presetCubit.syncSettingsWithGroups();
              if (context.mounted) {
                context.push('/preset_detail', extra: presetCubit);
              }
            },
          ),
        );
      });
    });
  }
}
