import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/incoming_call_bloc.dart';
import '../../../model/call_event.dart';
import '../call_header_widget.dart';
import '../../../widgets/call_action_button.dart';

class RingingCallWidget extends StatelessWidget {
  const RingingCallWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const IncomingCallHeaderWidget(
          stateIcon: Icons.phone_in_talk,
          iconColor: Colors.blue,
          stateText: 'Incoming Call',
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CallActionButton(
              onPressed: () {
                context.read<IncomingCallBloc>().add(
                  ReceiverAccept(timestamp: DateTime.now().toIso8601String()),
                );
              },
              icon: Icons.phone,
              label: 'Accept',
              backgroundColor: Colors.green,
            ),
            const SizedBox(width: 20),
            CallActionButton(
              onPressed: () {
                context.read<IncomingCallBloc>().add(
                  const ReceiverReject(clientTokenId: '123'),
                );
              },
              icon: Icons.phone_disabled,
              label: 'Reject',
              backgroundColor: Colors.red,
            ),
          ],
        ),
      ],
    );
  }
}
