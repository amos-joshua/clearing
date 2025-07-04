import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/call_event.dart';
import '../../bloc/outgoing_call_bloc.dart';
import '../../../model/call_event.dart' as events;

class OutgoingEventButtonBarWidget extends StatelessWidget {
  const OutgoingEventButtonBarWidget({super.key});

  Widget _buildEventButton(
    BuildContext context,
    String label,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(label),
    );
  }

  Widget _callInitButton(BuildContext context, CallUrgency urgency) {
    return _buildEventButton(
      context,
      'Init Call - ${urgency.name}',
      () => context.read<OutgoingCallBloc>().add(
        events.SenderCallInit(
          receiverPhoneNumbers: ['+15552345'],
          urgency: urgency,
          subject: 'Test',
          sdpOffer: '123',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _callInitButton(context, CallUrgency.leisure),
        _callInitButton(context, CallUrgency.important),
        _callInitButton(context, CallUrgency.urgent),
        _buildEventButton(
          context,
          'Hang Up',
          () =>
              context.read<OutgoingCallBloc>().add(const events.SenderHangUp()),
        ),
        _buildEventButton(
          context,
          'Receiver Ack',
          () => context.read<OutgoingCallBloc>().add(
            const events.ReceiverAck(clientTokenId: '123', sdpAnswer: '123'),
          ),
        ),
        _buildEventButton(
          context,
          'Reject',
          () => context.read<OutgoingCallBloc>().add(
            const events.ReceiverReject(clientTokenId: '123'),
          ),
        ),
        _buildEventButton(
          context,
          'Accept',
          () => context.read<OutgoingCallBloc>().add(
            events.ReceiverAccept(timestamp: DateTime.now().toIso8601String()),
          ),
        ),
        _buildEventButton(
          context,
          'Receiver Hang Up',
          () => context.read<OutgoingCallBloc>().add(
            const events.ReceiverHangUp(),
          ),
        ),
        _buildEventButton(
          context,
          'Timeout',
          () =>
              context.read<OutgoingCallBloc>().add(const events.CallTimeout()),
        ),
      ],
    );
  }
}
