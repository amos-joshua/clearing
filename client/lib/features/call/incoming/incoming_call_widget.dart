import 'package:clearing_client/features/call/call_urgency_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/call.dart';
import 'bloc/incoming_call_bloc.dart';
import 'bloc/incoming_call_state.dart';
import 'widgets/states/idle_call_widget.dart';
import 'widgets/states/ringing_call_widget.dart';
import 'widgets/states/ongoing_call_widget.dart';
import 'widgets/states/ended_call_widget.dart';
import 'widgets/states/rejected_call_widget.dart';
import 'widgets/states/unanswered_call_widget.dart';

class IncomingCallWidget extends StatelessWidget {
  const IncomingCallWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<IncomingCallBloc>();
    final call = context.watch<Call>();
    return Container(
      color: call.urgency.backgroundColor,
      width: double.infinity,
      child: switch (bloc.state) {
        IncomingCallStateIdle() => const IdleCallWidget(),
        IncomingCallStateRinging() => const RingingCallWidget(),
        IncomingCallStateOngoing() => const OngoingCallWidget(),
        IncomingCallStateEnded() => const EndedCallWidget(),
        IncomingCallStateRejected() => const RejectedCallWidget(),
        IncomingCallStateUnanswered() => const UnansweredCallWidget(),
      },
    );
  }
}
