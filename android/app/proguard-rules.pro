# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Flutter engine
-keep class io.flutter.embedding.** { *; }

# WebView - keep JavaScript interface methods
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep webview_flutter classes
-keep class io.flutter.plugins.webviewflutter.** { *; }

# Keep share_plus classes
-keep class dev.fluttercommunity.plus.share.** { *; }

# Keep url_launcher classes
-keep class io.flutter.plugins.urllauncher.** { *; }

# Keep listen_sharing_intent classes
-keep class com.kasem.receive_sharing_intent.** { *; }

# Keep shared_preferences classes
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Keep dynamic_color classes
-keep class io.material.materialcolorplugin.** { *; }

# Keep Google Fonts (if using HTTP to fetch fonts)
-keep class com.google.android.gms.** { *; }

# Suppress warnings for missing classes
-dontwarn com.google.android.gms.**
-dontwarn io.flutter.embedding.**

# Keep Kotlin metadata
-keep class kotlin.Metadata { *; }
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}

# Keep annotation classes
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
