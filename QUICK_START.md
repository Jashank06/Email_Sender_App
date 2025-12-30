# ⚡ Quick Start Guide

## Get Running in 5 Minutes! 🚀

---

## 🎯 What You'll Build

A premium Flutter mobile app that sends personalized bulk emails from Google Sheets using Gmail or Outlook.

**Demo Flow:**
```
Open App → Configure Email → Add Sheet → Create Template → Send! ✅
```

---

## 📦 What You Need

Before starting, have these ready:

1. ✅ **Node.js** installed (v14+)
2. ✅ **Flutter** installed (v3.0+)
3. ✅ **Gmail or Outlook** account
4. ✅ **App Password** (generated from your email provider)
5. ✅ **Google Sheet** with contacts
6. ✅ **Service Account** JSON file

---

## 🚀 Step 1: Backend Setup (2 minutes)

### Install & Start Server

```bash
# Install dependencies
npm install

# Start backend server
npm run server
```

You should see:
```
🚀 Server running on port 3000
📧 Email API ready
🌐 http://localhost:3000
```

**✅ Backend is running!**

---

## 📱 Step 2: Flutter App Setup (2 minutes)

### Install & Run App

```bash
# Navigate to Flutter app
cd flutter_email_app

# Get dependencies
flutter pub get

# Run on Android/iOS
flutter run
```

**✅ App is running!**

---

## 🔑 Step 3: Get Credentials (1 minute)

### A. Generate Email App Password

**For Gmail:**
1. Go to: https://myaccount.google.com/apppasswords
2. Create app password for "Mail"
3. Copy the 16-character code

**For Outlook:**
1. Go to: https://account.microsoft.com/security
2. Generate app password
3. Copy the password

### B. Get Service Account (If not done)

1. Go to: https://console.cloud.google.com/
2. Create project → Enable Sheets API
3. Create Service Account → Download JSON
4. Save as `serviceAccount.json` in project root

---

## 📊 Step 4: Prepare Google Sheet (30 seconds)

### Create Sheet with This Format:

| Name          | Email                |
|---------------|----------------------|
| John Doe      | john@example.com     |
| Jane Smith    | jane@example.com     |

### Share Sheet:
1. Click "Share" button
2. Add service account email (from `serviceAccount.json`)
3. Give "Viewer" access

### Get Sheet ID:
From URL: `https://docs.google.com/spreadsheets/d/[COPY-THIS-ID]/edit`

---

## 🎮 Step 5: Use the App!

### Open the App

1. **Tap "Get Started"**

2. **Configure Email:**
   - Select Gmail or Outlook
   - Enter your email
   - Enter app password
   - Tap "Continue"

3. **Add Google Sheet:**
   - Paste Sheet ID
   - Tap "Continue"

4. **Create Template:**
   - Enter sender name (optional)
   - Enter subject: `Hello {{name}}!`
   - Enter template (or use default)
   - Tap "Continue"

5. **Send Emails:**
   - Review settings
   - Tap "Send Emails"
   - Watch the magic happen! ✨

**✅ You're sending emails!**

---

## 🎨 Example Template

Copy and paste this ready-to-use template:

```html
<div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; color: #333;">
  <h2 style="color: #2563eb;">Hello {{name}}! 👋</h2>
  <p>I hope this message finds you well.</p>
  <p>I wanted to reach out personally to share something exciting with you.</p>
  <div style="background: #f3f4f6; padding: 20px; border-radius: 8px; margin: 20px 0;">
    <p style="margin: 0;">✨ This is a personalized email sent to <strong>{{email}}</strong></p>
  </div>
  <p>Looking forward to connecting!</p>
  <p>Best regards,<br><strong>Your Name</strong></p>
</div>
```

---

## 📸 What to Expect

### Home Screen
- Beautiful glassmorphic design
- Animated background orbs
- "Get Started" button with glow effect

### Email Config
- Provider selection (Gmail/Outlook)
- Smooth input fields
- Real-time validation

### Sheet Setup
- Clean interface
- Instructions card
- Contact preview

### Template Editor
- Large text area for HTML
- Variable chips
- Syntax hints

### Sending
- Animated progress
- Real-time status
- Beautiful results screen

---

## ⚡ Pro Tips

### First Test
Always test with yourself first:
1. Add your email to sheet
2. Send test email
3. Verify it looks good
4. Then send to real contacts

### Common Issues

**"Cannot connect to server"**
```bash
# Make sure server is running
npm run server
```

**"Authentication failed"**
- Use APP PASSWORD, not regular password
- Enable 2FA first

**"Sheet not found"**
- Share sheet with service account
- Verify Sheet ID is correct

---

## 🎯 You're Ready!

Your premium email sender is ready to use! Here's what you built:

✅ Backend API with Gmail/Outlook support  
✅ Beautiful Flutter app with glassmorphic UI  
✅ Google Sheets integration  
✅ Custom email templates  
✅ Real-time sending progress  

**Time to send some emails!** 🚀📧

---

## 📚 Need More Help?

- **Detailed Setup**: See [SETUP_INSTRUCTIONS.md](SETUP_INSTRUCTIONS.md)
- **How to Use**: See [USAGE_GUIDE.md](USAGE_GUIDE.md)
- **Full Features**: See [README_APP.md](README_APP.md)

---

<div align="center">

**🎉 Happy Emailing! 🎉**

Built with ❤️ using Flutter & Node.js

</div>
