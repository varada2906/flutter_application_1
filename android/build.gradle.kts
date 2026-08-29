// android/build.gradle.kts

buildscript {
    // Update Kotlin version if needed
    ext.set("kotlin_version", "1.9.22")
    
    repositories {
        google()
        mavenCentral()
    }
    
    dependencies {
        // Update to Android Gradle Plugin 8.9.1
        classpath("com.android.tools.build:gradle:8.9.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:${ext.get("kotlin_version")}")
        // If using Firebase
        classpath("com.google.gms:google-services:4.4.2")
    }
}

// Your existing allprojects block
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}