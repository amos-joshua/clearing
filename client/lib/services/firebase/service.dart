import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart' show FirebaseDatabase;
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../features/app/config.dart';
import '../../features/call/model/call_event.dart';
import '../logging/logging_service.dart';

class FirebaseRemoteMessage {
  final CallEvent callEvent;
  final bool fromBackground;

  FirebaseRemoteMessage({
    required this.callEvent,
    required this.fromBackground,
  });

  static FirebaseRemoteMessage? parseFrom(
    Map<String, dynamic> data, {
    required bool fromBackground,
    required LoggingService logger,
  }) {
    try {
      final receiverDeviceTokenIds = data['receiver_device_token_ids'];
      if (receiverDeviceTokenIds is String) {
        try {
          final receiverDeviceTokenIdsList = jsonDecode(receiverDeviceTokenIds);
          data['receiver_device_token_ids'] = receiverDeviceTokenIdsList;
        } on FormatException catch (exc, stackTrace) {
          logger.warning(
            'Error parsing receiver device token ids from incoming call init: $exc\n$stackTrace',
          );
        }
      }
      final turnServers = data['turn_servers'];
      if (turnServers is String) {
        try {
          final turnServersList = jsonDecode(turnServers);
          data['turn_servers'] = turnServersList;
        } on FormatException catch (exc, stackTrace) {
          logger.warning(
            'Error parsing turn servers from incoming call init: $exc\n$stackTrace',
          );
        }
      }
      final callEvent = CallEvent.fromJson(data);
      return FirebaseRemoteMessage(
        callEvent: callEvent,
        fromBackground: fromBackground,
      );
    } catch (exc, stackTrace) {
      logger.warning(
        'Error parsing firebase message $data (fromBackground: $fromBackground): $exc\n$stackTrace',
      );
      return null;
    }
  }
}

abstract class FirebaseServiceBase {
  FirebaseAuth get firebaseAuth;
  Future<void> init();
  Future<List<String>> getDevices();
  Future<void> updateDevice(String deviceToken, String deviceName);
  Stream<FirebaseRemoteMessage> get firebaseMessageStream;
}

class FirebaseService implements FirebaseServiceBase {
  static const _firebaseAppName = 'FirebaseClearingApp';
  static const pushNotificationReceiverPortName =
      'push-notification-payload-receiver-port';
  final LoggingService _logger;
  final FirebaseConfig firebaseConfig;
  final pushNotificationReceiverPort = ReceivePort();
  final _firebaseMessageStreamController =
      StreamController<FirebaseRemoteMessage>.broadcast();
  late final FirebaseDatabase _firebaseDb;
  late final FirebaseAuth _firebaseAuth;

  @override
  FirebaseAuth get firebaseAuth => _firebaseAuth;

  @override
  Stream<FirebaseRemoteMessage> get firebaseMessageStream =>
      _firebaseMessageStreamController.stream;

  late final bool hasReceivedPushNotificationsPermissions;

  FirebaseService({
    required AppConfig appConfig,
    required LoggingService logger,
  }) : firebaseConfig = appConfig.firebaseConfig,
       _logger = logger;

  @override
  Future<void> init() async {
    final firebaseConfig = this.firebaseConfig;
    final appExists = Firebase.apps.any((app) => app.name == _firebaseAppName);
    final firebaseApp = switch (appExists) {
      true => Firebase.app(_firebaseAppName),
      false => await Firebase.initializeApp(
        name: _firebaseAppName,
        options: FirebaseConfig.firebaseOptions,
      ),
    };

    final notificationSettings = await FirebaseMessaging.instance
        .requestPermission(provisional: true);
    hasReceivedPushNotificationsPermissions = [
      AuthorizationStatus.authorized,
      AuthorizationStatus.provisional,
    ].contains(notificationSettings.authorizationStatus);

    _firebaseDb = FirebaseDatabase.instanceFor(
      app: firebaseApp,
      databaseURL: firebaseConfig.databaseUrl,
    );
    _firebaseAuth = FirebaseAuth.instanceFor(app: firebaseApp);
    if (firebaseConfig is FirebaseConfigEmulator) {
      await _firebaseAuth.useAuthEmulator(
        firebaseConfig.host,
        firebaseConfig.authPort,
      );
      _firebaseDb.useDatabaseEmulator(
        firebaseConfig.host,
        firebaseConfig.databasePort,
      );
    }

    IsolateNameServer.registerPortWithName(
      pushNotificationReceiverPort.sendPort,
      pushNotificationReceiverPortName,
    );
    pushNotificationReceiverPort.listen((dynamic data) {
      if (data is! Map<String, dynamic>) {
        _logger.warning(
          'Received invalid firebase message from push notification, expected a Map<String, dynamic> but got: ${data.runtimeType}: $data',
        );
        return;
      }
      final firebaseMessage = FirebaseRemoteMessage.parseFrom(
        data,
        logger: _logger,
        fromBackground: true,
      );
      if (firebaseMessage != null) {
        _firebaseMessageStreamController.add(firebaseMessage);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final firebaseMessage = FirebaseRemoteMessage.parseFrom(
        message.data,
        logger: _logger,
        fromBackground: false,
      );
      if (firebaseMessage != null) {
        _firebaseMessageStreamController.add(firebaseMessage);
      }
    });
  }

  @override
  Future<List<String>> getDevices() async {
    final uid = _firebaseAuth.currentUser?.uid;

    if (uid == null) {
      _logger.error(
        'User uid is unexpectedly null when retrieving devices from firebase',
      );
      return [];
    }

    final userDevicesPath = '/users/$uid/devices';
    final userDevicesRef = _firebaseDb.ref(userDevicesPath);
    final userDevicesSnapshot = await userDevicesRef.get();
    final userDevicesMap = userDevicesSnapshot.value as Map;
    final userDevices = userDevicesMap.values.map((value) => '$value').toList();
    return userDevices;
  }

  @override
  Future<void> updateDevice(String deviceToken, String deviceName) async {
    final uid = _firebaseAuth.currentUser?.uid;
    final userDevicesPath = '/users/$uid/devices';
    final userDevicesRef = _firebaseDb.ref(userDevicesPath);
    await userDevicesRef.update({deviceToken: deviceName});
  }
}

class FirebaseServiceMock implements FirebaseServiceBase {
  @override
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @override
  Future<void> init() async {
    print('mock initializing firebase');
  }

  @override
  Future<List<String>> getDevices() async {
    return ['device1', 'device2', 'device3'];
  }

  @override
  Future<void> updateDevice(String deviceToken, String deviceName) async {
    print('mock updating device $deviceToken with name $deviceName');
  }

  @override
  Stream<FirebaseRemoteMessage> get firebaseMessageStream =>
      const Stream.empty();
}
