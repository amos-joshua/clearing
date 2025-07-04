// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CallComposerState {

 String? get displayName; List<String> get contactPhoneNumbers; CallUrgency get urgency; String get subject;
/// Create a copy of CallComposerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CallComposerStateCopyWith<CallComposerState> get copyWith => _$CallComposerStateCopyWithImpl<CallComposerState>(this as CallComposerState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallComposerState&&(identical(other.displayName, displayName) || other.displayName == displayName)&&const DeepCollectionEquality().equals(other.contactPhoneNumbers, contactPhoneNumbers)&&(identical(other.urgency, urgency) || other.urgency == urgency)&&(identical(other.subject, subject) || other.subject == subject));
}


@override
int get hashCode => Object.hash(runtimeType,displayName,const DeepCollectionEquality().hash(contactPhoneNumbers),urgency,subject);

@override
String toString() {
  return 'CallComposerState(displayName: $displayName, contactPhoneNumbers: $contactPhoneNumbers, urgency: $urgency, subject: $subject)';
}


}

/// @nodoc
abstract mixin class $CallComposerStateCopyWith<$Res>  {
  factory $CallComposerStateCopyWith(CallComposerState value, $Res Function(CallComposerState) _then) = _$CallComposerStateCopyWithImpl;
@useResult
$Res call({
 String? displayName, List<String> contactPhoneNumbers, CallUrgency urgency, String subject
});




}
/// @nodoc
class _$CallComposerStateCopyWithImpl<$Res>
    implements $CallComposerStateCopyWith<$Res> {
  _$CallComposerStateCopyWithImpl(this._self, this._then);

  final CallComposerState _self;
  final $Res Function(CallComposerState) _then;

/// Create a copy of CallComposerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? displayName = freezed,Object? contactPhoneNumbers = null,Object? urgency = null,Object? subject = null,}) {
  return _then(_self.copyWith(
displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,contactPhoneNumbers: null == contactPhoneNumbers ? _self.contactPhoneNumbers : contactPhoneNumbers // ignore: cast_nullable_to_non_nullable
as List<String>,urgency: null == urgency ? _self.urgency : urgency // ignore: cast_nullable_to_non_nullable
as CallUrgency,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc


class _CallComposerState implements CallComposerState {
  const _CallComposerState({required this.displayName, required final  List<String> contactPhoneNumbers, required this.urgency, required this.subject}): _contactPhoneNumbers = contactPhoneNumbers;
  

@override final  String? displayName;
 final  List<String> _contactPhoneNumbers;
@override List<String> get contactPhoneNumbers {
  if (_contactPhoneNumbers is EqualUnmodifiableListView) return _contactPhoneNumbers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_contactPhoneNumbers);
}

@override final  CallUrgency urgency;
@override final  String subject;

/// Create a copy of CallComposerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CallComposerStateCopyWith<_CallComposerState> get copyWith => __$CallComposerStateCopyWithImpl<_CallComposerState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CallComposerState&&(identical(other.displayName, displayName) || other.displayName == displayName)&&const DeepCollectionEquality().equals(other._contactPhoneNumbers, _contactPhoneNumbers)&&(identical(other.urgency, urgency) || other.urgency == urgency)&&(identical(other.subject, subject) || other.subject == subject));
}


@override
int get hashCode => Object.hash(runtimeType,displayName,const DeepCollectionEquality().hash(_contactPhoneNumbers),urgency,subject);

@override
String toString() {
  return 'CallComposerState(displayName: $displayName, contactPhoneNumbers: $contactPhoneNumbers, urgency: $urgency, subject: $subject)';
}


}

/// @nodoc
abstract mixin class _$CallComposerStateCopyWith<$Res> implements $CallComposerStateCopyWith<$Res> {
  factory _$CallComposerStateCopyWith(_CallComposerState value, $Res Function(_CallComposerState) _then) = __$CallComposerStateCopyWithImpl;
@override @useResult
$Res call({
 String? displayName, List<String> contactPhoneNumbers, CallUrgency urgency, String subject
});




}
/// @nodoc
class __$CallComposerStateCopyWithImpl<$Res>
    implements _$CallComposerStateCopyWith<$Res> {
  __$CallComposerStateCopyWithImpl(this._self, this._then);

  final _CallComposerState _self;
  final $Res Function(_CallComposerState) _then;

/// Create a copy of CallComposerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? displayName = freezed,Object? contactPhoneNumbers = null,Object? urgency = null,Object? subject = null,}) {
  return _then(_CallComposerState(
displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,contactPhoneNumbers: null == contactPhoneNumbers ? _self._contactPhoneNumbers : contactPhoneNumbers // ignore: cast_nullable_to_non_nullable
as List<String>,urgency: null == urgency ? _self.urgency : urgency // ignore: cast_nullable_to_non_nullable
as CallUrgency,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
