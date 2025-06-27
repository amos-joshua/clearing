// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppState()';
}


}

/// @nodoc
class $AppStateCopyWith<$Res>  {
$AppStateCopyWith(AppState _, $Res Function(AppState) __);
}


/// @nodoc


class AppStateInitializing extends AppState {
  const AppStateInitializing(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppStateInitializing);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppState.initializing()';
}


}




/// @nodoc


class AppStateInitialized extends AppState {
  const AppStateInitialized({required this.appServices}): super._();
  

 final  AppServices appServices;

/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppStateInitializedCopyWith<AppStateInitialized> get copyWith => _$AppStateInitializedCopyWithImpl<AppStateInitialized>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppStateInitialized&&(identical(other.appServices, appServices) || other.appServices == appServices));
}


@override
int get hashCode => Object.hash(runtimeType,appServices);

@override
String toString() {
  return 'AppState.initialized(appServices: $appServices)';
}


}

/// @nodoc
abstract mixin class $AppStateInitializedCopyWith<$Res> implements $AppStateCopyWith<$Res> {
  factory $AppStateInitializedCopyWith(AppStateInitialized value, $Res Function(AppStateInitialized) _then) = _$AppStateInitializedCopyWithImpl;
@useResult
$Res call({
 AppServices appServices
});




}
/// @nodoc
class _$AppStateInitializedCopyWithImpl<$Res>
    implements $AppStateInitializedCopyWith<$Res> {
  _$AppStateInitializedCopyWithImpl(this._self, this._then);

  final AppStateInitialized _self;
  final $Res Function(AppStateInitialized) _then;

/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? appServices = null,}) {
  return _then(AppStateInitialized(
appServices: null == appServices ? _self.appServices : appServices // ignore: cast_nullable_to_non_nullable
as AppServices,
  ));
}


}

/// @nodoc


class AppStateInitFailed extends AppState {
  const AppStateInitFailed(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppStateInitFailed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppState.initFailed()';
}


}




/// @nodoc
mixin _$AppEvent {

 AppServices get appServices;
/// Create a copy of AppEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppEventCopyWith<AppEvent> get copyWith => _$AppEventCopyWithImpl<AppEvent>(this as AppEvent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppEvent&&(identical(other.appServices, appServices) || other.appServices == appServices));
}


@override
int get hashCode => Object.hash(runtimeType,appServices);

@override
String toString() {
  return 'AppEvent(appServices: $appServices)';
}


}

/// @nodoc
abstract mixin class $AppEventCopyWith<$Res>  {
  factory $AppEventCopyWith(AppEvent value, $Res Function(AppEvent) _then) = _$AppEventCopyWithImpl;
@useResult
$Res call({
 AppServices appServices
});




}
/// @nodoc
class _$AppEventCopyWithImpl<$Res>
    implements $AppEventCopyWith<$Res> {
  _$AppEventCopyWithImpl(this._self, this._then);

  final AppEvent _self;
  final $Res Function(AppEvent) _then;

/// Create a copy of AppEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? appServices = null,}) {
  return _then(_self.copyWith(
appServices: null == appServices ? _self.appServices : appServices // ignore: cast_nullable_to_non_nullable
as AppServices,
  ));
}

}


/// @nodoc


class InitServices implements AppEvent {
  const InitServices({required this.appServices});
  

@override final  AppServices appServices;

/// Create a copy of AppEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InitServicesCopyWith<InitServices> get copyWith => _$InitServicesCopyWithImpl<InitServices>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InitServices&&(identical(other.appServices, appServices) || other.appServices == appServices));
}


@override
int get hashCode => Object.hash(runtimeType,appServices);

@override
String toString() {
  return 'AppEvent.initServices(appServices: $appServices)';
}


}

/// @nodoc
abstract mixin class $InitServicesCopyWith<$Res> implements $AppEventCopyWith<$Res> {
  factory $InitServicesCopyWith(InitServices value, $Res Function(InitServices) _then) = _$InitServicesCopyWithImpl;
@override @useResult
$Res call({
 AppServices appServices
});




}
/// @nodoc
class _$InitServicesCopyWithImpl<$Res>
    implements $InitServicesCopyWith<$Res> {
  _$InitServicesCopyWithImpl(this._self, this._then);

  final InitServices _self;
  final $Res Function(InitServices) _then;

/// Create a copy of AppEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? appServices = null,}) {
  return _then(InitServices(
appServices: null == appServices ? _self.appServices : appServices // ignore: cast_nullable_to_non_nullable
as AppServices,
  ));
}


}

// dart format on
