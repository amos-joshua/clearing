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
mixin _$AuthState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState()';
}


}

/// @nodoc
class $AuthStateCopyWith<$Res>  {
$AuthStateCopyWith(AuthState _, $Res Function(AuthState) __);
}


/// @nodoc


class AuthStateCheckingInitialAuth extends AuthState {
  const AuthStateCheckingInitialAuth(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthStateCheckingInitialAuth);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState.checkingInitialAuth()';
}


}




/// @nodoc


class AuthStateSignedIn extends AuthState {
  const AuthStateSignedIn({required this.currentUser}): super._();
  

 final  AppUser currentUser;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthStateSignedInCopyWith<AuthStateSignedIn> get copyWith => _$AuthStateSignedInCopyWithImpl<AuthStateSignedIn>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthStateSignedIn&&(identical(other.currentUser, currentUser) || other.currentUser == currentUser));
}


@override
int get hashCode => Object.hash(runtimeType,currentUser);

@override
String toString() {
  return 'AuthState.signedIn(currentUser: $currentUser)';
}


}

/// @nodoc
abstract mixin class $AuthStateSignedInCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory $AuthStateSignedInCopyWith(AuthStateSignedIn value, $Res Function(AuthStateSignedIn) _then) = _$AuthStateSignedInCopyWithImpl;
@useResult
$Res call({
 AppUser currentUser
});




}
/// @nodoc
class _$AuthStateSignedInCopyWithImpl<$Res>
    implements $AuthStateSignedInCopyWith<$Res> {
  _$AuthStateSignedInCopyWithImpl(this._self, this._then);

  final AuthStateSignedIn _self;
  final $Res Function(AuthStateSignedIn) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? currentUser = null,}) {
  return _then(AuthStateSignedIn(
currentUser: null == currentUser ? _self.currentUser : currentUser // ignore: cast_nullable_to_non_nullable
as AppUser,
  ));
}


}

/// @nodoc


class AuthStateSignedOut extends AuthState {
  const AuthStateSignedOut({this.error, required this.isLoggingIn}): super._();
  

 final  String? error;
 final  bool isLoggingIn;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthStateSignedOutCopyWith<AuthStateSignedOut> get copyWith => _$AuthStateSignedOutCopyWithImpl<AuthStateSignedOut>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthStateSignedOut&&(identical(other.error, error) || other.error == error)&&(identical(other.isLoggingIn, isLoggingIn) || other.isLoggingIn == isLoggingIn));
}


@override
int get hashCode => Object.hash(runtimeType,error,isLoggingIn);

@override
String toString() {
  return 'AuthState.signedOut(error: $error, isLoggingIn: $isLoggingIn)';
}


}

/// @nodoc
abstract mixin class $AuthStateSignedOutCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory $AuthStateSignedOutCopyWith(AuthStateSignedOut value, $Res Function(AuthStateSignedOut) _then) = _$AuthStateSignedOutCopyWithImpl;
@useResult
$Res call({
 String? error, bool isLoggingIn
});




}
/// @nodoc
class _$AuthStateSignedOutCopyWithImpl<$Res>
    implements $AuthStateSignedOutCopyWith<$Res> {
  _$AuthStateSignedOutCopyWithImpl(this._self, this._then);

  final AuthStateSignedOut _self;
  final $Res Function(AuthStateSignedOut) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = freezed,Object? isLoggingIn = null,}) {
  return _then(AuthStateSignedOut(
error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,isLoggingIn: null == isLoggingIn ? _self.isLoggingIn : isLoggingIn // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$AuthEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthEvent()';
}


}

/// @nodoc
class $AuthEventCopyWith<$Res>  {
$AuthEventCopyWith(AuthEvent _, $Res Function(AuthEvent) __);
}


/// @nodoc


class CheckInitialAuth implements AuthEvent {
  const CheckInitialAuth();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckInitialAuth);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthEvent.checkInitialAuth()';
}


}




/// @nodoc


class Logout implements AuthEvent {
  const Logout();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Logout);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthEvent.logout()';
}


}




/// @nodoc


class Login implements AuthEvent {
  const Login(this.loginMethod);
  

 final  LoginMethod loginMethod;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginCopyWith<Login> get copyWith => _$LoginCopyWithImpl<Login>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Login&&(identical(other.loginMethod, loginMethod) || other.loginMethod == loginMethod));
}


@override
int get hashCode => Object.hash(runtimeType,loginMethod);

@override
String toString() {
  return 'AuthEvent.login(loginMethod: $loginMethod)';
}


}

/// @nodoc
abstract mixin class $LoginCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $LoginCopyWith(Login value, $Res Function(Login) _then) = _$LoginCopyWithImpl;
@useResult
$Res call({
 LoginMethod loginMethod
});




}
/// @nodoc
class _$LoginCopyWithImpl<$Res>
    implements $LoginCopyWith<$Res> {
  _$LoginCopyWithImpl(this._self, this._then);

  final Login _self;
  final $Res Function(Login) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? loginMethod = null,}) {
  return _then(Login(
null == loginMethod ? _self.loginMethod : loginMethod // ignore: cast_nullable_to_non_nullable
as LoginMethod,
  ));
}


}

// dart format on
