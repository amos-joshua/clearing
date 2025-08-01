import 'package:freezed_annotation/freezed_annotation.dart';

part 'call_event.freezed.dart';
part 'call_event.g.dart';

enum CallEventType {
  @JsonValue('sender_call_init')
  senderCallInit,
  @JsonValue('turn_servers')
  turnServers,
  @JsonValue('sender_authorize')
  senderAuthorize,
  @JsonValue('sender_ice_candidates')
  senderIceCandidates,
  @JsonValue('sender_hang_up')
  senderHangUp,
  @JsonValue('sender_disconnected')
  senderDisconnected,
  @JsonValue('receiver_ack')
  receiverAck,
  @JsonValue('receiver_hang_up')
  receiverHangUp,
  @JsonValue('receiver_reject')
  receiverReject,
  @JsonValue('receiver_accept')
  receiverAccept,
  @JsonValue('receiver_disconnected')
  receiverDisconnected,
  @JsonValue('call_timeout')
  callTimeout,
  @JsonValue('incoming_call_init')
  incomingCallInit,
  @JsonValue('error')
  error,
}

enum CallUrgency {
  @JsonValue('leisure')
  leisure,
  @JsonValue('important')
  important,
  @JsonValue('urgent')
  urgent,
}

@Freezed(unionKey: 'call_event', unionValueCase: FreezedUnionCase.snake)
abstract class CallEvent with _$CallEvent {
  const factory CallEvent.senderAuthorize({
    @JsonKey(name: 'client_token_id') required String clientTokenId,
  }) = SenderAuthorize;

  const factory CallEvent.turnServers({
    @JsonKey(name: 'turn_servers')
    required List<Map<String, dynamic>> turnServers,
  }) = TurnServers;

  const factory CallEvent.senderCallInit({
    @JsonKey(name: 'receiver_phone_numbers')
    required List<String> receiverPhoneNumbers,
    required CallUrgency urgency,
    required String subject,
    @JsonKey(name: 'sdp_offer') required String sdpOffer,
  }) = SenderCallInit;

  const factory CallEvent.senderIceCandidates({
    @JsonKey(name: 'ice_candidates') required List<String> iceCandidates,
  }) = SenderIceCandidates;

  const factory CallEvent.senderHangUp() = SenderHangUp;

  const factory CallEvent.senderDisconnected() = SenderDisconnected;

  const factory CallEvent.incomingCallInit({
    @JsonKey(name: 'call_uuid') required String callUuid,
    @JsonKey(name: 'caller_display_name') required String callerDisplayName,
    @JsonKey(name: 'caller_phone_number') required String callerPhoneNumber,
    required CallUrgency urgency,
    required String subject,
    @JsonKey(name: 'sdp_offer') required String sdpOffer,
    @JsonKey(name: 'turn_servers')
    required List<Map<String, dynamic>> turnServers,
  }) = IncomingCallInit;

  const factory CallEvent.receiverAck({
    @JsonKey(name: 'client_token_id') required String clientTokenId,
    @JsonKey(name: 'sdp_answer') required String sdpAnswer,
  }) = ReceiverAck;

  const factory CallEvent.receiverAccept({
    @JsonKey(name: 'timestamp') required String timestamp,
  }) = ReceiverAccept;

  const factory CallEvent.receiverReject({
    @JsonKey(name: 'client_token_id') required String clientTokenId,
    @Default('') String reason,
  }) = ReceiverReject;

  const factory CallEvent.receiverDisconnected() = ReceiverDisconnected;

  const factory CallEvent.callTimeout() = CallTimeout;

  const factory CallEvent.receiverHangUp() = ReceiverHangUp;

  const factory CallEvent.error({
    @JsonKey(name: 'error_code') required String errorCode,
    @JsonKey(name: 'error_message') required String errorMessage,
  }) = CallError;

  factory CallEvent.fromJson(Map<String, dynamic> json) =>
      _$CallEventFromJson(json);
}

extension ReceiverAcceptExtension on ReceiverAccept {
  (DateTime, String?) parseTimestamp() {
    try {
      return (DateTime.parse(timestamp), null);
    } catch (e) {
      return (DateTime.now(), e.toString());
    }
  }
}
