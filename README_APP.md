# 📧 Premium Email Sender App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter)
![Node.js](https://img.shields.io/badge/Node.js-14+-339933?style=for-the-badge&logo=node.js)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**A premium Flutter mobile app with glassmorphic UI for sending bulk personalized emails**

[Features](#-features) • [Screenshots](#-ui-preview) • [Quick Start](#-quick-start) • [Setup](#-detailed-setup)

</div>

---

## ✨ Features

### 🎨 **Premium UI/UX**
- Modern glassmorphic design with blur effects
- Black & white theme with gradient accents
- 3D effects and smooth animations
- Fully responsive and intuitive interface

### 📧 **Email Capabilities**
- **Dual Provider Support**: Gmail & Outlook
- **Bulk Email Sending**: Send to unlimited contacts
- **Personalization**: Dynamic template variables
- **Real-time Progress**: Track sending status
- **HTML Templates**: Full HTML email support

### 📊 **Google Sheets Integration**
- Direct import from Google Sheets
- Auto-detect contacts
- Support for any sheet structure
- Real-time validation

### 🔒 **Security**
- App password authentication
- No data storage on device
- Secure API communication
- Service account protection

---

## 🎬 UI Preview

The app features a stunning glassmorphic interface with:
- **Home Screen**: Premium landing with 3D effects
- **Email Config**: Smooth provider selection with animations
- **Sheet Setup**: Visual step-by-step guide
- **Template Editor**: Code-highlighted HTML editor
- **Send Screen**: Real-time progress with beautiful stats

---

## 🚀 Quick Start

### Prerequisites
```bash
# Check Flutter installation
flutter --version

# Check Node.js installation
node --version
```

### 1. Backend Setup (30 seconds)
```bash
# Install dependencies
npm install

# Start server
npm run server
```

### 2. Flutter App Setup (1 minute)
```bash
# Navigate to Flutter app
cd flutter_email_app

# Get dependencies
flutter pub get

# Run app
flutter run
```

### 3. Configure & Use
1. Open app → Tap "Get Started"
2. Select Gmail/Outlook → Enter credentials
3. Paste Google Sheet ID
4. Customize email template
5. Send! 🚀

---

## 📋 Detailed Setup

### Backend Configuration

1. **Create `.env` file:**
```env
PORT=3000
GMAIL_USER=your-email@gmail.com
GMAIL_APP_PASSWORD=your-app-password
SHEET_ID=your-default-sheet-id
```

2. **Add Service Account:**
   - Place `serviceAccount.json` in root
   - [How to get service account credentials →](SETUP_INSTRUCTIONS.md#step-3-add-service-account-credentials)

3. **Start Server:**
```bash
npm run server
```

### Flutter App Configuration

1. **Update API URL** in `lib/services/api_service.dart`:
```dart
// For Android Emulator
static const String baseUrl = 'http://10.0.2.2:3000';

// For iOS Simulator
static const String baseUrl = 'http://localhost:3000';

// For Physical Device (replace with your IP)
static const String baseUrl = 'http://192.168.1.100:3000';
```

2. **Run on Device:**
```bash
# Android
flutter run

# iOS
flutter run -d ios

# Web
flutter run -d chrome
```

---

## 🔑 Email Provider Setup

### Gmail
1. Enable 2FA: [Google Account Security](https://myaccount.google.com/security)
2. Generate App Password: [App Passwords](https://myaccount.google.com/apppasswords)
3. Use the 16-character password in the app

### Outlook
1. Enable 2FA: [Microsoft Account Security](https://account.microsoft.com/security)
2. Generate App Password in security settings
3. Use the app password in the app

---

## 📊 Google Sheets Format

Create a sheet with this structure:

| Name          | Email                |
|---------------|----------------------|
| John Doe      | john@example.com     |
| Jane Smith    | jane@example.com     |

**Steps:**
1. Create sheet with Name & Email columns
2. Share with service account email (from `serviceAccount.json`)
3. Copy Sheet ID from URL
4. Paste in app

---

## 🎨 Template Variables

Use these in subject and body:

- `{{name}}` → Contact's name
- `{{email}}` → Contact's email

**Example:**
```html
<div style="font-family: Arial, sans-serif;">
  <h2>Hi {{name}}!</h2>
  <p>This email is sent to {{email}}</p>
</div>
```

---

## 🏗️ Architecture

### Backend (Node.js + Express)
```
server.js
├── /api/test-email      → Verify email credentials
├── /api/test-sheet      → Validate Google Sheets
└── /api/send-emails     → Send bulk emails
```

### Frontend (Flutter)
```
Screens:
├── HomeScreen           → Landing page
├── EmailConfigScreen    → Email setup
├── SheetConfigScreen    → Sheet connection
├── TemplateConfigScreen → Template editor
└── SendEmailScreen      → Send & results

State Management: Provider
Styling: Glassmorphism + Custom Theme
Animations: flutter_animate
```

---

## 🐛 Troubleshooting

### "Cannot connect to server"
```bash
# Make sure server is running
npm run server

# Check API URL matches your environment
# Update in lib/services/api_service.dart
```

### "Authentication failed"
- Use **app password**, not regular password
- Enable 2FA first
- Regenerate app password if needed

### "Sheet not found"
- Share sheet with service account email
- Check Sheet ID is correct
- Verify service account has access

### Build errors
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📁 Project Structure

```
.
├── server.js                    # Backend API
├── package.json                 # Backend dependencies
├── .env                        # Configuration
├── serviceAccount.json         # Google credentials
├── SETUP_INSTRUCTIONS.md       # Detailed guide
└── flutter_email_app/
    ├── lib/
    │   ├── main.dart
    │   ├── models/
    │   ├── providers/
    │   ├── screens/
    │   ├── services/
    │   ├── utils/
    │   └── widgets/
    └── pubspec.yaml
```

---

## 🎯 API Endpoints

### POST `/api/test-email`
Test email credentials
```json
{
  "provider": "gmail",
  "email": "user@gmail.com",
  "password": "app-password"
}
```

### POST `/api/test-sheet`
Validate Google Sheet
```json
{
  "sheetId": "sheet-id"
}
```

### POST `/api/send-emails`
Send bulk emails
```json
{
  "provider": "gmail",
  "email": "user@gmail.com",
  "password": "app-password",
  "sheetId": "sheet-id",
  "subject": "Hello {{name}}",
  "template": "<html>...</html>",
  "senderName": "Your Name",
  "delayMs": 3000
}
```

---

## 🔐 Security

- ✅ App passwords only (never use main password)
- ✅ No credential storage
- ✅ Service account isolation
- ✅ `.env` and `serviceAccount.json` in `.gitignore`
- ✅ CORS enabled for API security

---

## 📈 Performance

- **Email Rate**: ~1 email per 3 seconds (configurable)
- **Recommended Batch**: Up to 500 contacts per session
- **Template Size**: Supports large HTML templates
- **Sheet Size**: No limit on contacts

---

## 🤝 Contributing

Contributions welcome! This is a complete, production-ready app that can be:
- Extended with more email providers
- Enhanced with email scheduling
- Integrated with more data sources
- Customized for specific use cases

---

## 📄 License

MIT License - Free to use and modify

---

## 🎉 Ready to Send!

Your premium email sender is ready! Follow the [Quick Start](#-quick-start) to begin sending beautiful, personalized emails. 🚀

**Need help?** Check [SETUP_INSTRUCTIONS.md](SETUP_INSTRUCTIONS.md) for detailed setup guide.

---

<div align="center">

**Built with ❤️ using Flutter & Node.js**

⭐ Star this repo if you find it useful!

</div>
