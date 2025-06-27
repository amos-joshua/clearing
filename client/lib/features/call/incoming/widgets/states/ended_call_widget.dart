import 'package:clearing_client/features/call/incoming/widgets/call_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../widgets/dismiss_call_button.dart';
import '../../bloc/incoming_call_bloc.dart';
import '../../bloc/incoming_call_state.dart';

class EndedCallWidget extends StatelessWidget {
  const EndedCallWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<IncomingCallBloc>().state;
    final error = state is IncomingCallStateEnded ? state.error : null;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const IncomingCallHeaderWidget(
          stateIcon: Icons.call_end,
          iconColor: Colors.red,
          stateText: 'Call Ended',
        ),
        const SizedBox(height: 20),
        if (error != null)
          Text(error, style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 20),
        const DismissCallButton(),
      ],
    );
  }
}
