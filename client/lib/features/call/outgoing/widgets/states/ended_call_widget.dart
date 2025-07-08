import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../widgets/dismiss_call_button.dart';
import '../../bloc/outgoing_call_bloc.dart';
import '../../bloc/outgoing_call_state.dart';
import '../call_header_widget.dart';

class EndedCallWidget extends StatelessWidget {
  const EndedCallWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final outgoingCallBloc = context.watch<OutgoingCallBloc>();
    final state = outgoingCallBloc.state;
    final error = state is OutgoingCallStateEnded ? state.error : null;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutgoingCallHeaderWidget(
          stateIcon: Icons.call_end,
          iconColor: Colors.red.shade300,
          stateText: 'Call Ended',
        ),
        const SizedBox(height: 20),
        if (error != null)
          switch (error.reason) {
            'RecipientNotRegistered' => const Text(
              "Recipient doesn't have ClearRing installed",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            _ => Text(
              "${error.reason}: ${error.error}",
              style: const TextStyle(color: Colors.red),
            ),
          },
        const SizedBox(height: 20),
        const DismissCallButton(),
      ],
    );
  }
}
