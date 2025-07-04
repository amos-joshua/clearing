import 'package:clearing_client/repositories/contacts/all.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/app/service_initializer.dart';
import 'features/auth/bloc.dart';
import 'services/auth/service.dart';

import 'features/app/config.dart';
import 'features/call/bloc/cubit.dart';
import 'features/devices/bloc/cubit.dart';
import 'features/groups/bloc/cubit.dart';
import 'features/presets/bloc/cubit.dart';
import 'features/presets/model/preset.dart';
import 'features/settings/bloc/bloc.dart';
import 'services/app_services.dart';
import 'services/contacts/native.dart';
import 'services/contacts/phone_contacts.dart';
import 'services/firebase/service.dart';
import 'services/logging/logging_service.dart';
import 'services/storage/in_memory.dart';
import 'services/storage/persistent_storage.dart';
import 'services/storage/storage.dart';

class AppDependencies extends StatelessWidget {
  final Widget child;
  final Widget splashScreen;
  final AppConfig appConfig;
  final bool mockFirebase;
  final bool mockStorage;
  final bool mockContacts;

  AppDependencies({
    super.key,
    required this.child,
    required this.splashScreen,
    required this.appConfig,
    this.mockFirebase = false,
    this.mockStorage = false,
    this.mockContacts = false,
  });

  late final LoggingService _loggingService = LogManager();

  AuthServiceBase authRepository() => switch (mockFirebase) {
    true => AuthServiceMock(),
    false => AuthServiceFirebase(_loggingService, _firebaseService),
  };

  late final FirebaseServiceBase _firebaseService = switch (mockFirebase) {
    true => FirebaseServiceMock(),
    false => FirebaseService(appConfig: appConfig, logger: _loggingService),
  };

  Storage storage() => switch (mockStorage) {
    true => InMemoryStorage(),
    false => PersistentStorage(logger: _loggingService),
  };

  PhoneContactsService contactsService() => switch (mockContacts) {
    true => PhoneContactsServiceMock(),
    false => PhoneContactsServiceNative(logger: _loggingService),
  };

  @override
  Widget build(BuildContext context) {
    final appServices = AppServices(
      appConfig: appConfig,
      logger: _loggingService,
      firebaseService: _firebaseService,
      storage: storage(),
      contactsService: contactsService(),
      authService: authRepository(),
    );

    return ServiceInitializer(
      appServices: appServices,
      splashScreen: splashScreen,
      builder: (context) {
        return MultiBlocProvider(
          providers: [
            AuthBloc.provider(appServices.authService, _loggingService),
            RepositoryProvider<AuthServiceBase>.value(
              value: appServices.authService,
            ),
            BlocProvider(
              create: (context) => AppSettingsCubit(
                database: appServices.database,
                nativeNotifications: appServices.nativeNotifications,
                activePresetData: ActivePresetData.defaultPresetData(),
              )..determineActivePreset(),
            ),
            BlocProvider(
              create: (context) =>
                  GroupsCubit(database: appServices.database)..list(''),
            ),
            BlocProvider(
              create: (context) => PresetsCubit(
                database: appServices.database,
                nativeNotifications: appServices.nativeNotifications,
              )..list(),
            ),
            BlocProvider(
              create: (context) =>
                  DevicesCubit(appServices.firebaseService, appServices.logger),
            ),
            BlocProvider(
              create: (context) =>
                  CallsCubit(database: appServices.database)..list(),
            ),
          ],
          child: MultiRepositoryProvider(
            providers: [
              RepositoryProvider.value(value: appConfig),
              RepositoryProvider.value(value: appServices.logger),
              RepositoryProvider.value(value: appServices.contactsService),
              RepositoryProvider(
                create: (context) => AllContactsRepository(appServices.storage),
              ),
              RepositoryProvider(create: (context) => appServices.database),
              RepositoryProvider(
                create: (context) => appServices.nativeNotifications,
              ),
              RepositoryProvider.value(value: appServices.runtimeParameters),
              RepositoryProvider.value(value: appServices.activeCallService),
              RepositoryProvider.value(value: appServices.firebaseService),
            ],
            child: child,
          ),
        );
      },
    );
  }
}
