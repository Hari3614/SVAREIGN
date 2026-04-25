# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.BuildConfig { *; }
-keep class io.flutter.embedding.**  { *; }
-keep class androidx.lifecycle.DefaultLifecycleObserver

# Flutter packages
-keep class com.razorpay.** { *; }
-keepattributes InnerClasses

# AndroidX
-dontwarn androidx.**
-keep class androidx.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class org.apache.http.** { *; }
-dontwarn com.google.firebase.**

# Google Play Services
-keep class com.google.android.gms.** { *; }
-keep class com.google.android.play.** { *; }
-dontwarn com.google.android.gms.**
-dontwarn com.google.android.play.**

# Smart Auth
-keep class fman.ge.smart_auth.** { *; }

# Other packages
-keep class com.google.gson.** { *; }
-keep class com.google.common.** { *; }

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep reflection-related classes
-keep class java.lang.reflect.AnnotatedType
-keep class java.lang.reflect.**

# Suppress warnings for missing classes
-dontwarn java.lang.reflect.AnnotatedType