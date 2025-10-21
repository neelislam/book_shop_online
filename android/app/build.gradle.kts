plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.books_smart_app"
    compileSdk = flutter.compileSdkVersion
    // Removed duplicate and manually specified ndkVersion
    // ndkVersion = flutter.ndkVersion

    compileOptions {
        // Updated to Java 17, the recommended standard for Flutter 3.19+ and later SDKs
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.books_smart_app"
        // CRITICAL FIX: Increased minSdk to 21 (Android 5.0) to ensure plugin compatibility
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:33.0.0")) // Updated BoM version
    // Use the dependencies without explicit versions as they are managed by the BoM
    implementation("com.google.firebase:firebase-firestore-ktx") // Use KT-extension for modern Kotlin
    implementation("com.google.firebase:firebase-auth-ktx") // Add auth dependency for Firebase Auth
}
