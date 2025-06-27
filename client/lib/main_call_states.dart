import 'package:flutter/material.dart';
import 'features/app/config.dart';
import 'pages/diagnostic/call_states_page.dart';
import 'dependencies.dart';
import 'pages/splash_loading_page.dart';

void main() {
  runApp(const CallStatesApp());
}

class CallStatesApp extends StatelessWidget {
  const CallStatesApp({super.key});
  final title = 'Clearing - Call States';
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: AppDependencies(
        appConfig: AppConfig.configFromEnv,
        mockFirebase: true,
        splashScreen: const SplashLoadingPage(),
        child: const DiagnosticsCallStatesPage(),
      ),
    );
  }
}
