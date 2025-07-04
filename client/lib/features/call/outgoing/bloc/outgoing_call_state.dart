import 'package:freezed_annotation/freezed_annotation.dart';

part 'outgoing_call_state.freezed.dart';

@freezed
sealed class OutgoingCallState with _$OutgoingCallState {
  const OutgoingCallState._(); // Private constructor for base class fields

  const factory OutgoingCallState.idle() = OutgoingCallStateIdle;

  const factory OutgoingCallState.authorized() = OutgoingCallStateAuthorized;

  const factory OutgoingCallState.calling() = OutgoingCallStateCalling;

  const factory OutgoingCallState.ringing() = OutgoingCallStateRinging;

  const factory OutgoingCallState.ongoing({required DateTime startedAt}) =
      OutgoingCallStateOngoing;

  const factory OutgoingCallState.unanswered() = OutgoingCallStateUnanswered;

  const factory OutgoingCallState.rejected() = OutgoingCallStateRejected;

  const factory OutgoingCallState.ended({String? error}) =
      OutgoingCallStateEnded;
}
