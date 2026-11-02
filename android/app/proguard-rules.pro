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

# Keep receive_intent classes
-keep class com.bhikadia.receive_intent.** { *; }

# Keep shared_preferences classes
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Keep dynamic_color classes
-keep class io.material.materialcolorplugin.** { *; }

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
