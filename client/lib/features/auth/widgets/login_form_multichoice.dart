import 'package:clearing_client/features/auth/widgets/email_password_login_form.dart';
import 'package:flutter/material.dart';

import 'google_login_button.dart';

class LoginFormMultichoice extends StatelessWidget {
  const LoginFormMultichoice({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        EmailPasswordLoginForm(),
        Divider(),
        GoogleLoginButton(),
      ],
    );
  }
}