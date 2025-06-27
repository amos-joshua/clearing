// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SenderCallInit _$SenderCallInitFromJson(Map<String, dynamic> json) =>
    SenderCallInit(
      clientTokenId: json['client_token_id'] as String,
      receiverEmails: (json['receiver_emails'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      urgency: $enumDecode(_$CallUrgencyEnumMap, json['urgency']),
      subject: json['subject'] as String,
      sdpOffer: json['sdp_offer'] as String,
      $type: json['call_event'] as String?,
    );

Map<String, dynamic> _$SenderCallInitToJson(SenderCallInit instance) =>
    <String, dynamic>{
      'client_token_id': instance.clientTokenId,
      'receiver_emails': instance.receiverEmails,
      'urgency': _$CallUrgencyEnumMap[instance.urgency]!,
      'subject': instance.subject,
      'sdp_offer': instance.sdpOffer,
      'call_event': instance.$type,
    };

const _$CallUrgencyEnumMap = {
  CallUrgency.leisure: 'leisure',
  CallUrgency.important: 'important',
  CallUrgency.urgent: 'urgent',
};

SenderIceCandidates _$SenderIceCandidatesFromJson(Map<String, dynamic> json) =>
    SenderIceCandidates(
      iceCandidates: (json['ice_candidates'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      $type: json['call_event'] as String?,
    );

Map<String, dynamic> _$SenderIceCandidatesToJson(
  SenderIceCandidates instance,
) => <String, dynamic>{
  'ice_candidates': instance.iceCandidates,
  'call_event': instance.$type,
};

SenderHangUp _$SenderHangUpFromJson(Map<String, dynamic> json) =>
    SenderHangUp($type: json['call_event'] as String?);

Map<String, dynamic> _$SenderHangUpToJson(SenderHangUp instance) =>
    <String, dynamic>{'call_event': instance.$type};

SenderDisconnected _$SenderDisconnectedFromJson(Map<String, dynamic> json) =>
    SenderDisconnected($type: json['call_event'] as String?);

Map<String, dynamic> _$SenderDisconnectedToJson(SenderDisconnected instance) =>
    <String, dynamic>{'call_event': instance.$type};

IncomingCallInit _$IncomingCallInitFromJson(Map<String, dynamic> json) =>
    IncomingCallInit(
      callUuid: json['call_uuid'] as String,
      callerDisplayName: json['caller_display_name'] as String,
      callerEmail: json['caller_email'] as String,
      urgency: $enumDecode(_$CallUrgencyEnumMap, json['urgency']),
      subject: json['subject'] as String,
      sdpOffer: json['sdp_offer'] as String,
      $type: json['call_event'] as String?,
    );

Map<String, dynamic> _$IncomingCallInitToJson(IncomingCallInit instance) =>
    <String, dynamic>{
      'call_uuid': instance.callUuid,
      'caller_display_name': instance.callerDisplayName,
      'caller_email': instance.callerEmail,
      'urgency': _$CallUrgencyEnumMap[instance.urgency]!,
      'subject': instance.subject,
      'sdp_offer': instance.sdpOffer,
      'call_event': instance.$type,
    };

ReceiverAck _$ReceiverAckFromJson(Map<String, dynamic> json) => ReceiverAck(
  clientTokenId: json['client_token_id'] as String,
  sdpAnswer: json['sdp_answer'] as String,
  $type: json['call_event'] as String?,
);

Map<String, dynamic> _$ReceiverAckToJson(ReceiverAck instance) =>
    <String, dynamic>{
      'client_token_id': instance.clientTokenId,
      'sdp_answer': instance.sdpAnswer,
      'call_event': instance.$type,
    };

ReceiverAccept _$ReceiverAcceptFromJson(Map<String, dynamic> json) =>
    ReceiverAccept(
      timestamp: json['timestamp'] as String,
      $type: json['call_event'] as String?,
    );

Map<String, dynamic> _$ReceiverAcceptToJson(ReceiverAccept instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'call_event': instance.$type,
    };

ReceiverReject _$ReceiverRejectFromJson(Map<String, dynamic> json) =>
    ReceiverReject(
      clientTokenId: json['client_token_id'] as String,
      reason: json['reason'] as String? ?? '',
      $type: json['call_event'] as String?,
    );

Map<String, dynamic> _$ReceiverRejectToJson(ReceiverReject instance) =>
    <String, dynamic>{
      'client_token_id': instance.clientTokenId,
      'reason': instance.reason,
      'call_event': instance.$type,
    };

ReceiverDisconnected _$ReceiverDisconnectedFromJson(
  Map<String, dynamic> json,
) => ReceiverDisconnected($type: json['call_event'] as String?);

Map<String, dynamic> _$ReceiverDisconnectedToJson(
  ReceiverDisconnected instance,
) => <String, dynamic>{'call_event': instance.$type};

CallTimeout _$CallTimeoutFromJson(Map<String, dynamic> json) =>
    CallTimeout($type: json['call_event'] as String?);

Map<String, dynamic> _$CallTimeoutToJson(CallTimeout instance) =>
    <String, dynamic>{'call_event': instance.$type};

ReceiverHangUp _$ReceiverHangUpFromJson(Map<String, dynamic> json) =>
    ReceiverHangUp($type: json['call_event'] as String?);

Map<String, dynamic> _$ReceiverHangUpToJson(ReceiverHangUp instance) =>
    <String, dynamic>{'call_event': instance.$type};

CallError _$CallErrorFromJson(Map<String, dynamic> json) => CallError(
  errorCode: json['error_code'] as String,
  errorMessage: json['error_message'] as String,
  $type: json['call_event'] as String?,
);

Map<String, dynamic> _$CallErrorToJson(CallError instance) => <String, dynamic>{
  'error_code': instance.errorCode,
  'error_message': instance.errorMessage,
  'call_event': instance.$type,
};
