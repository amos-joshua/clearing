import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../bloc.dart';
import '../model/login_method.dart';

class GoogleLoginButton extends StatelessWidget {
  const GoogleLoginButton({super.key});

  void _handleGoogleLogin(BuildContext context) {
    context.read<AuthBloc>().add(AuthEvent.login(LoginMethodGoogle()));
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthStateSignedOut) {
      return const Text(
        "ERROR: Google login button should only be shown when signed out",
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: authState.isLoggingIn
                    ? null
                    : () => _handleGoogleLogin(context),
                icon: authState.isLoggingIn
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : const Icon(Icons.login),
                label: authState.isLoggingIn
                    ? Shimmer.fromColors(
                        baseColor: Colors.black12,
                        highlightColor: Colors.white,
                        child: const Text('Signing in...'),
                      )
                    : const Text('Sign in with Gmail'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
