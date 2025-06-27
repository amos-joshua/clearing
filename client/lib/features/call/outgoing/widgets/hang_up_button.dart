import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/outgoing_call_bloc.dart';
import '../../model/call_event.dart';
import '../../widgets/call_action_button.dart';

class HangUpButton extends StatelessWidget {
  const HangUpButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CallActionButton(
      onPressed: () {
        context.read<OutgoingCallBloc>().add(const SenderHangUp());
      },
      icon: Icons.call_end,
      label: 'End call',
      backgroundColor: Colors.red,
    );
  }
}
