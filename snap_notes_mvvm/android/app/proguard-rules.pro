-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# Local notifications & receivers
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# App models / DTOs from obfuscation
-keep class com.example.snap_notes_mvvm.features.notifikasi.models.** { *; }
-keepclassmembers class com.example.snap_notes_mvvm.features.notifikasi.models.** { *; }
