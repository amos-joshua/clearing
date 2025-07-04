import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class AppUser {
  final String phoneNumber;
  final String? email;
  final String displayName;
  final String uid;
  final String authToken;

  AppUser({
    required this.phoneNumber,
    this.email,
    required this.displayName,
    required this.uid,
    required this.authToken,
  });

  static Future<AppUser> fromFirebase(firebase_auth.User user) async {
    final authToken = await user.getIdToken();
    if (authToken == null) {
      throw Exception('Failed to get auth token for user ${user.uid}');
    }
    return AppUser(
      phoneNumber: user.phoneNumber ?? '',
      email: user.email,
      displayName: user.displayName ?? '',
      uid: user.uid,
      authToken: authToken,
    );
  }

  @override
  String toString() {
    return 'AppUser(email: $phoneNumber, displayName: $displayName, uid: $uid)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser &&
        other.phoneNumber == phoneNumber &&
        other.email == email &&
        other.displayName == displayName &&
        other.uid == uid;
  }

  @override
  int get hashCode => Object.hash(phoneNumber, email, displayName, uid);
}
