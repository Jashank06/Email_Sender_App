# Email Sender App - Tracking Features

## 🎯 New Features Added

This update adds comprehensive email tracking capabilities to the Email Sender App, including:

### ✨ Features

1. **📧 Email Open Tracking (Pixel Tracking)**
   - Invisible 1x1 pixel embedded in emails
   - Tracks when recipients open emails
   - Records timestamp, device, browser, location
   - Counts multiple opens per email

2. **🔗 Link Click Tracking**
   - All links in emails are automatically tracked
   - Redirects users seamlessly to original URLs
   - Records click metadata (device, location, timestamp)
   - Shows most clicked links in analytics

3. **📊 Delivery Status Dashboard**
   - Beautiful campaigns list with statistics
   - Detailed campaign analytics
   - Individual email status tracking
   - Real-time status updates

4. **⚡ Real-Time Sending Progress**
   - Live progress bar during email sending
   - Success/failure counters
   - Estimated time remaining
   - Current email being sent
   - Sending speed (emails/minute)
   - WebSocket-powered real-time updates

## 🏗️ Architecture

### Backend (Node.js + Express)

#### Database (MongoDB)
- **Campaigns Collection**: Stores email campaign metadata and statistics
- **Email Events Collection**: Tracks individual email events (sent, opened, clicked, failed)
- **Tracked Links Collection**: Maps tracking URLs to original URLs

#### API Endpoints

**Tracking Endpoints:**
- `GET /track/open/:trackingId` - Serves tracking pixel and records opens
- `GET /track/click/:linkId` - Redirects to original URL and records clicks

**Analytics Endpoints:**
- `GET /api/campaigns` - List all campaigns with statistics
- `GET /api/campaigns/:id` - Get detailed campaign analytics
- `GET /api/campaigns/:id/events` - Get all events for a campaign
- `GET /api/campaigns/:id/stats` - Get aggregated statistics

**Email Sending:**
- `POST /api/send-emails` - Enhanced with tracking functionality

#### WebSocket Events
- `email-progress` - Real-time progress updates during sending
- `email-complete` - Campaign completion notification
- `subscribe-campaign` - Subscribe to campaign updates
- `unsubscribe-campaign` - Unsubscribe from campaign updates

### Frontend (Flutter)

#### Models
- `Campaign` - Campaign data with statistics
- `CampaignDetails` - Detailed campaign information
- `EmailEvent` - Individual email event data
- `EmailProgress` - Real-time progress data

#### Services
- `TrackingService` - API calls for campaigns and analytics

#### Providers
- `TrackingProvider` - State management with WebSocket integration

#### Screens
- `CampaignsScreen` - Dashboard showing all campaigns
- `CampaignDetailScreen` - Detailed analytics for a campaign

#### Widgets
- `ProgressCard` - Real-time progress display

## 🚀 Setup Instructions

### Prerequisites
- Node.js (v14+)
- MongoDB (local or cloud instance)
- Flutter SDK (for mobile app)

### Backend Setup

1. **Install Dependencies**
   ```bash
   cd /path/to/Email_Sender_App
   npm install
   ```

2. **Configure Environment Variables**
   
   Create/update `.env` file:
   ```env
   PORT=3000
   BASE_URL=http://localhost:3000
   MONGODB_URI=mongodb://localhost:27017/email_sender_app
   
   # Your email configuration
   GMAIL_USER=your-email@gmail.com
   GMAIL_APP_PASSWORD=your-app-password
   
   # OTP configuration
   OTP_GMAIL_USER=your-otp-email@gmail.com
   OTP_GMAIL_PASSWORD=your-otp-app-password
   ```

3. **Start MongoDB**
   ```bash
   # If using local MongoDB
   mongod
   
   # Or use MongoDB Atlas (cloud)
   # Update MONGODB_URI in .env with your connection string
   ```

4. **Start the Server**
   ```bash
   npm run server
   ```
   
   You should see:
   ```
   ✅ MongoDB connected successfully
   🚀 Server running on port 3000
   📧 Email API ready
   🔌 WebSocket ready
   🌐 http://localhost:3000
   ```

### Flutter App Setup

1. **Navigate to Flutter App Directory**
   ```bash
   cd flutter_email_app
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Update API Configuration**
   
   Edit `lib/config/api_config.dart`:
   ```dart
   class ApiConfig {
     static const String baseUrl = 'http://localhost:3000'; // or your server URL
   }
   ```
   
   For physical devices, use your computer's IP address:
   ```dart
   static const String baseUrl = 'http://192.168.1.100:3000';
   ```

4. **Run the App**
   ```bash
   # For iOS
   flutter run -d ios
   
   # For Android
   flutter run -d android
   
   # For Web
   flutter run -d chrome
   ```

## 📱 Usage Guide

### Sending Tracked Emails

1. **Compose Email**
   - Navigate to the send email screen
   - Fill in subject, template, and recipients
   - Click "Send Emails"

2. **Real-Time Progress**
   - Watch live progress bar
   - See current email being sent
   - View success/failure counts
   - Monitor sending speed

3. **Automatic Tracking**
   - Tracking pixel is automatically injected
   - All links are automatically converted to tracked versions
   - No additional configuration needed

### Viewing Analytics

1. **Campaigns Dashboard**
   - Open the app and navigate to "Campaigns"
   - See all your email campaigns
   - View quick statistics for each campaign

2. **Campaign Details**
   - Tap on any campaign
   - View detailed analytics:
     - Total sent, opened, clicked, failed
     - Open rate and click rate percentages
     - Top clicked links
     - Individual email statuses
     - Device and location breakdown

3. **Real-Time Updates**
   - Statistics update automatically as recipients interact with emails
   - No need to refresh manually

## 🔧 Technical Details

### How Tracking Works

#### Email Open Tracking
1. When an email is sent, a unique tracking ID is generated
2. A 1x1 transparent GIF pixel is embedded in the email HTML
3. The pixel URL points to: `http://your-server/track/open/{trackingId}`
4. When the recipient opens the email, their email client loads the pixel
5. The server records the open event with metadata (timestamp, user agent, IP, location)
6. Campaign statistics are updated automatically

#### Link Click Tracking
1. All links in the email HTML are extracted
2. Each link is replaced with a tracking URL: `http://your-server/track/click/{linkId}`
3. The mapping between tracking URL and original URL is stored in the database
4. When a recipient clicks a link:
   - The server records the click event
   - The user is redirected to the original URL
   - Campaign statistics are updated

#### Real-Time Progress
1. WebSocket connection is established between Flutter app and server
2. During email sending, the server emits progress events after each email
3. Flutter app receives events and updates UI in real-time
4. Progress includes: sent count, failed count, percentage, time estimates

### Database Schema

#### Campaigns
```javascript
{
  subject: String,
  template: String,
  senderEmail: String,
  senderName: String,
  totalEmails: Number,
  sentCount: Number,
  deliveredCount: Number,
  openedCount: Number,
  clickedCount: Number,
  failedCount: Number,
  status: String, // 'pending', 'sending', 'completed', 'failed'
  createdAt: Date,
  completedAt: Date
}
```

#### Email Events
```javascript
{
  campaignId: ObjectId,
  trackingId: String, // unique per email
  recipientEmail: String,
  recipientName: String,
  status: String, // 'sent', 'delivered', 'opened', 'clicked', 'failed'
  openCount: Number,
  clickCount: Number,
  firstOpenedAt: Date,
  lastOpenedAt: Date,
  metadata: {
    userAgent: String,
    ipAddress: String,
    device: String,
    location: String,
    clickedLinks: Array
  }
}
```

#### Tracked Links
```javascript
{
  linkId: String,
  campaignId: ObjectId,
  emailTrackingId: String,
  originalUrl: String,
  clickCount: Number,
  clicks: [{
    timestamp: Date,
    userAgent: String,
    ipAddress: String,
    location: String
  }]
}
```

## 🎨 UI/UX Features

- **Glassmorphism Design**: Modern, premium look with frosted glass effects
- **Gradient Backgrounds**: Beautiful color gradients throughout the app
- **Animated Progress**: Smooth animations for progress indicators
- **Real-Time Updates**: Live data without page refreshes
- **Responsive Layout**: Works on all screen sizes
- **Dark Theme**: Eye-friendly dark color scheme

## 🔒 Privacy & Security

- **Minimal Data Collection**: Only essential tracking data is stored
- **Secure IDs**: Cryptographically secure random IDs prevent guessing
- **No Personal Data**: IP addresses and user agents are stored for analytics only
- **GDPR Compliant**: Easy to delete tracking data if needed

## 🐛 Troubleshooting

### MongoDB Connection Issues
```bash
# Check if MongoDB is running
mongod --version

# Start MongoDB
mongod

# Or use MongoDB Compass to connect visually
```

### WebSocket Connection Issues
- Ensure server is running
- Check firewall settings
- For physical devices, use computer's IP address instead of localhost
- Verify BASE_URL in Flutter app matches server URL

### Tracking Not Working
- Verify MongoDB is connected
- Check server logs for errors
- Ensure BASE_URL environment variable is set correctly
- Test tracking endpoints manually:
  ```bash
  curl http://localhost:3000/track/open/test-id
  ```

## 📊 Analytics Metrics

- **Open Rate**: (Unique Opens / Delivered) × 100
- **Click Rate**: (Unique Clicks / Delivered) × 100
- **Delivery Rate**: (Delivered / Total Sent) × 100
- **Failure Rate**: (Failed / Total Sent) × 100

## 🚧 Future Enhancements

- Email heatmaps showing click locations
- A/B testing for subject lines
- Automated follow-up campaigns
- Export analytics to PDF/CSV
- Geographic analytics with maps
- Email client detection
- Unsubscribe tracking
- Bounce rate analysis

## 📝 License

MIT License

## 🤝 Support

For issues or questions, please open an issue on GitHub or contact support.

---

**Built with ❤️ using Node.js, Express, MongoDB, Flutter, and Socket.IO**
