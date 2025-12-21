plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.todo_work_sessions"
    
    // MIS À JOUR : Passage à 36 pour satisfaire les dépendances récentes
    compileSdk = 36 
    ndkVersion = flutter.ndkVersion 

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        
        // Active le support des fonctions Java 8+ pour les anciens appareils
        isCoreLibraryDesugaringEnabled = true 
    }

    kotlinOptions {
        jvmTarget = "17" 
    }

    defaultConfig {
        applicationId = "com.example.todo_work_sessions"
        
        // FIX : Forcé à 21 pour assurer le support de coreLibraryDesugaring
        minSdk = flutter.minSdkVersion 
        
        // MIS À JOUR : Doit correspondre au compileSdk pour éviter les conflits
        targetSdk = 36 
        
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Nécessaire car le projet dépasse la limite des 64k méthodes (Multidex)
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // Pour tester ton APK release sans clé de signature privée pour l'instant
            signingConfig = signingConfigs.getByName("debug")
            
            // Optimisations optionnelles
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

dependencies {
    // Permet d'utiliser des fonctionnalités Java modernes sur des versions Android anciennes
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
