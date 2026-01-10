# Quick Start Guide - Email Tracking Features

## 🚀 Getting Started in 5 Minutes

### Step 1: Install MongoDB

**Option A: Local MongoDB (Recommended for Development)**
```bash
# macOS
brew tap mongodb/brew
brew install mongodb-community
brew services start mongodb-community

# Verify it's running
mongosh
# You should see MongoDB shell. Type 'exit' to quit.
```

**Option B: MongoDB Atlas (Cloud - Free Tier)**
1. Go to https://www.mongodb.com/cloud/atlas
2. Create free account
3. Create a free cluster
4. Get connection string
5. Update `MONGODB_URI` in `.env`

### Step 2: Configure Environment

```bash
cd /Users/Jay/Projects/Email_Sender_App

# Copy example env file
cp .env.example .env

# Edit .env file
nano .env
```

**Minimum required settings:**
```env
PORT=3000
BASE_URL=http://localhost:3000
MONGODB_URI=mongodb://localhost:27017/email_sender_app
```

### Step 3: Start the Server

```bash
# Make sure you're in the project root
cd /Users/Jay/Projects/Email_Sender_App

# Start the server
npm run server
```

**You should see:**
```
✅ MongoDB connected successfully
🚀 Server running on port 3000
📧 Email API ready
🔌 WebSocket ready
🌐 http://localhost:3000
```

### Step 4: Run the Flutter App

```bash
# Open new terminal
cd /Users/Jay/Projects/Email_Sender_App/flutter_email_app

# Get dependencies
flutter pub get

# Run the app
flutter run
```

**For physical device, update Environment config:**
```dart
// lib/config/environment.dart
static const String macIpAddress = 'YOUR_COMPUTER_IP';
// Example: '192.168.1.100'
```
> [!IMPORTANT]
> For tracking to work on physical devices, you MUST also update the `BASE_URL` in your `.env` file to use your Computer's IP address instead of `localhost`.

### Step 5: Test the Features

1. **Send a Test Campaign**
   - Open the app
   - Go to "Send Email" screen
   - Add a few test recipients (including yourself)
   - Include some links in the email template
   - Click "Send Emails"
   - Watch the real-time progress! ⚡

2. **Check the Dashboard**
   - Navigate to "Campaigns" screen
   - See your campaign listed
   - Tap to view detailed analytics

3. **Test Email Tracking**
   - Open the email you received
   - The app will record the open event
   - Click a link in the email
   - Check the dashboard - you'll see the click recorded!

---

## 🎯 Quick Test Commands

### Test Server Health
```bash
curl http://localhost:3000/health
```

### Test Campaigns API
```bash
curl http://localhost:3000/api/campaigns
```

### Test Tracking Pixel
```bash
curl http://localhost:3000/track/open/test-id-123
```

---

## 🐛 Troubleshooting

### MongoDB Won't Start
```bash
# Check if MongoDB is running
brew services list | grep mongodb

# Restart MongoDB
brew services restart mongodb-community

# Check MongoDB logs
tail -f /usr/local/var/log/mongodb/mongo.log
```

### Server Won't Start
```bash
# Check if port 3000 is in use
lsof -i :3000

# Kill process using port 3000
kill -9 <PID>

# Try a different port
PORT=3001 npm run server
```

### Flutter App Can't Connect
```bash
# Find your computer's IP address
ifconfig | grep "inet " | grep -v 127.0.0.1

# Update lib/config/environment.dart with this IP (macIpAddress variable)
# And update BASE_URL in .env (e.g., http://192.168.1.100:3000)
# Then rebuild the app
flutter clean
flutter pub get
flutter run
```

### MongoDB Connection Error
```bash
# Check MongoDB is running
mongosh

# If using MongoDB Atlas, verify:
# 1. Connection string is correct
# 2. IP whitelist includes your IP
# 3. Database user has correct permissions
```

---

## 📊 What to Expect

### Real-Time Progress
When sending emails, you'll see:
- **Live progress bar** updating after each email
- **Success counter** incrementing
- **Failed counter** (if any errors)
- **Time estimates** updating
- **Current email** being sent
- **Sending speed** in emails/minute

### Campaigns Dashboard
You'll see:
- **All campaigns** listed with beautiful cards
- **Quick stats** for each campaign
- **Status badges** (Completed, Sending, Failed)
- **Open rates** and **click rates**
- **Tap any campaign** to see detailed analytics

### Campaign Details
For each campaign:
- **Total sent, opened, clicked, failed**
- **Percentage rates**
- **Recent events** timeline
- **Individual email statuses**
- **Top clicked links** (coming soon with charts)

### Email Tracking
When recipients interact with emails:
- **Opens are tracked** when email is viewed
- **Clicks are tracked** when links are clicked
- **Device info** is captured (Desktop/Mobile/Tablet)
- **Location** is recorded (City, Country)
- **Statistics update** automatically

---

## 🎨 UI Features

- **Dark theme** with beautiful gradients
- **Glassmorphism** effects
- **Smooth animations**
- **Real-time updates** without refresh
- **Pull to refresh** on campaigns list
- **Loading states** with spinners
- **Error states** with retry buttons
- **Empty states** with helpful messages

---

## 📝 Next Steps

1. ✅ Start MongoDB
2. ✅ Configure .env
3. ✅ Start server
4. ✅ Run Flutter app
5. ✅ Send test campaign
6. ✅ Open email and click links
7. ✅ Check dashboard for analytics

**Everything is ready to go! 🎉**

For detailed documentation, see:
- [TRACKING_FEATURES.md](file:///Users/Jay/Projects/Email_Sender_App/TRACKING_FEATURES.md) - Complete feature documentation
- [walkthrough.md](file:///Users/Jay/.gemini/antigravity/brain/c0322d42-8aa7-41c1-a0a6-d27d66999462/walkthrough.md) - Implementation walkthrough

---

**Need help?** Check the troubleshooting section above or review the detailed documentation.
