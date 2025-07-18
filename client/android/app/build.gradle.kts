import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}


val localProperties = Properties().apply {
    val localPropertiesFile = rootProject.file("local.properties")
    if (localPropertiesFile.exists()) {
        localPropertiesFile.inputStream().use { load(it) }
    }
}

android {
    namespace = "net.swiftllama.clearing_client"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "net.swiftllama.clearing_client"
        minSdk = 23 //flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        getByName("debug") {
            val keystorePath = localProperties.getProperty("CLEARING_DEBUG_KEYSTORE") ?: "unknown-dbg-keystore"
            storeFile = file("${rootDir}/${keystorePath}")
            storePassword = localProperties.getProperty("CLEARING_DEBUG_KEYSTORE_PASSWORD") ?: ""
            keyAlias = localProperties.getProperty("CLEARING_DEBUG_KEYSTORE_ALIAS") ?: "unknown-alias"
            keyPassword = localProperties.getProperty("CLEARING_DEBUG_KEYSTORE_KEY_PASSWORD") ?: ""
        }
        create("release") {
            val keystorePath = localProperties.getProperty("CLEARING_RELEASE_KEYSTORE") ?: "unknown-release-keystore"
            storeFile = file("${rootDir}/${keystorePath}")
            storePassword = localProperties.getProperty("CLEARING_RELEASE_KEYSTORE_PASSWORD") ?: ""
            keyAlias = localProperties.getProperty("CLEARING_RELEASE_KEYSTORE_ALIAS") ?: "unknown-alias"
            keyPassword = localProperties.getProperty("CLEARING_RELEASE_KEYSTORE_KEY_PASSWORD") ?: ""
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
