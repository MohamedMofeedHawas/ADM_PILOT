# ADM Pilot App — Android Setup

## android/app/src/main/AndroidManifest.xml
Add these permissions inside <manifest>:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.INTERNET" />

<uses-feature android:name="android.hardware.camera" android:required="false" />
```

## android/app/build.gradle
Set minSdkVersion to 21:
```gradle
defaultConfig {
    minSdkVersion 21
    targetSdkVersion 34
}
```

## ios/Runner/Info.plist
Add these keys:
```xml
<key>NSCameraUsageDescription</key>
<string>ADM Pilot needs camera access for stress analysis</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>ADM Pilot needs photo library access to save reports</string>
```
