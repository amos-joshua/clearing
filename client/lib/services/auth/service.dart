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

abstract class AuthServiceBase {
  Future<void> init(RuntimeParameters runtimeParameters);
  Future<AppUser?> loadCurrentUser();
  Future<void> logout();
  Future<void> login(LoginMethod loginMethod);
  Future<void> deleteUserData();
}

class AuthServiceMock implements AuthServiceBase {
  @override
  Future<void> init(RuntimeParameters runtimeParameters) async {}

  AppUser? currentUser = AppUser(
    email: 'test@test.com',
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
      email: 'test@example.com',
      displayName: 'Test User',
      uid: 'test-user-id',
      authToken: 'test-token',
    );
  }

  @override
  Future<void> deleteUserData() async {
    currentUser = null;
  }
}

class AuthServiceFirebase implements AuthServiceBase {
  final FirebaseServiceBase _firebaseService;
  FirebaseAuth get _auth => _firebaseService.firebaseAuth;

  final LoggingService _logger;
  late final RuntimeParameters _runtimeParameters;

  AuthServiceFirebase(this._logger, this._firebaseService);

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
        default:
          throw Exception('An error occurred during login.');
      }
    }
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
