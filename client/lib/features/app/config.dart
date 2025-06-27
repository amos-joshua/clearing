import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

import 'env.dart';

class AppConfig {
  final String environment;
  final String host;
  final int port;
  final bool sslEnabled;
  final FirebaseConfig firebaseConfig;

  AppConfig({
    required this.environment,
    required this.host,
    required this.port,
    required this.sslEnabled,
    required this.firebaseConfig,
  });

  String callEndpoint({required String callUuid}) =>
      '$_baseWebsocketURL/call/$callUuid';
  String answerEndpoint({required String callUuid}) =>
      '$_baseWebsocketURL/answer/$callUuid';
  String rejectEndpoint({required String callUuid}) =>
      '$_baseHttpURL/reject/$callUuid';

  String get _baseWebsocketURL =>
      sslEnabled ? 'wss://$host:$port' : 'ws://$host:$port';
  String get _baseHttpURL =>
      sslEnabled ? 'https://$host:$port' : 'http://$host:$port';

  bool get isDev => environment == 'dev';
  bool get isStaging => environment == 'staging';
  bool get isProd => environment == 'prod';

  static AppConfig configFromEnv = AppConfig(
    environment: envEnvironment,
    host: envSwitchboardHost,
    port: envSwitchboardPort,
    sslEnabled: envSwitchboardSslEnabled,
    firebaseConfig: FirebaseConfig.configFromEnv,
  );
}

sealed class FirebaseConfig {
  bool get useEmulator => false;
  String get databaseUrl => '';

  static FirebaseConfig configFromEnv = envFirebaseUseEmulator
      ? FirebaseConfigEmulator(
          host: envSwitchboardHost,
          authPort: envFirebaseEmulatorAuthPort,
          databasePort: envFirebaseEmulatorDatabasePort,
          namespace: envFirebaseEmulatorNamespace,
        )
      : FirebaseConfigCloud(databaseUrl: envFirebaseDatabaseUrl);

  static const firebaseOptionsWeb = FirebaseOptions(
    apiKey: envFirebaseApiKeyWeb,
    appId: envFirebaseAppIdWeb,
    messagingSenderId: envFirebaseMessageSenderId,
    projectId: envFirebaseProjectId,
    databaseURL: envFirebaseDatabaseUrl,
    storageBucket: envFirebaseStorageBucket,
  );

  static const firebaseOptionsAndroid = FirebaseOptions(
    apiKey: envFirebaseApiKeyAndroid,
    appId: envFirebaseAppIdAndroid,
    messagingSenderId: envFirebaseMessageSenderId,
    projectId: envFirebaseProjectId,
    databaseURL: envFirebaseDatabaseUrl,
    storageBucket: envFirebaseStorageBucket,
  );

  static FirebaseOptions get firebaseOptions {
    if (kIsWeb) {
      return firebaseOptionsWeb;
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => firebaseOptionsAndroid,
      _ => throw UnimplementedError(
        'firebase options not defined for platform $defaultTargetPlatform',
      ),
    };
  }
}

class FirebaseConfigEmulator extends FirebaseConfig {
  final String host;
  final int authPort;
  final int databasePort;
  final String namespace;

  FirebaseConfigEmulator({
    required this.host,
    required this.authPort,
    required this.databasePort,
    required this.namespace,
  });

  @override
  bool get useEmulator => true;

  @override
  String get databaseUrl => 'http://$host:$databasePort?ns=$namespace';
}

class FirebaseConfigCloud extends FirebaseConfig {
  final String _databaseUrl;

  FirebaseConfigCloud({required String databaseUrl})
    : _databaseUrl = databaseUrl;

  @override
  String get databaseUrl => _databaseUrl;
}
