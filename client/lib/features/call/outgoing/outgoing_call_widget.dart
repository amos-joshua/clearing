import 'package:clearing_client/features/call/call_urgency_colors.dart';
import 'package:clearing_client/features/call/model/call.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/outgoing_call_bloc.dart';
import 'bloc/outgoing_call_state.dart';
import 'widgets/states/idle_call_widget.dart';
import 'widgets/states/calling_call_widget.dart';
import 'widgets/states/ringing_call_widget.dart';
import 'widgets/states/ongoing_call_widget.dart';
import 'widgets/states/unanswered_call_widget.dart';
import 'widgets/states/rejected_call_widget.dart';
import 'widgets/states/ended_call_widget.dart';

class OutgoingCallWidget extends StatelessWidget {
  const OutgoingCallWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<OutgoingCallBloc>();
    final call = context.read<Call>();
    return Container(
      width: double.infinity,
      color: call.urgency.backgroundColor,
      child: switch (bloc.state) {
        OutgoingCallStateIdle() => const IdleCallWidget(),
        OutgoingCallStateAuthorized() => const CallingCallWidget(),
        OutgoingCallStateCalling() => const CallingCallWidget(),
        OutgoingCallStateRinging() => const RingingCallWidget(),
        OutgoingCallStateOngoing() => const OngoingCallWidget(),
        OutgoingCallStateUnanswered() => const UnansweredCallWidget(),
        OutgoingCallStateRejected() => const RejectedCallWidget(),
        OutgoingCallStateEnded() => const EndedCallWidget(),
      },
    );
  }
}
