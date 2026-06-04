plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 百度网盘 SDK 仓库配置
repositories {
    google()
    mavenCentral()
    maven { url = uri("https://repo1.maven.org/maven2") }
}

android {
    namespace = "com.heinci.height4kid"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    defaultConfig {
        applicationId = "com.heinci.height4kid"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = "height4kid"
            keyPassword = "height4kid2024"
            storeFile = file("height4kid-release-key.jks")
            storePassword = "height4kid2024"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_21
    }
}

flutter {
    source = "../.."
}

dependencies {
    // 百度网盘 SDK 需要手动下载集成
    // 目前使用 OAuth2 网页授权方式
    // 如需 SDK 方式，请从百度开放平台下载 SDK 并放入 libs 目录
}
