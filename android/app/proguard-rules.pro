# Flutter ProGuard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep file picker
-keep class com.mr.flutter.plugin.filepicker.** { *; }

# Keep shared preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Keep URL launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

# Keep path provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# Keep file saver
-keep class com.incrediblezayed.file_saver.** { *; }

# Keep permission handler
-keep class com.baseflow.permissionhandler.** { *; }

# Keep device info plus
-keep class dev.fluttercommunity.plus.device_info.** { *; }

# Keep Kotlin metadata
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**

# Keep local classes
-keep class com.heinci.height4kid.** { *; }

# General rules
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# R8 missing rules
-dontwarn javax.xml.stream.XMLStreamException
-dontwarn org.codehaus.mojo.animal_sniffer.IgnoreJRERequirement

# Google Play Core (deferred components)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
