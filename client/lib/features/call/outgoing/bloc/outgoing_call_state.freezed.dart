// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'outgoing_call_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OutgoingCallState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutgoingCallState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'OutgoingCallState()';
}


}

/// @nodoc
class $OutgoingCallStateCopyWith<$Res>  {
$OutgoingCallStateCopyWith(OutgoingCallState _, $Res Function(OutgoingCallState) __);
}


/// @nodoc


class OutgoingCallStateIdle extends OutgoingCallState {
  const OutgoingCallStateIdle(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutgoingCallStateIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'OutgoingCallState.idle()';
}


}




/// @nodoc


class OutgoingCallStateCalling extends OutgoingCallState {
  const OutgoingCallStateCalling(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutgoingCallStateCalling);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'OutgoingCallState.calling()';
}


}




/// @nodoc


class OutgoingCallStateRinging extends OutgoingCallState {
  const OutgoingCallStateRinging(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutgoingCallStateRinging);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'OutgoingCallState.ringing()';
}


}




/// @nodoc


class OutgoingCallStateOngoing extends OutgoingCallState {
  const OutgoingCallStateOngoing({required this.startedAt}): super._();
  

 final  DateTime startedAt;

/// Create a copy of OutgoingCallState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutgoingCallStateOngoingCopyWith<OutgoingCallStateOngoing> get copyWith => _$OutgoingCallStateOngoingCopyWithImpl<OutgoingCallStateOngoing>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutgoingCallStateOngoing&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt));
}


@override
int get hashCode => Object.hash(runtimeType,startedAt);

@override
String toString() {
  return 'OutgoingCallState.ongoing(startedAt: $startedAt)';
}


}

/// @nodoc
abstract mixin class $OutgoingCallStateOngoingCopyWith<$Res> implements $OutgoingCallStateCopyWith<$Res> {
  factory $OutgoingCallStateOngoingCopyWith(OutgoingCallStateOngoing value, $Res Function(OutgoingCallStateOngoing) _then) = _$OutgoingCallStateOngoingCopyWithImpl;
@useResult
$Res call({
 DateTime startedAt
});




}
/// @nodoc
class _$OutgoingCallStateOngoingCopyWithImpl<$Res>
    implements $OutgoingCallStateOngoingCopyWith<$Res> {
  _$OutgoingCallStateOngoingCopyWithImpl(this._self, this._then);

  final OutgoingCallStateOngoing _self;
  final $Res Function(OutgoingCallStateOngoing) _then;

/// Create a copy of OutgoingCallState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? startedAt = null,}) {
  return _then(OutgoingCallStateOngoing(
startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class OutgoingCallStateUnanswered extends OutgoingCallState {
  const OutgoingCallStateUnanswered(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutgoingCallStateUnanswered);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'OutgoingCallState.unanswered()';
}


}




/// @nodoc


class OutgoingCallStateRejected extends OutgoingCallState {
  const OutgoingCallStateRejected(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutgoingCallStateRejected);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'OutgoingCallState.rejected()';
}


}




/// @nodoc


class OutgoingCallStateEnded extends OutgoingCallState {
  const OutgoingCallStateEnded({this.error}): super._();
  

 final  String? error;

/// Create a copy of OutgoingCallState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutgoingCallStateEndedCopyWith<OutgoingCallStateEnded> get copyWith => _$OutgoingCallStateEndedCopyWithImpl<OutgoingCallStateEnded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutgoingCallStateEnded&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'OutgoingCallState.ended(error: $error)';
}


}

/// @nodoc
abstract mixin class $OutgoingCallStateEndedCopyWith<$Res> implements $OutgoingCallStateCopyWith<$Res> {
  factory $OutgoingCallStateEndedCopyWith(OutgoingCallStateEnded value, $Res Function(OutgoingCallStateEnded) _then) = _$OutgoingCallStateEndedCopyWithImpl;
@useResult
$Res call({
 String? error
});




}
/// @nodoc
class _$OutgoingCallStateEndedCopyWithImpl<$Res>
    implements $OutgoingCallStateEndedCopyWith<$Res> {
  _$OutgoingCallStateEndedCopyWithImpl(this._self, this._then);

  final OutgoingCallStateEnded _self;
  final $Res Function(OutgoingCallStateEnded) _then;

/// Create a copy of OutgoingCallState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = freezed,}) {
  return _then(OutgoingCallStateEnded(
error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
