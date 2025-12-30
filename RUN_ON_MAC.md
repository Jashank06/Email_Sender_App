# 🍎 Running on macOS

## ✅ macOS Desktop Support Enabled!

Your Flutter app is now configured to run on macOS desktop.

---

## 🚀 Quick Start

### Start Backend
```bash
# Terminal 1
npm run server
```

### Run Flutter App on Mac
```bash
# Terminal 2
cd flutter_email_app
flutter run -d macos
```

---

## 📱 Available Platforms

Your app now supports:
- ✅ **macOS Desktop** (enabled)
- ✅ **Web** (Chrome)
- ✅ **Android** (when emulator/device connected)
- ✅ **iOS** (when simulator/device connected)

---

## 🖥️ macOS App Features

The app will run as a native macOS desktop application with:
- Native window controls
- macOS menu bar integration
- Retina display support
- Full glassmorphic UI
- Smooth animations

---

## 🎯 Running the App

### Option 1: Command Line
```bash
cd flutter_email_app
flutter run -d macos
```

### Option 2: VS Code
1. Open Command Palette (Cmd + Shift + P)
2. Type "Flutter: Select Device"
3. Choose "macOS (desktop)"
4. Press F5 to run

### Option 3: Android Studio
1. Click device selector dropdown
2. Choose "macOS (desktop)"
3. Click Run button

---

## 📊 API Configuration

The API URL is already configured for macOS:
```dart
// lib/services/api_service.dart
static const String baseUrl = 'http://localhost:3000';
```

This works because:
- Backend runs on `localhost:3000`
- macOS app connects to `localhost:3000`
- They're on the same machine ✅

---

## 🎨 What You'll See

The macOS app will open with:
1. **Native window** with close/minimize/maximize buttons
2. **Beautiful glassmorphic UI** with blur effects
3. **Smooth animations** optimized for macOS
4. **Full functionality** - all features work perfectly

---

## 🔧 If Build Takes Long

Flutter is building the macOS app for the first time. This includes:
- Compiling native macOS code
- Installing CocoaPods dependencies
- Creating app bundle
- Generating assets

**First build:** ~2-5 minutes  
**Subsequent builds:** ~10-30 seconds

---

## ✨ Using the App on Mac

Once the app launches:

1. **Home Screen**
   - Click "Get Started" button

2. **Email Configuration**
   - Select Gmail or Outlook
   - Enter your email credentials
   - Click "Continue"

3. **Google Sheets**
   - Paste Sheet ID
   - Click "Continue"

4. **Template**
   - Customize your email
   - Click "Continue"

5. **Send**
   - Review and send emails
   - Watch real-time progress

---

## 💡 Pro Tips for macOS

### Keyboard Shortcuts
- **Cmd + Q**: Quit app
- **Cmd + W**: Close window
- **Cmd + M**: Minimize window
- **Cmd + Tab**: Switch apps

### Window Management
- Drag window to resize
- Double-click title bar to maximize
- Native macOS window animations

### Performance
- macOS app is faster than web version
- Uses native rendering
- Better memory management
- Hardware-accelerated animations

---

## 🐛 Troubleshooting

### Build Fails
```bash
cd flutter_email_app
flutter clean
flutter pub get
flutter run -d macos
```

### Cannot Connect to Server
Make sure backend is running:
```bash
npm run server
```

### CocoaPods Issues
```bash
cd macos
pod install
cd ..
flutter run -d macos
```

---

## 📦 What Was Added

```
flutter_email_app/
└── macos/                    # macOS-specific files
    ├── Runner/               # App configuration
    ├── Flutter/              # Flutter integration
    └── Runner.xcodeproj/     # Xcode project
```

---

## 🎉 You're All Set!

Your Premium Email Sender now runs natively on macOS!

**Enjoy the beautiful glassmorphic UI on your Mac!** 🍎✨

---

## 📚 Resources

- [Flutter macOS Desktop](https://docs.flutter.dev/desktop)
- [macOS Platform Integration](https://docs.flutter.dev/development/platform-integration/macos)

