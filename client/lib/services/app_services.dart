import 'package:clearing_client/services/storage/database.dart';

import '../features/auth/model/app_user.dart';
import '../features/app/config.dart';
import 'auth/service.dart';
import 'active_call/active_call.dart';
import 'contacts/phone_contacts.dart';
import 'firebase/service.dart';
import 'first_time_initializer/first_time_initializer.dart';
import 'logging/logging_service.dart';
import 'notifications/native.dart';
import 'runtime_parameters/service.dart';
import 'storage/storage.dart';

class AppServices {
  final AppConfig appConfig;
  final LoggingService logger;
  final FirebaseServiceBase firebaseService;
  final Storage storage;
  final runtimeParametersService = RuntimeParametersService();
  final PhoneContactsService contactsService;
  final Database database;
  late final NativeNotifications nativeNotifications = NativeNotifications(
    database: database,
  );
  final AuthServiceBase authService;
  final firstTimeInitializer = FirstTimeInitializer();
  late final activeCallService = ActiveCallService(
    appConfig: appConfig,
    logger: logger,
    firebaseService: firebaseService,
    database: database,
    nativeNotifications: nativeNotifications,
  );

  RuntimeParameters get runtimeParameters =>
      runtimeParametersService.runtimeParameters;

  AppServices({
    required this.appConfig,
    required this.logger,
    required this.firebaseService,
    required this.storage,
    required this.contactsService,
    required this.authService,
  }) : database = Database(storage);

  Future<bool> init() async {
    try {
      logger.info('Initializing app services');
      await runtimeParametersService.init(logger: logger);
      await firebaseService.init();
      await storage.initialize(
        runtimeParametersService.runtimeParameters.supportDirectory,
      );
      await database.init();
      await nativeNotifications.init();
      await contactsService.init(storage);
      await firstTimeInitializer.init(
        database: database,
        runtimeParameters: runtimeParameters,
      );
      await authService.init(runtimeParameters);
      logger.info('App services initialized');
      return true;
    } catch (exc, stackTrace) {
      logger.error('Failed to initialize services', exc, stackTrace);
      print('Failed to initialize services: $exc\n$stackTrace');
      return false;
    }
  }
}

class AppStartupData {
  AppUser? loggedInUser;
}
