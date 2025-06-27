// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'call_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
CallEvent _$CallEventFromJson(
  Map<String, dynamic> json
) {
        switch (json['call_event']) {
                  case 'sender_call_init':
          return SenderCallInit.fromJson(
            json
          );
                case 'sender_ice_candidates':
          return SenderIceCandidates.fromJson(
            json
          );
                case 'sender_hang_up':
          return SenderHangUp.fromJson(
            json
          );
                case 'sender_disconnected':
          return SenderDisconnected.fromJson(
            json
          );
                case 'incoming_call_init':
          return IncomingCallInit.fromJson(
            json
          );
                case 'receiver_ack':
          return ReceiverAck.fromJson(
            json
          );
                case 'receiver_accept':
          return ReceiverAccept.fromJson(
            json
          );
                case 'receiver_reject':
          return ReceiverReject.fromJson(
            json
          );
                case 'receiver_disconnected':
          return ReceiverDisconnected.fromJson(
            json
          );
                case 'call_timeout':
          return CallTimeout.fromJson(
            json
          );
                case 'receiver_hang_up':
          return ReceiverHangUp.fromJson(
            json
          );
                case 'error':
          return CallError.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'call_event',
  'CallEvent',
  'Invalid union type "${json['call_event']}"!'
);
        }
      
}

/// @nodoc
mixin _$CallEvent {



  /// Serializes this CallEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallEvent);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CallEvent()';
}


}

/// @nodoc
class $CallEventCopyWith<$Res>  {
$CallEventCopyWith(CallEvent _, $Res Function(CallEvent) __);
}


/// @nodoc
@JsonSerializable()

class SenderCallInit implements CallEvent {
  const SenderCallInit({@JsonKey(name: 'client_token_id') required this.clientTokenId, @JsonKey(name: 'receiver_emails') required final  List<String> receiverEmails, required this.urgency, required this.subject, @JsonKey(name: 'sdp_offer') required this.sdpOffer, final  String? $type}): _receiverEmails = receiverEmails,$type = $type ?? 'sender_call_init';
  factory SenderCallInit.fromJson(Map<String, dynamic> json) => _$SenderCallInitFromJson(json);

@JsonKey(name: 'client_token_id') final  String clientTokenId;
 final  List<String> _receiverEmails;
@JsonKey(name: 'receiver_emails') List<String> get receiverEmails {
  if (_receiverEmails is EqualUnmodifiableListView) return _receiverEmails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_receiverEmails);
}

 final  CallUrgency urgency;
 final  String subject;
@JsonKey(name: 'sdp_offer') final  String sdpOffer;

@JsonKey(name: 'call_event')
final String $type;


/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SenderCallInitCopyWith<SenderCallInit> get copyWith => _$SenderCallInitCopyWithImpl<SenderCallInit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SenderCallInitToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SenderCallInit&&(identical(other.clientTokenId, clientTokenId) || other.clientTokenId == clientTokenId)&&const DeepCollectionEquality().equals(other._receiverEmails, _receiverEmails)&&(identical(other.urgency, urgency) || other.urgency == urgency)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.sdpOffer, sdpOffer) || other.sdpOffer == sdpOffer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientTokenId,const DeepCollectionEquality().hash(_receiverEmails),urgency,subject,sdpOffer);

@override
String toString() {
  return 'CallEvent.senderCallInit(clientTokenId: $clientTokenId, receiverEmails: $receiverEmails, urgency: $urgency, subject: $subject, sdpOffer: $sdpOffer)';
}


}

/// @nodoc
abstract mixin class $SenderCallInitCopyWith<$Res> implements $CallEventCopyWith<$Res> {
  factory $SenderCallInitCopyWith(SenderCallInit value, $Res Function(SenderCallInit) _then) = _$SenderCallInitCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'client_token_id') String clientTokenId,@JsonKey(name: 'receiver_emails') List<String> receiverEmails, CallUrgency urgency, String subject,@JsonKey(name: 'sdp_offer') String sdpOffer
});




}
/// @nodoc
class _$SenderCallInitCopyWithImpl<$Res>
    implements $SenderCallInitCopyWith<$Res> {
  _$SenderCallInitCopyWithImpl(this._self, this._then);

  final SenderCallInit _self;
  final $Res Function(SenderCallInit) _then;

/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? clientTokenId = null,Object? receiverEmails = null,Object? urgency = null,Object? subject = null,Object? sdpOffer = null,}) {
  return _then(SenderCallInit(
clientTokenId: null == clientTokenId ? _self.clientTokenId : clientTokenId // ignore: cast_nullable_to_non_nullable
as String,receiverEmails: null == receiverEmails ? _self._receiverEmails : receiverEmails // ignore: cast_nullable_to_non_nullable
as List<String>,urgency: null == urgency ? _self.urgency : urgency // ignore: cast_nullable_to_non_nullable
as CallUrgency,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,sdpOffer: null == sdpOffer ? _self.sdpOffer : sdpOffer // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class SenderIceCandidates implements CallEvent {
  const SenderIceCandidates({@JsonKey(name: 'ice_candidates') required final  List<String> iceCandidates, final  String? $type}): _iceCandidates = iceCandidates,$type = $type ?? 'sender_ice_candidates';
  factory SenderIceCandidates.fromJson(Map<String, dynamic> json) => _$SenderIceCandidatesFromJson(json);

 final  List<String> _iceCandidates;
@JsonKey(name: 'ice_candidates') List<String> get iceCandidates {
  if (_iceCandidates is EqualUnmodifiableListView) return _iceCandidates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_iceCandidates);
}


@JsonKey(name: 'call_event')
final String $type;


/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SenderIceCandidatesCopyWith<SenderIceCandidates> get copyWith => _$SenderIceCandidatesCopyWithImpl<SenderIceCandidates>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SenderIceCandidatesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SenderIceCandidates&&const DeepCollectionEquality().equals(other._iceCandidates, _iceCandidates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_iceCandidates));

@override
String toString() {
  return 'CallEvent.senderIceCandidates(iceCandidates: $iceCandidates)';
}


}

/// @nodoc
abstract mixin class $SenderIceCandidatesCopyWith<$Res> implements $CallEventCopyWith<$Res> {
  factory $SenderIceCandidatesCopyWith(SenderIceCandidates value, $Res Function(SenderIceCandidates) _then) = _$SenderIceCandidatesCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'ice_candidates') List<String> iceCandidates
});




}
/// @nodoc
class _$SenderIceCandidatesCopyWithImpl<$Res>
    implements $SenderIceCandidatesCopyWith<$Res> {
  _$SenderIceCandidatesCopyWithImpl(this._self, this._then);

  final SenderIceCandidates _self;
  final $Res Function(SenderIceCandidates) _then;

/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? iceCandidates = null,}) {
  return _then(SenderIceCandidates(
iceCandidates: null == iceCandidates ? _self._iceCandidates : iceCandidates // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
@JsonSerializable()

class SenderHangUp implements CallEvent {
  const SenderHangUp({final  String? $type}): $type = $type ?? 'sender_hang_up';
  factory SenderHangUp.fromJson(Map<String, dynamic> json) => _$SenderHangUpFromJson(json);



@JsonKey(name: 'call_event')
final String $type;



@override
Map<String, dynamic> toJson() {
  return _$SenderHangUpToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SenderHangUp);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CallEvent.senderHangUp()';
}


}




/// @nodoc
@JsonSerializable()

class SenderDisconnected implements CallEvent {
  const SenderDisconnected({final  String? $type}): $type = $type ?? 'sender_disconnected';
  factory SenderDisconnected.fromJson(Map<String, dynamic> json) => _$SenderDisconnectedFromJson(json);



@JsonKey(name: 'call_event')
final String $type;



@override
Map<String, dynamic> toJson() {
  return _$SenderDisconnectedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SenderDisconnected);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CallEvent.senderDisconnected()';
}


}




/// @nodoc
@JsonSerializable()

class IncomingCallInit implements CallEvent {
  const IncomingCallInit({@JsonKey(name: 'call_uuid') required this.callUuid, @JsonKey(name: 'caller_display_name') required this.callerDisplayName, @JsonKey(name: 'caller_email') required this.callerEmail, required this.urgency, required this.subject, @JsonKey(name: 'sdp_offer') required this.sdpOffer, final  String? $type}): $type = $type ?? 'incoming_call_init';
  factory IncomingCallInit.fromJson(Map<String, dynamic> json) => _$IncomingCallInitFromJson(json);

@JsonKey(name: 'call_uuid') final  String callUuid;
@JsonKey(name: 'caller_display_name') final  String callerDisplayName;
@JsonKey(name: 'caller_email') final  String callerEmail;
 final  CallUrgency urgency;
 final  String subject;
@JsonKey(name: 'sdp_offer') final  String sdpOffer;

@JsonKey(name: 'call_event')
final String $type;


/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IncomingCallInitCopyWith<IncomingCallInit> get copyWith => _$IncomingCallInitCopyWithImpl<IncomingCallInit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IncomingCallInitToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IncomingCallInit&&(identical(other.callUuid, callUuid) || other.callUuid == callUuid)&&(identical(other.callerDisplayName, callerDisplayName) || other.callerDisplayName == callerDisplayName)&&(identical(other.callerEmail, callerEmail) || other.callerEmail == callerEmail)&&(identical(other.urgency, urgency) || other.urgency == urgency)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.sdpOffer, sdpOffer) || other.sdpOffer == sdpOffer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,callUuid,callerDisplayName,callerEmail,urgency,subject,sdpOffer);

@override
String toString() {
  return 'CallEvent.incomingCallInit(callUuid: $callUuid, callerDisplayName: $callerDisplayName, callerEmail: $callerEmail, urgency: $urgency, subject: $subject, sdpOffer: $sdpOffer)';
}


}

/// @nodoc
abstract mixin class $IncomingCallInitCopyWith<$Res> implements $CallEventCopyWith<$Res> {
  factory $IncomingCallInitCopyWith(IncomingCallInit value, $Res Function(IncomingCallInit) _then) = _$IncomingCallInitCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'call_uuid') String callUuid,@JsonKey(name: 'caller_display_name') String callerDisplayName,@JsonKey(name: 'caller_email') String callerEmail, CallUrgency urgency, String subject,@JsonKey(name: 'sdp_offer') String sdpOffer
});




}
/// @nodoc
class _$IncomingCallInitCopyWithImpl<$Res>
    implements $IncomingCallInitCopyWith<$Res> {
  _$IncomingCallInitCopyWithImpl(this._self, this._then);

  final IncomingCallInit _self;
  final $Res Function(IncomingCallInit) _then;

/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? callUuid = null,Object? callerDisplayName = null,Object? callerEmail = null,Object? urgency = null,Object? subject = null,Object? sdpOffer = null,}) {
  return _then(IncomingCallInit(
callUuid: null == callUuid ? _self.callUuid : callUuid // ignore: cast_nullable_to_non_nullable
as String,callerDisplayName: null == callerDisplayName ? _self.callerDisplayName : callerDisplayName // ignore: cast_nullable_to_non_nullable
as String,callerEmail: null == callerEmail ? _self.callerEmail : callerEmail // ignore: cast_nullable_to_non_nullable
as String,urgency: null == urgency ? _self.urgency : urgency // ignore: cast_nullable_to_non_nullable
as CallUrgency,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,sdpOffer: null == sdpOffer ? _self.sdpOffer : sdpOffer // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ReceiverAck implements CallEvent {
  const ReceiverAck({@JsonKey(name: 'client_token_id') required this.clientTokenId, @JsonKey(name: 'sdp_answer') required this.sdpAnswer, final  String? $type}): $type = $type ?? 'receiver_ack';
  factory ReceiverAck.fromJson(Map<String, dynamic> json) => _$ReceiverAckFromJson(json);

@JsonKey(name: 'client_token_id') final  String clientTokenId;
@JsonKey(name: 'sdp_answer') final  String sdpAnswer;

@JsonKey(name: 'call_event')
final String $type;


/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceiverAckCopyWith<ReceiverAck> get copyWith => _$ReceiverAckCopyWithImpl<ReceiverAck>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReceiverAckToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceiverAck&&(identical(other.clientTokenId, clientTokenId) || other.clientTokenId == clientTokenId)&&(identical(other.sdpAnswer, sdpAnswer) || other.sdpAnswer == sdpAnswer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientTokenId,sdpAnswer);

@override
String toString() {
  return 'CallEvent.receiverAck(clientTokenId: $clientTokenId, sdpAnswer: $sdpAnswer)';
}


}

/// @nodoc
abstract mixin class $ReceiverAckCopyWith<$Res> implements $CallEventCopyWith<$Res> {
  factory $ReceiverAckCopyWith(ReceiverAck value, $Res Function(ReceiverAck) _then) = _$ReceiverAckCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'client_token_id') String clientTokenId,@JsonKey(name: 'sdp_answer') String sdpAnswer
});




}
/// @nodoc
class _$ReceiverAckCopyWithImpl<$Res>
    implements $ReceiverAckCopyWith<$Res> {
  _$ReceiverAckCopyWithImpl(this._self, this._then);

  final ReceiverAck _self;
  final $Res Function(ReceiverAck) _then;

/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? clientTokenId = null,Object? sdpAnswer = null,}) {
  return _then(ReceiverAck(
clientTokenId: null == clientTokenId ? _self.clientTokenId : clientTokenId // ignore: cast_nullable_to_non_nullable
as String,sdpAnswer: null == sdpAnswer ? _self.sdpAnswer : sdpAnswer // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ReceiverAccept implements CallEvent {
  const ReceiverAccept({@JsonKey(name: 'timestamp') required this.timestamp, final  String? $type}): $type = $type ?? 'receiver_accept';
  factory ReceiverAccept.fromJson(Map<String, dynamic> json) => _$ReceiverAcceptFromJson(json);

@JsonKey(name: 'timestamp') final  String timestamp;

@JsonKey(name: 'call_event')
final String $type;


/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceiverAcceptCopyWith<ReceiverAccept> get copyWith => _$ReceiverAcceptCopyWithImpl<ReceiverAccept>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReceiverAcceptToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceiverAccept&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,timestamp);

@override
String toString() {
  return 'CallEvent.receiverAccept(timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $ReceiverAcceptCopyWith<$Res> implements $CallEventCopyWith<$Res> {
  factory $ReceiverAcceptCopyWith(ReceiverAccept value, $Res Function(ReceiverAccept) _then) = _$ReceiverAcceptCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'timestamp') String timestamp
});




}
/// @nodoc
class _$ReceiverAcceptCopyWithImpl<$Res>
    implements $ReceiverAcceptCopyWith<$Res> {
  _$ReceiverAcceptCopyWithImpl(this._self, this._then);

  final ReceiverAccept _self;
  final $Res Function(ReceiverAccept) _then;

/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? timestamp = null,}) {
  return _then(ReceiverAccept(
timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ReceiverReject implements CallEvent {
  const ReceiverReject({@JsonKey(name: 'client_token_id') required this.clientTokenId, this.reason = '', final  String? $type}): $type = $type ?? 'receiver_reject';
  factory ReceiverReject.fromJson(Map<String, dynamic> json) => _$ReceiverRejectFromJson(json);

@JsonKey(name: 'client_token_id') final  String clientTokenId;
@JsonKey() final  String reason;

@JsonKey(name: 'call_event')
final String $type;


/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceiverRejectCopyWith<ReceiverReject> get copyWith => _$ReceiverRejectCopyWithImpl<ReceiverReject>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReceiverRejectToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceiverReject&&(identical(other.clientTokenId, clientTokenId) || other.clientTokenId == clientTokenId)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientTokenId,reason);

@override
String toString() {
  return 'CallEvent.receiverReject(clientTokenId: $clientTokenId, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $ReceiverRejectCopyWith<$Res> implements $CallEventCopyWith<$Res> {
  factory $ReceiverRejectCopyWith(ReceiverReject value, $Res Function(ReceiverReject) _then) = _$ReceiverRejectCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'client_token_id') String clientTokenId, String reason
});




}
/// @nodoc
class _$ReceiverRejectCopyWithImpl<$Res>
    implements $ReceiverRejectCopyWith<$Res> {
  _$ReceiverRejectCopyWithImpl(this._self, this._then);

  final ReceiverReject _self;
  final $Res Function(ReceiverReject) _then;

/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? clientTokenId = null,Object? reason = null,}) {
  return _then(ReceiverReject(
clientTokenId: null == clientTokenId ? _self.clientTokenId : clientTokenId // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ReceiverDisconnected implements CallEvent {
  const ReceiverDisconnected({final  String? $type}): $type = $type ?? 'receiver_disconnected';
  factory ReceiverDisconnected.fromJson(Map<String, dynamic> json) => _$ReceiverDisconnectedFromJson(json);



@JsonKey(name: 'call_event')
final String $type;



@override
Map<String, dynamic> toJson() {
  return _$ReceiverDisconnectedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceiverDisconnected);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CallEvent.receiverDisconnected()';
}


}




/// @nodoc
@JsonSerializable()

class CallTimeout implements CallEvent {
  const CallTimeout({final  String? $type}): $type = $type ?? 'call_timeout';
  factory CallTimeout.fromJson(Map<String, dynamic> json) => _$CallTimeoutFromJson(json);



@JsonKey(name: 'call_event')
final String $type;



@override
Map<String, dynamic> toJson() {
  return _$CallTimeoutToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallTimeout);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CallEvent.callTimeout()';
}


}




/// @nodoc
@JsonSerializable()

class ReceiverHangUp implements CallEvent {
  const ReceiverHangUp({final  String? $type}): $type = $type ?? 'receiver_hang_up';
  factory ReceiverHangUp.fromJson(Map<String, dynamic> json) => _$ReceiverHangUpFromJson(json);



@JsonKey(name: 'call_event')
final String $type;



@override
Map<String, dynamic> toJson() {
  return _$ReceiverHangUpToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceiverHangUp);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CallEvent.receiverHangUp()';
}


}




/// @nodoc
@JsonSerializable()

class CallError implements CallEvent {
  const CallError({@JsonKey(name: 'error_code') required this.errorCode, @JsonKey(name: 'error_message') required this.errorMessage, final  String? $type}): $type = $type ?? 'error';
  factory CallError.fromJson(Map<String, dynamic> json) => _$CallErrorFromJson(json);

@JsonKey(name: 'error_code') final  String errorCode;
@JsonKey(name: 'error_message') final  String errorMessage;

@JsonKey(name: 'call_event')
final String $type;


/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CallErrorCopyWith<CallError> get copyWith => _$CallErrorCopyWithImpl<CallError>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CallErrorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallError&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,errorCode,errorMessage);

@override
String toString() {
  return 'CallEvent.error(errorCode: $errorCode, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $CallErrorCopyWith<$Res> implements $CallEventCopyWith<$Res> {
  factory $CallErrorCopyWith(CallError value, $Res Function(CallError) _then) = _$CallErrorCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'error_code') String errorCode,@JsonKey(name: 'error_message') String errorMessage
});




}
/// @nodoc
class _$CallErrorCopyWithImpl<$Res>
    implements $CallErrorCopyWith<$Res> {
  _$CallErrorCopyWithImpl(this._self, this._then);

  final CallError _self;
  final $Res Function(CallError) _then;

/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? errorCode = null,Object? errorMessage = null,}) {
  return _then(CallError(
errorCode: null == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String,errorMessage: null == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
