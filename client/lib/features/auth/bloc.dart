import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:async';

import '../../services/logging/logging_service.dart';
import 'model/app_user.dart';
import 'model/login_method.dart';
import '../../services/auth/service.dart';

part 'bloc.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  const AuthState._();

  const factory AuthState.checkingInitialAuth() = AuthStateCheckingInitialAuth;
  const factory AuthState.signedIn({required AppUser currentUser}) =
      AuthStateSignedIn;
  const factory AuthState.signedOut({
    String? error,
    required bool isLoggingIn,
  }) = AuthStateSignedOut;
}

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.checkInitialAuth() = CheckInitialAuth;
  const factory AuthEvent.logout() = Logout;
  const factory AuthEvent.login(LoginMethod loginMethod) = Login;
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoggingService logger;
  final AuthServiceBase repository;
  AuthBloc({required this.repository, required this.logger})
    : super(const AuthStateCheckingInitialAuth()) {
    on<Logout>(_onLogout);
    on<Login>(_onLogin);
    on<CheckInitialAuth>(_onCheckInitialAuth);
  }

  void _onCheckInitialAuth(
    CheckInitialAuth event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final currentUser = await repository.loadCurrentUser();
      if (currentUser != null) {
        emit(AuthStateSignedIn(currentUser: currentUser));
      } else {
        emit(const AuthStateSignedOut(isLoggingIn: false));
      }
    } catch (exc, stacktrace) {
      logger.error('Failed to check initial auth', exc, stacktrace);
      emit(const AuthStateSignedOut(isLoggingIn: false));
    }
  }

  void _onLogout(Logout event, Emitter<AuthState> emit) async {
    await repository.logout();
    emit(const AuthStateSignedOut(isLoggingIn: false));
  }

  void _onLogin(Login event, Emitter<AuthState> emit) async {
    if (state is AuthStateSignedOut) {
      emit(const AuthStateSignedOut(isLoggingIn: true));
    }
    try {
      await repository
          .login(event.loginMethod)
          .timeout(
            const Duration(seconds: 40),
            onTimeout: () =>
                throw TimeoutException('Login timed out after 40 seconds'),
          );
      final currentUser = await repository.loadCurrentUser();
      if (currentUser == null) {
        throw Exception("Authentication failed, current user is null");
      }
      emit(AuthStateSignedIn(currentUser: currentUser));
    } catch (exc) {
      if (exc is PhoneVerificationInitiatedException) {
        // Phone verification was initiated successfully, stay in signed out state
        // but don't set an error - the UI will handle this as success
        emit(const AuthStateSignedOut(isLoggingIn: false));
      } else {
        emit(AuthStateSignedOut(error: exc.toString(), isLoggingIn: false));
      }
    }
  }

  static provider(AuthServiceBase repository, LoggingService logger) {
    return BlocProvider(
      create: (context) =>
          AuthBloc(repository: repository, logger: logger)
            ..add(const CheckInitialAuth()),
    );
  }
}
