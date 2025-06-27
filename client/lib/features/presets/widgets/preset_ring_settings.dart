import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../call/call_urgency_colors.dart';
import '../../call/model/call_event.dart';
import '../bloc/cubit.dart';
import '../model/enums.dart';

class PresetSettingRingButton extends StatelessWidget {
  final CallUrgency urgency;
  final bool readonly;

  const PresetSettingRingButton({
    required this.urgency,
    required this.readonly,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final settingCubit = context.watch<PresetSettingCubit>();
    final setting = settingCubit.state.presetSetting;
    final ringType = setting.ringTypeFor(urgency);

    return InkWell(
      onTap: readonly
          ? null
          : () {
              settingCubit.setRingTypeFor(
                urgency,
                ringType: ringType.nextRingType,
              );
            },
      child: Card(
        color: ringType != RingType.silent
            ? urgency.backgroundColor
            : Colors.grey.shade400,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(ringType.icon, color: Colors.white),
        ),
      ),
    );
  }
}

class PresetSettingRingSummary extends StatelessWidget {
  final bool readonly;
  const PresetSettingRingSummary({required this.readonly, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PresetSettingRingButton(
            urgency: CallUrgency.leisure,
            readonly: readonly,
          ),
        ),
        Expanded(
          child: PresetSettingRingButton(
            urgency: CallUrgency.important,
            readonly: readonly,
          ),
        ),
        Expanded(
          child: PresetSettingRingButton(
            urgency: CallUrgency.urgent,
            readonly: readonly,
          ),
        ),
      ],
    );
  }
}
