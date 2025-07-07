import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/incoming_call_bloc.dart';
import '../../../model/call_event.dart';

class IncomingEventButtonBarWidget extends StatelessWidget {
  const IncomingEventButtonBarWidget({super.key});

  Widget incomingCallInitButton(
    BuildContext context, {
    required CallUrgency urgency,
  }) {
    return ElevatedButton(
      onPressed: () {
        context.read<IncomingCallBloc>().add(
          IncomingCallInit(
            callUuid: '123',
            subject: 'Test Subject',
            urgency: urgency,
            callerDisplayName: 'Test Sender',
            callerPhoneNumber: '+15552345',
            sdpOffer: 'Test SDP Offer',
            turnServers: [],
          ),
        );
      },
      child: Text('Incoming Call - ${urgency.name}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          incomingCallInitButton(context, urgency: CallUrgency.leisure),
          incomingCallInitButton(context, urgency: CallUrgency.important),
          incomingCallInitButton(context, urgency: CallUrgency.urgent),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              context.read<IncomingCallBloc>().add(
                const ReceiverAck(clientTokenId: '123', sdpAnswer: '123'),
              );
            },
            child: const Text('Receiver Ack'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              context.read<IncomingCallBloc>().add(
                const ReceiverReject(clientTokenId: '123'),
              );
            },
            child: const Text('Receiver Reject'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              context.read<IncomingCallBloc>().add(
                ReceiverAccept(timestamp: DateTime.now().toIso8601String()),
              );
            },
            child: const Text('Receiver Accept'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              context.read<IncomingCallBloc>().add(const SenderHangUp());
            },
            child: const Text('Sender Hang Up'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              context.read<IncomingCallBloc>().add(const CallTimeout());
            },
            child: const Text('Call Timeout'),
          ),
        ],
      ),
    );
  }
}
