sealed class LoginMethod {
  String logInfo();
}

class LoginMethodEmailPassword extends LoginMethod {
  final String email;
  final String password;

  @override
  String logInfo() => 'email: $email';

  LoginMethodEmailPassword({required this.email, required this.password});
}

class LoginMethodGoogle extends LoginMethod {
  @override
  String logInfo() => 'google signin';
}
