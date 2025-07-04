import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../logging/logging_service.dart';

class PhoneAuthService {
  final FirebaseAuth _auth;
  final LoggingService _logger;
  String? _verificationId;
  int? _resendToken;

  PhoneAuthService(this._auth, this._logger);

  Future<UserCredential?> sendVerificationCode(String phoneNumber) async {
    final result = await _verifyPhoneNumber(
      phoneNumber: phoneNumber,
      isResend: false,
      resendToken: null,
    );
    return result;
  }

  Future<UserCredential> verifyCode(String smsCode) async {
    if (_verificationId == null) {
      throw Exception(
        'No verification session active. Please send a verification code first.',
      );
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      _logger.error('Error verifying SMS code', e);
      rethrow;
    }
  }

  Future<UserCredential?> resendCode(String phoneNumber) async {
    if (_resendToken == null) {
      throw Exception(
        'No resend token available. Please send a new verification code.',
      );
    }

    return await _verifyPhoneNumber(
      phoneNumber: phoneNumber,
      isResend: true,
      resendToken: _resendToken,
    );
  }

  Future<UserCredential?> _verifyPhoneNumber({
    required String phoneNumber,
    required bool isResend,
    int? resendToken,
  }) async {
    final completer = Completer<UserCredential?>();
    final action = isResend ? 'resending' : 'sending';

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          _logger.info('Phone verification auto-completed for $phoneNumber');
          final userCredential = await _auth.signInWithCredential(credential);
          if (!completer.isCompleted) {
            completer.complete(userCredential);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          _logger.error(
            'Phone verification failed for $phoneNumber: ${e.message}',
            e,
          );
          if (!completer.isCompleted) {
            completer.completeError(
              Exception('Phone verification failed: ${e.message}'),
            );
          }
        },
        codeSent: (String verificationId, int? newResendToken) {
          _verificationId = verificationId;
          _resendToken = newResendToken;
          _logger.info(
            'SMS code ${isResend ? 'resent' : 'sent'} to $phoneNumber',
          );
          if (!completer.isCompleted) {
            completer.complete(null); // Manual verification needed
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _logger.warning('SMS code auto-retrieval timeout for $phoneNumber');
          if (!completer.isCompleted) {
            completer.completeError(
              Exception('SMS code auto-retrieval timeout'),
            );
          }
        },
        forceResendingToken: resendToken,
        timeout: const Duration(seconds: 60),
      );

      return await completer.future;
    } catch (e) {
      _logger.error('Error $action verification code to $phoneNumber', e);
      rethrow;
    }
  }

  void clearVerificationSession() {
    _verificationId = null;
    _resendToken = null;
  }

  bool get hasActiveVerification => _verificationId != null;
}
