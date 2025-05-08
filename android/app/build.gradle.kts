plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.todo_list"
    compileSdk = flutter.compileSdkVersion

    // ✅ Force required NDK version (Fixes NDK version mismatch)
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.todo_list"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // ✅ Java 11 compatibility
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11

        // ✅ Enable core library desugaring
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ Add this to support flutter_local_notifications

    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:1.2.2")

}
