import 'dart:ui';

import 'package:clearing_client/features/auth/widgets/auth_protected_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:relative_time/relative_time.dart';
import 'features/app/config.dart';
import 'dependencies.dart';
import 'pages/splash_loading_page.dart';
import 'routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const ClearingApp());
}

class ClearingApp extends StatelessWidget {
  const ClearingApp({super.key});
  final title = 'Clearing';

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.configFromEnv;

    return AppDependencies(
      appConfig: config,
      splashScreen: const SplashLoadingPage(),
      child: _banner(
        config,
        child: AuthProtected(
          loggedInBuilder: (context) => MaterialApp.router(
            localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
              RelativeTimeLocalizations.delegate,
            ],
            routerConfig: appRouter,
          ),
        ),
      ),
    );
  }

  Widget _banner(AppConfig config, {required Widget child}) {
    if (config.isProd && !kDebugMode) {
      return child;
    }
    final message = kDebugMode
        ? '${config.environment} - dbg'
        : config.environment;
    final color = switch (config.environment) {
      'staging' => Colors.green,
      'dev' => Colors.red,
      _ => Colors.blue,
    };
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Banner(
        message: message,
        location: BannerLocation.topEnd,
        child: child,
        color: color,
      ),
    );
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final send = IsolateNameServer.lookupPortByName(
    'push-notification-payload-receiver-port',
  );
  send?.send(message.data);
}
