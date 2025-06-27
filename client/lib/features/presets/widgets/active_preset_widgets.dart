import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/storage/database.dart';
import '../../../utils/dialogs.dart';
import '../../settings/bloc/bloc.dart';
import '../model/preset.dart';

class ActivePresetTitle extends StatelessWidget {
  const ActivePresetTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appSettings = context.watch<AppSettingsCubit>();
    final activePresetData = appSettings.state.activePresetData;
    final endTime = TimeOfDay.fromDateTime(activePresetData.endTime);
    return ListTile(
      title: Text(
        activePresetData.preset.name,
        style: theme.textTheme.titleLarge,
      ),
      trailing: !activePresetData.isOverride
          ? null
          : IconButton(
              onPressed: () async {
                final confirmed = await ConfirmDialog(
                  context,
                ).show(title: "Cancel '${activePresetData.preset.name}'?");
                if (confirmed) {
                  appSettings.clearOverridePreset();
                }
              },
              icon: const Icon(Icons.cancel),
            ),
      subtitle: activePresetData.preset.isDefault
          ? null
          : Text('Until ${endTime.format(context)}'),
    );
  }
}

class PresetOverridePopupButton extends StatelessWidget {
  static const _icon = Icon(Icons.more_time_outlined);
  const PresetOverridePopupButton({super.key});

  @override
  Widget build(BuildContext context) {
    final presetsFuture = context.read<Database>().presets();

    return FutureBuilder(
      future: presetsFuture,
      builder: (context, snapshot) {
        final appSettingsCubit = context.read<AppSettingsCubit>();

        final presets = snapshot.data;
        if (presets == null) {
          return const IconButton(icon: _icon, onPressed: null);
        }
        return PopupMenuButton<Preset>(
          itemBuilder: (context) => presets
              .map(
                (preset) => PopupMenuItem(
                  value: preset,
                  child: ListTile(
                    leading: const Icon(Icons.list),
                    title: Text(preset.name),
                  ),
                ),
              )
              .toList(),
          onSelected: (preset) async {
            final duration = await DurationSelectDialog(
              context,
            ).show(title: 'Set to ${preset.name} for...');
            if (duration == null) return;
            if (context.mounted) {
              appSettingsCubit.overridePreset(preset, duration);
            }
          },
          icon: _icon,
        );
      },
    );
  }
}
