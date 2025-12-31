# 🌍 Environment Configuration Guide

## Overview
The app now automatically switches between **Development** and **Production** environments based on the build mode.

## 🎯 How It Works

### Automatic Detection
- **Debug Mode** (Development): Uses `http://localhost:3000`
- **Release Mode** (Production): Uses `http://148.135.136.17:3002`

### Configuration File
All environment settings are in: `flutter_email_app/lib/config/environment.dart`

## 🔧 Development Setup

### 1️⃣ Running Backend Server

```bash
# Start the server on localhost
npm run server

# Server will run on: http://localhost:3000
```

### 2️⃣ Running Flutter App (Development)

#### For macOS/Windows Desktop:
```bash
cd flutter_email_app
flutter run -d macos  # or -d windows
```
✅ Uses `http://localhost:3000` automatically

#### For Web Browser:
```bash
cd flutter_email_app
flutter run -d chrome
```
✅ Uses `http://localhost:3000` automatically

#### For iOS Simulator:
```bash
cd flutter_email_app
flutter run -d "iPhone 14"
```
✅ Uses `http://localhost:3000` automatically

#### For Android Emulator:
```bash
cd flutter_email_app
flutter run -d emulator-5554
```
⚠️ **Special Note**: Android emulator needs `10.0.2.2` instead of `localhost`

**To fix for Android Emulator**, edit `environment.dart`:
```dart
static const String developmentUrl = 'http://10.0.2.2:3000';
```

#### For Physical Device (Same WiFi):
1. Find your Mac's IP address:
   - macOS: `System Preferences > Network` or run `ifconfig | grep inet`
   - Example IP: `192.168.1.100`

2. Edit `environment.dart`:
```dart
static const String developmentUrl = 'http://192.168.1.100:3000';
```

3. Make sure firewall allows connections on port 3000

## 🚀 Production Setup

### Building Release APK
```bash
cd flutter_email_app
flutter build apk --release
```
✅ Automatically uses production URL: `http://148.135.136.17:3002`

### Building Release iOS
```bash
cd flutter_email_app
flutter build ios --release
```
✅ Automatically uses production URL: `http://148.135.136.17:3002`

## 🎛️ Manual Override

If you want to **force production URL even in debug mode**:

Edit `flutter_email_app/lib/config/environment.dart`:
```dart
static const bool forceProduction = true;  // Change to true
```

## 🧪 Testing OTP Functionality

### Development Test
1. Start backend: `npm run server`
2. Run Flutter app: `flutter run`
3. Sign up with email
4. Check console logs for environment info:
   ```
   ═══════════════════════════════════════════════
   🌍 Environment: Development
   📡 Base URL: http://localhost:3000
   🔧 Debug Mode: true
   🎯 Force Production: false
   ═══════════════════════════════════════════════
   ```
5. Enter OTP received in email
6. Verify it navigates to home screen

### Production Test
1. Build release APK: `flutter build apk --release`
2. Install on device: `flutter install`
3. Test signup/login flow
4. OTP will be sent using production server

## 🔍 Debugging Connection Issues

### Check Console Output
When app starts, look for environment info in console:
```
🌍 Environment: Development
📡 Base URL: http://localhost:3000
```

### Test Backend Connection
```bash
# Test if backend is reachable
curl http://localhost:3000/health

# Should return: {"status":"ok","message":"Server is running"}
```

### Common Issues

1. **"Failed to connect"** on Android Emulator
   - Solution: Use `10.0.2.2` instead of `localhost`

2. **"Failed to connect"** on Physical Device
   - Solution: Use your Mac's IP address
   - Check both devices are on same WiFi
   - Check firewall settings

3. **OTP not received**
   - Check backend logs
   - Verify email credentials in server.js
   - Check spam folder

## 📱 Platform-Specific URLs Reference

| Platform | URL |
|----------|-----|
| macOS/Windows/Linux | `http://localhost:3000` |
| Chrome Web | `http://localhost:3000` |
| iOS Simulator | `http://localhost:3000` |
| Android Emulator | `http://10.0.2.2:3000` |
| Physical Device (WiFi) | `http://YOUR_MAC_IP:3000` |
| Production APK/IPA | `http://148.135.136.17:3002` |

## 🎨 Customizing URLs

Edit `flutter_email_app/lib/config/environment.dart`:

```dart
class Environment {
  // Change these URLs as needed
  static const String developmentUrl = 'http://localhost:3000';
  static const String productionUrl = 'http://148.135.136.17:3002';
  
  // Or add more environments
  static const String stagingUrl = 'http://staging.example.com:3000';
}
```

## ✅ Verification Checklist

- [ ] Backend server running on `localhost:3000`
- [ ] Flutter app shows correct environment in console
- [ ] Signup sends OTP email successfully
- [ ] OTP verification works
- [ ] User navigates to home screen after OTP
- [ ] Production build uses production URL

## 🆘 Need Help?

If issues persist:
1. Check backend server is running
2. Verify network connectivity
3. Check firewall settings
4. Review console logs for errors
5. Test with `curl` or Postman first
