import 'dart:io';

import 'package:clearing_client/features/auth/model/app_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';

import '../firebase/service.dart';
import '../logging/logging_service.dart';
import '../runtime_parameters/service.dart';
import '../../features/auth/model/login_method.dart';
import 'phone_auth_service.dart';

/// Exception thrown when phone verification is initiated successfully
/// This is not an error, but indicates that the SMS code was sent
class PhoneVerificationInitiatedException implements Exception {
  @override
  String toString() =>
      'Phone verification initiated. Please provide the SMS code.';
}

abstract class AuthServiceBase {
  Future<void> init(RuntimeParameters runtimeParameters);
  Future<AppUser?> loadCurrentUser();
  Future<void> logout();
  Future<void> login(LoginMethod loginMethod);
  Future<void> deleteUserData();

  // Phone authentication methods
  Future<UserCredential?> sendPhoneVerificationCode(String phoneNumber);
  Future<UserCredential> verifyPhoneCode(String smsCode);
  Future<UserCredential?> resendPhoneVerificationCode(String phoneNumber);
  bool get hasActivePhoneVerification;
  void clearPhoneVerificationSession();
}

class AuthServiceMock implements AuthServiceBase {
  @override
  Future<void> init(RuntimeParameters runtimeParameters) async {}

  AppUser? currentUser = AppUser(
    phoneNumber: 'test@test.com',
    displayName: 'Test User',
    uid: 'test-user-id',
    authToken: 'test-token',
  );

  @override
  Future<AppUser?> loadCurrentUser() async {
    return currentUser;
  }

  @override
  Future<void> logout() async {
    currentUser = null;
  }

  @override
  Future<void> login(LoginMethod loginMethod) async {
    currentUser = AppUser(
      phoneNumber: 'test@example.com',
      displayName: 'Test User',
      uid: 'test-user-id',
      authToken: 'test-token',
    );
  }

  @override
  Future<void> deleteUserData() async {
    currentUser = null;
  }

  @override
  Future<UserCredential?> sendPhoneVerificationCode(String phoneNumber) async {
    // Mock implementation
    print('Mock: Sending verification code to $phoneNumber');
    return null;
  }

  @override
  Future<UserCredential> verifyPhoneCode(String smsCode) async {
    // Mock implementation - create a mock user credential
    throw UnimplementedError('Mock phone verification not implemented');
  }

  @override
  Future<UserCredential?> resendPhoneVerificationCode(
    String phoneNumber,
  ) async {
    // Mock implementation
    print('Mock: Resending verification code to $phoneNumber');
    return null;
  }

  @override
  bool get hasActivePhoneVerification => false;

  @override
  void clearPhoneVerificationSession() {
    // Mock implementation
    print('Mock: Clearing phone verification session');
  }
}

class AuthServiceFirebase implements AuthServiceBase {
  final FirebaseServiceBase _firebaseService;
  FirebaseAuth get _auth => _firebaseService.firebaseAuth;

  final LoggingService _logger;
  late final RuntimeParameters _runtimeParameters;
  late final PhoneAuthService _phoneAuthService = PhoneAuthService(
    _auth,
    _logger,
  );

  AuthServiceFirebase(this._logger, this._firebaseService);

  @override
  Future<void> init(RuntimeParameters runtimeParameters) async {
    _runtimeParameters = runtimeParameters;
    _firebaseService.firebaseAuth.idTokenChanges().listen(onUserTokenChanged);
  }

  void onUserTokenChanged(User? user) async {
    if (user == null) {
      return;
    }

    final deviceRegistrationToken = await FirebaseMessaging.instance.getToken();
    if (deviceRegistrationToken == null) {
      _logger.warning(
        'Device registration token is unexpectedly null when user token changed for user ${user.uid}',
      );
      return;
    }
    final deviceName =
        '${Platform.operatingSystem} ${_runtimeParameters.osVersion} ${_runtimeParameters.phoneModel}';
    await _firebaseService.updateDevice(deviceRegistrationToken, deviceName);
    _logger.info(
      'Updated device for user ${user.uid} with token $deviceRegistrationToken and name $deviceName',
    );
  }

  @override
  Future<AppUser?> loadCurrentUser() async {
    return switch (_auth.currentUser) {
      final user? => AppUser.fromFirebase(user),
      _ => null,
    };
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Future<void> login(LoginMethod loginMethod) async {
    try {
      final userCredential = switch (loginMethod) {
        LoginMethodEmailPassword method =>
          await _auth.signInWithEmailAndPassword(
            email: method.email,
            password: method.password,
          ),
        LoginMethodGoogle() => await _auth.signInWithProvider(
          GoogleAuthProvider(),
        ),
        LoginMethodPhone method => await _handlePhoneAuth(method),
      };

      final deviceRegistrationToken = await FirebaseMessaging.instance
          .getToken();
      final userUid = userCredential.user?.uid;
      if (deviceRegistrationToken == null) {
        throw Exception(
          'Cannot log in user with ${loginMethod.logInfo()}: invalid device registration token',
        );
      }
      if (userUid == null) {
        throw Exception(
          'Cannot log in user with ${loginMethod.logInfo()}: invalid user uid',
        );
      }
      final deviceName =
          '${Platform.operatingSystem} ${_runtimeParameters.osVersion} ${_runtimeParameters.phoneModel}';
      await _firebaseService.updateDevice(deviceRegistrationToken, deviceName);
      _logger.info(
        'Updated device for user $userUid with token $deviceRegistrationToken and name $deviceName',
      );
    } on FirebaseAuthException catch (exc) {
      switch (exc.code) {
        case 'user-not-found':
          throw Exception('No user found with this email.');
        case 'wrong-password':
          throw Exception('Wrong password provided.');
        case 'invalid-email':
          throw Exception('The email address is not valid.');
        case 'user-disabled':
          throw Exception('This user has been disabled.');
        case 'invalid-phone-number':
          throw Exception('The phone number is not valid.');
        case 'invalid-verification-code':
          throw Exception('The verification code is not valid.');
        case 'session-expired':
          throw Exception(
            'The verification session has expired. Please try again.',
          );
        default:
          throw Exception('An error occurred during login: ${exc.message}');
      }
    }
  }

  Future<UserCredential> _handlePhoneAuth(LoginMethodPhone method) async {
    if (method.smsCode != null) {
      // Complete the phone sign-in with SMS code
      return await _phoneAuthService.verifyCode(method.smsCode!);
    } else {
      // Start the phone sign-in process
      final userCredential = await _phoneAuthService.sendVerificationCode(
        method.phoneNumber,
      );
      if (userCredential != null) {
        return userCredential;
      }
      // Code was sent successfully, but we need to wait for SMS code
      // This is the expected flow for phone auth, so we don't throw an exception
      // Instead, we throw a specific exception that indicates success
      throw PhoneVerificationInitiatedException();
    }
  }

  // Method to send verification code (called from UI)
  @override
  Future<UserCredential?> sendPhoneVerificationCode(String phoneNumber) async {
    return await _phoneAuthService.sendVerificationCode(phoneNumber);
  }

  // Method to verify SMS code (called from UI)
  @override
  Future<UserCredential> verifyPhoneCode(String smsCode) async {
    return await _phoneAuthService.verifyCode(smsCode);
  }

  // Method to resend verification code (called from UI)
  @override
  Future<UserCredential?> resendPhoneVerificationCode(
    String phoneNumber,
  ) async {
    return await _phoneAuthService.resendCode(phoneNumber);
  }

  // Method to check if there's an active verification session
  @override
  bool get hasActivePhoneVerification =>
      _phoneAuthService.hasActiveVerification;

  // Method to clear verification session
  @override
  void clearPhoneVerificationSession() {
    _phoneAuthService.clearVerificationSession();
  }

  @override
  Future<void> deleteUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _logger.error('User uid is unexpectedly null when deleting user data');
      return;
    }
    await FirebaseDatabase.instance.ref('/users/$uid').remove();
  }
}
