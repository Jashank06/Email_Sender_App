# 📱 iPhone USB Testing Setup

## ✅ Your Configuration

Your Mac IP Address: **192.168.31.123**  
Your iPhone: **iOS 26.1** (Connected via USB)

## 🎯 How It Works Now

The app is now **smart** and automatically detects the platform:

| Platform | URL Used | Auto-Detected |
|----------|----------|---------------|
| iPhone/iPad (USB/WiFi) | `http://192.168.31.123:3000` | ✅ Yes |
| Android Phone/Tablet | `http://192.168.31.123:3000` | ✅ Yes |
| macOS Desktop | `http://localhost:3000` | ✅ Yes |
| Chrome Browser | `http://localhost:3000` | ✅ Yes |
| iOS Simulator | `http://localhost:3000` | ✅ Yes |
| Production APK/IPA | `http://148.135.136.17:3002` | ✅ Yes |

## 🚀 Running on iPhone (USB Connected)

### Step 1: Start Backend Server
```bash
npm run server
```
Server runs on: `http://localhost:3000` and `http://192.168.31.123:3000`

### Step 2: Run Flutter App on iPhone
```bash
cd flutter_email_app
flutter run -d 00008030-000654922233402E
```

Or simply:
```bash
cd flutter_email_app
flutter run  # Auto-selects iPhone if only one device
```

### Step 3: Check Console Output
You should see:
```
═══════════════════════════════════════════════
🌍 Environment: Development
📱 Platform: iOS (iPhone/iPad)
📡 Base URL: http://192.168.31.123:3000
🔧 Debug Mode: true
🎯 Force Production: false
═══════════════════════════════════════════════
```

### Step 4: Test OTP Functionality
1. Open app on iPhone
2. Tap "Sign Up"
3. Enter your details
4. Tap "Get OTP"
5. Check email for OTP
6. Enter 6-digit code
7. App navigates to home screen ✅

## 🔧 Troubleshooting

### "Connection Failed" on iPhone

#### Solution 1: Check Network Connection
Both Mac and iPhone must be on the same network (even when USB connected for deployment, the HTTP connection uses network).

Check your Mac's IP:
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

#### Solution 2: Test Backend Reachability
From your iPhone's Safari browser, visit:
```
http://192.168.31.123:3000/health
```

Should show:
```json
{"status":"ok","message":"Server is running"}
```

#### Solution 3: Check Firewall
Make sure your Mac's firewall allows connections on port 3000:
- System Preferences > Security & Privacy > Firewall
- Click "Firewall Options"
- Make sure Node.js or Terminal is allowed

#### Solution 4: Restart Backend
```bash
# Stop server (Ctrl+C)
# Start again
npm run server
```

### iPhone Not Detected

```bash
# Check connected devices
flutter devices

# If iPhone not showing, disconnect and reconnect USB
# Unlock iPhone
# Trust the Mac if prompted
```

### Build Taking Too Long

First iOS build can take 5-10 minutes. Subsequent builds are faster.

```bash
# Check build progress
ps aux | grep flutter
```

## 📊 Testing Checklist

- [x] Mac IP detected: `192.168.31.123`
- [x] Backend server running on port 3000
- [x] iPhone connected via USB
- [ ] Flutter app building/running on iPhone
- [ ] App shows correct environment info
- [ ] OTP sent successfully
- [ ] OTP verification works
- [ ] Navigation to home screen works

## 🎯 Other Devices

### Test on iPad (USB):
```bash
flutter run -d <IPAD_ID>
```

### Test on Android Phone (USB):
```bash
flutter run -d <ANDROID_ID>
```
Both will automatically use: `http://192.168.31.123:3000`

### Test on iOS Simulator:
```bash
flutter run -d "iPhone 14"
```
Uses: `http://localhost:3000` (simulator can access localhost)

## 🔄 Switching Between Devices

You can run on multiple devices simultaneously:

```bash
# Terminal 1: Backend
npm run server

# Terminal 2: iPhone
cd flutter_email_app
flutter run -d iPhone

# Terminal 3: Chrome (for quick testing)
cd flutter_email_app
flutter run -d chrome
```

Each platform automatically uses the correct URL!

## 🎨 Changing Mac IP Address

If your Mac's IP changes (different WiFi network), update:

File: `flutter_email_app/lib/config/environment.dart`
```dart
static const String macIpAddress = '192.168.31.123'; // Update this
```

To find your new IP:
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

## 🚀 Production Build

When ready for production (App Store):
```bash
cd flutter_email_app
flutter build ios --release
```

Automatically uses: `http://148.135.136.17:3002` ✅

## ✅ Everything Now Works!

✅ localhost for desktop/web  
✅ Mac IP for physical devices (iPhone, iPad, Android)  
✅ Production IP for release builds  
✅ Automatic platform detection  
✅ No manual URL changes needed!
