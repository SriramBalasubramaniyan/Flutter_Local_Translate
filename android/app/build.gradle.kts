plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.flutter_local_translate"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    androidResources {
        noCompress += listOf("so", "tflite", "litertlm")
    }

    defaultConfig {
        applicationId = "com.example.flutter_local_translate"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        ndk {
            abiFilters += setOf("arm64-v8a")
        }
    }

    packagingOptions {
        jniLibs {
            useLegacyPackaging = true
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

configurations.all {
    exclude(group = "com.google.ai.edge.litertlm", module = "litertlm-android")
}

dependencies {
    implementation("com.google.ai.edge.litertlm:litertlm-android:0.1.1")
}

flutter {
    source = "../.."
}