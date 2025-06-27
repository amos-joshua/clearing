import 'package:flutter/material.dart';
import 'features/app/config.dart';
import 'features/auth/widgets/auth_protected_widget.dart';
import 'pages/root_page.dart';
import 'dependencies.dart';
import 'pages/splash_loading_page.dart';

void main() {
  runApp(const ClearingAppContactless());
}

class ClearingAppContactless extends StatelessWidget {
  const ClearingAppContactless({super.key});
  final title = 'ClearRing';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: AppDependencies(
        appConfig: AppConfig.configFromEnv,
        mockStorage: true,
        mockContacts: true,
        splashScreen: const SplashLoadingPage(),
        child: AuthProtected(
          loggedInBuilder: (context) =>
              RootPage(title: title, diagnosticCallWithoutContacts: true),
        ),
      ),
    );
  }
}
