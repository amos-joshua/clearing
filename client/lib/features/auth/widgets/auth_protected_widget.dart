import 'package:clearing_client/features/auth/widgets/login_form_multichoice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../services/logging/widgets/log_viewer_button.dart';
import '../../../utils/widgets/loading_handset_spinner.dart';
import '../bloc.dart';
import '../model/app_user.dart';

class AuthProtected extends StatelessWidget {
  final Widget Function(BuildContext context) loggedInBuilder;

  const AuthProtected({super.key, required this.loggedInBuilder});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    return MaterialApp(
      home: switch (authState) {
        AuthStateSignedIn() => loggedInBuilder(context),
        AuthStateCheckingInitialAuth() => loadingWidget(),
        AuthStateSignedOut() => loginWidget(),
      },
    );
  }

  Widget loggedInWidget(BuildContext context, AppUser currentUser) =>
      RepositoryProvider.value(
        value: currentUser,
        child: loggedInBuilder(context),
      );

  Widget loadingWidget() => _scaffold(
    child: const Padding(
      padding: EdgeInsets.only(top: 64.0),
      child: LoadingHandsetSpinner(),
    ),
  );

  Widget loginWidget() => _scaffold(child: const LoginFormMultichoice());

  Widget _scaffold({required Widget child}) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Align(
              alignment: Alignment.centerRight,
              child: LogViewerButton(),
            ),
            Image.asset('assets/images/logo-512.png'),
            child,
          ],
        ),
      ),
    );
  }
}
