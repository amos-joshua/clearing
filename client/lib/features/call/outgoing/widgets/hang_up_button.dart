import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../incoming/bloc/incoming_call_bloc.dart';
import '../bloc/outgoing_call_bloc.dart';
import '../../model/call_event.dart';
import '../../widgets/call_action_button.dart';

class HangUpButton extends StatelessWidget {
  final bool isOutgoing;
  const HangUpButton({super.key, required this.isOutgoing});

  @override
  Widget build(BuildContext context) {
    return CallActionButton(
      onPressed: () {
        if (isOutgoing) {
          context.read<OutgoingCallBloc>().add(const SenderHangUp());
        } else {
          context.read<IncomingCallBloc>().add(const ReceiverHangUp());
        }
      },
      icon: Icons.call_end,
      label: 'End call',
      backgroundColor: Colors.red,
    );
  }
}
