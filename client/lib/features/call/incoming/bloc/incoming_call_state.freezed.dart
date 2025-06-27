// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'incoming_call_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$IncomingCallState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IncomingCallState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'IncomingCallState()';
}


}

/// @nodoc
class $IncomingCallStateCopyWith<$Res>  {
$IncomingCallStateCopyWith(IncomingCallState _, $Res Function(IncomingCallState) __);
}


/// @nodoc


class IncomingCallStateIdle extends IncomingCallState {
  const IncomingCallStateIdle(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IncomingCallStateIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'IncomingCallState.idle()';
}


}




/// @nodoc


class IncomingCallStateRinging extends IncomingCallState {
  const IncomingCallStateRinging(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IncomingCallStateRinging);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'IncomingCallState.ringing()';
}


}




/// @nodoc


class IncomingCallStateOngoing extends IncomingCallState {
  const IncomingCallStateOngoing({required this.startedAt}): super._();
  

 final  DateTime startedAt;

/// Create a copy of IncomingCallState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IncomingCallStateOngoingCopyWith<IncomingCallStateOngoing> get copyWith => _$IncomingCallStateOngoingCopyWithImpl<IncomingCallStateOngoing>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IncomingCallStateOngoing&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt));
}


@override
int get hashCode => Object.hash(runtimeType,startedAt);

@override
String toString() {
  return 'IncomingCallState.ongoing(startedAt: $startedAt)';
}


}

/// @nodoc
abstract mixin class $IncomingCallStateOngoingCopyWith<$Res> implements $IncomingCallStateCopyWith<$Res> {
  factory $IncomingCallStateOngoingCopyWith(IncomingCallStateOngoing value, $Res Function(IncomingCallStateOngoing) _then) = _$IncomingCallStateOngoingCopyWithImpl;
@useResult
$Res call({
 DateTime startedAt
});




}
/// @nodoc
class _$IncomingCallStateOngoingCopyWithImpl<$Res>
    implements $IncomingCallStateOngoingCopyWith<$Res> {
  _$IncomingCallStateOngoingCopyWithImpl(this._self, this._then);

  final IncomingCallStateOngoing _self;
  final $Res Function(IncomingCallStateOngoing) _then;

/// Create a copy of IncomingCallState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? startedAt = null,}) {
  return _then(IncomingCallStateOngoing(
startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class IncomingCallStateUnanswered extends IncomingCallState {
  const IncomingCallStateUnanswered(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IncomingCallStateUnanswered);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'IncomingCallState.unanswered()';
}


}




/// @nodoc


class IncomingCallStateRejected extends IncomingCallState {
  const IncomingCallStateRejected(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IncomingCallStateRejected);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'IncomingCallState.rejected()';
}


}




/// @nodoc


class IncomingCallStateEnded extends IncomingCallState {
  const IncomingCallStateEnded({this.error}): super._();
  

 final  String? error;

/// Create a copy of IncomingCallState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IncomingCallStateEndedCopyWith<IncomingCallStateEnded> get copyWith => _$IncomingCallStateEndedCopyWithImpl<IncomingCallStateEnded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IncomingCallStateEnded&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'IncomingCallState.ended(error: $error)';
}


}

/// @nodoc
abstract mixin class $IncomingCallStateEndedCopyWith<$Res> implements $IncomingCallStateCopyWith<$Res> {
  factory $IncomingCallStateEndedCopyWith(IncomingCallStateEnded value, $Res Function(IncomingCallStateEnded) _then) = _$IncomingCallStateEndedCopyWithImpl;
@useResult
$Res call({
 String? error
});




}
/// @nodoc
class _$IncomingCallStateEndedCopyWithImpl<$Res>
    implements $IncomingCallStateEndedCopyWith<$Res> {
  _$IncomingCallStateEndedCopyWithImpl(this._self, this._then);

  final IncomingCallStateEnded _self;
  final $Res Function(IncomingCallStateEnded) _then;

/// Create a copy of IncomingCallState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = freezed,}) {
  return _then(IncomingCallStateEnded(
error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
