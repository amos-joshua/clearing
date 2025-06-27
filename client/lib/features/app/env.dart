const envEnvironment = String.fromEnvironment(
  'CLEARING_ENVIRONMENT',
  defaultValue: 'dev',
);

const envSwitchboardSslEnabled = bool.fromEnvironment(
  'CLEARING_SERVER_DEV_SSL_ENABLED',
  defaultValue: false,
);

const envSwitchboardHost = String.fromEnvironment(
  'CLEARING_SERVER_DEV_HOST',
  defaultValue: 'localhost',
);

const envSwitchboardPort = int.fromEnvironment(
  'CLEARING_SERVER_DEV_PORT',
  defaultValue: 0,
);

const envFirebaseUseEmulator = bool.fromEnvironment(
  'CLEARING_FIREBASE_USE_EMULATOR',
  defaultValue: false,
);

const envFirebaseDatabaseUrl = String.fromEnvironment(
  'CLEARING_FIREBASE_DATABASE_URL',
  defaultValue: 'https://clearing-server-staging.swiftllama.net',
);

const envFirebaseEmulatorAuthPort = int.fromEnvironment(
  'CLEARING_FIREBASE_EMULATOR_AUTH_PORT',
  defaultValue: 0,
);

const envFirebaseEmulatorDatabasePort = int.fromEnvironment(
  'CLEARING_FIREBASE_EMULATOR_DATABASE_PORT',
  defaultValue: 0,
);

const envFirebaseEmulatorNamespace = String.fromEnvironment(
  'CLEARING_FIREBASE_EMULATOR_NAMESPACE',
  defaultValue: '',
);

const envFirebaseApiKeyWeb = String.fromEnvironment(
  'CLEARING_FIREBASE_API_KEY_WEB',
  defaultValue: '',
);

const envFirebaseAppIdWeb = String.fromEnvironment(
  'CLEARING_FIREBASE_APP_ID_WEB',
  defaultValue: '',
);

const envFirebaseApiKeyAndroid = String.fromEnvironment(
  'CLEARING_FIREBASE_API_KEY_ANDROID',
  defaultValue: '',
);

const envFirebaseAppIdAndroid = String.fromEnvironment(
  'CLEARING_FIREBASE_APP_ID_ANDROID',
  defaultValue: '',
);

const envFirebaseMessageSenderId = String.fromEnvironment(
  'CLEARING_FIREBASE_MESSAGE_SENDER_ID',
  defaultValue: '',
);

const envFirebaseProjectId = String.fromEnvironment(
  'CLEARING_FIREBASE_PROJECT_ID',
  defaultValue: '',
);

const envFirebaseStorageBucket = String.fromEnvironment(
  'CLEARING_FIREBASE_STORAGE_BUCKET',
  defaultValue: '',
);