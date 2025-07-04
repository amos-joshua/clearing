import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthBloc>();
    final authState = auth.state;
    if (authState is! AuthStateSignedIn) {
      throw "Logout button should only be shown when signed in";
    }

    final currentPhoneNumber = switch (authState.currentUser.phoneNumber) {
      String number when number.isEmpty => '(no number registered)',
      String number => number,
    };
    return ElevatedButton.icon(
      onPressed: () => auth.add(const Logout()),
      icon: const Icon(Icons.logout),
      label: Text(currentPhoneNumber),
      iconAlignment: IconAlignment.end,
    );
  }
}
