# 📱 APK Build Guide

## Prerequisites
- Flutter SDK installed
- Android Studio installed
- Android SDK configured

## 🔧 Step 1: Update Backend URL

Before building APK, update the production URL in Flutter app:

**File: `flutter_email_app/lib/services/api_service.dart`**
```dart
static const String baseUrl = 'https://yourdomain.com'; // Your Hostinger URL
```

## 🏗️ Step 2: Configure App Signing (Optional for Release)

### For Debug APK (Testing):
No signing needed - Flutter will use debug keystore automatically.

### For Release APK (Production):

1. **Create keystore:**
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. **Create `android/key.properties`:**
```properties
storePassword=your-store-password
keyPassword=your-key-password
keyAlias=upload
storeFile=/Users/Jay/upload-keystore.jks
```

3. **Update `android/app/build.gradle`:**
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

## 📦 Step 3: Build APK

### Option A: Debug APK (Quick Testing)
```bash
cd flutter_email_app
flutter build apk --debug
```
**Output:** `build/app/outputs/flutter-apk/app-debug.apk`

### Option B: Release APK (Production)
```bash
cd flutter_email_app
flutter build apk --release
```
**Output:** `build/app/outputs/flutter-apk/app-release.apk`

### Option C: Split APKs by Architecture (Smaller size)
```bash
flutter build apk --split-per-abi
```
**Output:**
- `app-armeabi-v7a-release.apk` (32-bit ARM devices)
- `app-arm64-v8a-release.apk` (64-bit ARM devices - most modern phones)
- `app-x86_64-release.apk` (64-bit x86 devices)

**Recommended:** Use `app-arm64-v8a-release.apk` for most Android phones.

## 📲 Step 4: Install APK

### On Physical Device:
1. **Enable Developer Options:**
   - Settings → About Phone → Tap "Build Number" 7 times

2. **Enable USB Debugging:**
   - Settings → Developer Options → USB Debugging

3. **Install via USB:**
```bash
cd flutter_email_app
flutter install
```

### Via File Transfer:
1. Copy APK to phone
2. Open APK file
3. Allow "Install from Unknown Sources" if prompted
4. Install

### Via ADB:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

## 🌐 Step 5: Deployment Checklist

Before distributing APK:

- [ ] Backend deployed to Hostinger and running
- [ ] Backend URL updated in `api_service.dart`
- [ ] Test backend health endpoint: `curl https://yourdomain.com/health`
- [ ] APK built in release mode
- [ ] APK tested on physical device
- [ ] Backend is accessible from mobile network (not just WiFi)

## 🎯 Complete Workflow

### 1. Deploy Backend First:
```bash
# On Hostinger VPS
docker pull yourusername/email-backend:latest
docker run -d --name email-backend -p 3000:3000 --env-file .env --restart unless-stopped yourusername/email-backend:latest
```

### 2. Update Flutter App:
```dart
// lib/services/api_service.dart
static const String baseUrl = 'https://yourdomain.com';
```

### 3. Build APK:
```bash
cd flutter_email_app
flutter clean
flutter pub get
flutter build apk --release --split-per-abi
```

### 4. Test APK:
```bash
# Install on device
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk

# Check device logs if issues
adb logcat | grep flutter
```

## 🐛 Troubleshooting

### APK won't install:
- Check if you have "Install from Unknown Sources" enabled
- Uninstall old version first
- Make sure APK is for correct architecture

### APK can't connect to backend:
- Check backend URL in `api_service.dart`
- Verify backend is running: `curl https://yourdomain.com/health`
- Check if device has internet connection
- Try accessing backend URL in phone browser first

### Build fails:
```bash
# Clean and rebuild
cd flutter_email_app
flutter clean
rm -rf build/
flutter pub get
flutter build apk --release
```

### Large APK size:
- Use `--split-per-abi` to create smaller APKs per architecture
- Only distribute the APK for your target architecture (usually arm64-v8a)

## 📊 APK Sizes (Approximate)

- Debug APK: ~50-60 MB
- Release APK (universal): ~20-25 MB
- Release APK (split arm64-v8a): ~15-20 MB

## 🔒 Security Notes

1. **Never commit:**
   - `key.properties`
   - Keystore files (`.jks`)
   - Backend credentials in source code

2. **Use environment variables** for sensitive data

3. **Enable HTTPS** on backend (via Nginx + Let's Encrypt)

4. **Obfuscate code** for release:
```bash
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```

## 📱 Distribution Options

1. **Direct APK:** Share APK file directly (for internal use)
2. **Google Play Store:** Publish for wider distribution
3. **Firebase App Distribution:** For beta testing
4. **Internal App Store:** For company-only distribution

## 🎉 Done!

Your APK is ready! Share the APK file with users or upload to Play Store.

**File Location:**
```
flutter_email_app/build/app/outputs/flutter-apk/app-release.apk
```

**Backend URL:**
```
https://yourdomain.com (or your Hostinger VPS IP)
```
