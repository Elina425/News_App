import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.compose)
    id("org.jetbrains.kotlin.plugin.serialization")
}

android {
    namespace = "com.example.android_project"
    compileSdk = 36

    packaging {
        // Exclude the specific binary that is not 16KB page-aligned
        resources.excludes.add("dump_syms/**")
    }

    defaultConfig {
        applicationId = "com.example.android_project"
        minSdk = 24
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlin {
        compilerOptions {
            jvmTarget.set(JvmTarget.JVM_11)
        }
    }
    buildFeatures {
        compose = true
    }
}

dependencies {

    // ANDROIDX & COMPOSE FOUNDATION
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.lifecycle.runtime.ktx)
    implementation(libs.androidx.activity.compose)
    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.compose.ui)
    implementation(libs.androidx.compose.ui.graphics)
    implementation(libs.androidx.compose.ui.tooling.preview)

    // COMPOSE MATERIAL (Material 3 for most UI)
    implementation(libs.androidx.compose.material3)
    implementation("androidx.compose.material3:material3:1.4.0") // Specific M3 version

    // COMPOSE PULL REFRESH (Material 1.x for Pull-to-Refresh Component)
    implementation("androidx.compose.material:material-android:1.9.5")

    // KTOR NETWORK CLIENT (API calls)
    implementation("io.ktor:ktor-client-core:3.3.2")
    implementation("io.ktor:ktor-client-android:3.3.2")
    implementation("io.ktor:ktor-client-content-negotiation:3.3.2")
    implementation("io.ktor:ktor-serialization-kotlinx-json:3.3.2")

    // COIL (Image Loading)
    implementation("io.coil-kt:coil-compose:2.7.0")

    // LIFECYCLE & VIEWMODEL (MVVM State Management)
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.10.0")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.10.0")
    implementation(libs.firebase.crashlytics.buildtools)
    implementation(libs.androidx.compose.foundation)

    // TESTING (Standard)
    testImplementation(libs.junit)
    androidTestImplementation(libs.androidx.junit)
    androidTestImplementation(libs.androidx.espresso.core)
    androidTestImplementation(platform(libs.androidx.compose.bom))
    androidTestImplementation(libs.androidx.compose.ui.test.junit4)
    debugImplementation(libs.androidx.compose.ui.tooling)
    debugImplementation(libs.androidx.compose.ui.test.manifest)
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.10.2")
    implementation("androidx.compose.material:material-icons-extended")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.10.0")
}