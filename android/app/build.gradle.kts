plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.flutter_application_1"
    compileSdk = 35  // Use explicit version instead of flutter.compileSdkVersion
    ndkVersion = "27.3.13750724"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17  // Changed to 17
        targetCompatibility = JavaVersion.VERSION_17  // Changed to 17
    }

    kotlinOptions {
        jvmTarget = "17"  // Changed to 17
    }

    defaultConfig {
        applicationId = "com.example.flutter_application_1"
        minSdk = flutter.minSdkVersion  // Explicit version (or flutter.minSdkVersion)
        targetSdk = 35  // Explicit version (or flutter.targetSdkVersion)
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:34.5.0"))
    // Add your Firebase dependencies here
    // implementation("com.google.firebase:firebase-analytics")
    // implementation("com.google.firebase:firebase-auth")
    // etc.
}
