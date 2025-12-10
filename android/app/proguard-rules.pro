# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Play Core (para el error que tienes)
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.** { *; }

# Google Play Services
-keep class com.google.android.gms.** { *; }
-keep interface com.google.android.gms.** { *; }

# Sqflite
-keep class com.tekartik.sqflite.** { *; }

# Shared Preferences
-keep class com.example.shared_preferences.** { *; }

# Para mantener métodos nativos
-keepclasseswithmembernames class * {
    native <methods>;
}

# Para mantener atributos de serialización
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod

# Para mantener clases de Kotlin
-keep class kotlin.** { *; }
-dontwarn kotlin.**

# Para mantener clases de AndroidX
-keep class androidx.** { *; }
-dontwarn androidx.**

# Para mantener clases de Google
-keep class com.google.** { *; }
-dontwarn com.google.**
