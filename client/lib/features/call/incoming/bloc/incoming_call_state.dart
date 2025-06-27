import 'package:freezed_annotation/freezed_annotation.dart';

part 'incoming_call_state.freezed.dart';

@freezed
sealed class IncomingCallState with _$IncomingCallState {
  const IncomingCallState._(); // Private constructor for base class fields

  const factory IncomingCallState.idle() = IncomingCallStateIdle;

  const factory IncomingCallState.ringing() = IncomingCallStateRinging;

  const factory IncomingCallState.ongoing({required DateTime startedAt}) =
      IncomingCallStateOngoing;

  const factory IncomingCallState.unanswered() = IncomingCallStateUnanswered;

  const factory IncomingCallState.rejected() = IncomingCallStateRejected;

  const factory IncomingCallState.ended({String? error}) =
      IncomingCallStateEnded;
}
