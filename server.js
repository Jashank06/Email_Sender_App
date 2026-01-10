require('dotenv').config();
const express = require('express');
const nodemailer = require('nodemailer');
const { GoogleSpreadsheet } = require('google-spreadsheet');
const { JWT } = require('google-auth-library');
const cors = require('cors');
const bodyParser = require('body-parser');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const mongoose = require('mongoose');
const { Server } = require('socket.io');
const http = require('http');

// Import tracking models and utilities
const { Campaign, EmailEvent, TrackedLink } = require('./models/trackingModels');
const User = require('./models/userModel');
const {
  generateTrackingId,
  generateShortId,
  injectTrackingPixel,
  replaceLinksWithTracking,
  parseUserAgent,
  getLocationFromIP,
  getClientIP,
  calculateStats
} = require('./utils/trackingUtils');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
});
const PORT = process.env.PORT || 3000;

// MongoDB Connection
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/email_sender_app';
mongoose.connect(MONGODB_URI)
  .then(() => console.log('✅ MongoDB connected successfully'))
  .catch(err => console.error('❌ MongoDB connection error:', err));

// In-memory storage for OTPs (users moved to MongoDB)
const otpStore = new Map();

// Create uploads directory if it doesn't exist
const uploadDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir);
}

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 25 * 1024 * 1024 // 25MB limit per file
  }
});

// Middleware
app.use(cors());

// Use conditional middleware based on content-type
app.use((req, res, next) => {
  if (req.is('multipart/form-data')) {
    // Skip body parsing for multipart, multer will handle it
    return next();
  }
  // For JSON and urlencoded
  bodyParser.json({ limit: '50mb' })(req, res, (err) => {
    if (err) return next(err);
    bodyParser.urlencoded({ extended: true, limit: '50mb' })(req, res, next);
  });
});

// Helper function to create OTP email transporter (using provided Gmail credentials)
// Note: OTP functionality disabled - authentication removed from frontend
function createOtpTransporter() {
  return nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.OTP_GMAIL_USER || 'jay440470@gmail.com',
      pass: process.env.OTP_GMAIL_PASSWORD || 'gwrsxziiwwzartep'
    }
  });
}

// Helper function to create email transporter (Gmail or Outlook)
function createTransporter(emailConfig) {
  const { provider, email, password } = emailConfig;

  if (provider === 'gmail') {
    return nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: email,
        pass: password
      }
    });
  } else if (provider === 'outlook') {
    return nodemailer.createTransport({
      host: 'smtp-mail.outlook.com',
      port: 587,
      secure: false,
      auth: {
        user: email,
        pass: password
      },
      tls: {
        ciphers: 'SSLv3'
      }
    });
  } else {
    throw new Error('Unsupported email provider');
  }
}

// Generate 6-digit OTP
function generateOTP() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// Create beautiful OTP email template
function createOtpEmailTemplate(name, otp) {
  return `
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap');
        
        * {
          margin: 0;
          padding: 0;
          box-sizing: border-box;
        }
        
        body {
          font-family: 'Poppins', sans-serif;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          padding: 40px 20px;
        }
        
        .container {
          max-width: 600px;
          margin: 0 auto;
          background: rgba(255, 255, 255, 0.95);
          border-radius: 24px;
          overflow: hidden;
          box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        }
        
        .header {
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          padding: 40px 30px;
          text-align: center;
          position: relative;
          overflow: hidden;
        }
        
        .header::before {
          content: '';
          position: absolute;
          top: -50%;
          left: -50%;
          width: 200%;
          height: 200%;
          background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
          animation: pulse 3s ease-in-out infinite;
        }
        
        @keyframes pulse {
          0%, 100% { transform: scale(1); opacity: 0.5; }
          50% { transform: scale(1.1); opacity: 0.8; }
        }
        
        .logo {
          font-size: 48px;
          margin-bottom: 10px;
          filter: drop-shadow(0 4px 8px rgba(0,0,0,0.2));
        }
        
        .header h1 {
          color: white;
          font-size: 28px;
          font-weight: 700;
          text-shadow: 0 2px 4px rgba(0,0,0,0.2);
          position: relative;
          z-index: 1;
        }
        
        .content {
          padding: 50px 40px;
          text-align: center;
        }
        
        .greeting {
          font-size: 20px;
          color: #333;
          margin-bottom: 20px;
          font-weight: 600;
        }
        
        .message {
          font-size: 16px;
          color: #666;
          line-height: 1.6;
          margin-bottom: 40px;
        }
        
        .otp-container {
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          border-radius: 16px;
          padding: 30px;
          margin: 30px 0;
          position: relative;
          overflow: hidden;
        }
        
        .otp-container::before {
          content: '';
          position: absolute;
          top: 0;
          left: 0;
          right: 0;
          bottom: 0;
          background: url('data:image/svg+xml,<svg width="100" height="100" xmlns="http://www.w3.org/2000/svg"><defs><pattern id="grid" width="20" height="20" patternUnits="userSpaceOnUse"><path d="M 20 0 L 0 0 0 20" fill="none" stroke="rgba(255,255,255,0.1)" stroke-width="1"/></pattern></defs><rect width="100" height="100" fill="url(%23grid)" /></svg>');
          opacity: 0.3;
        }
        
        .otp-label {
          color: rgba(255, 255, 255, 0.9);
          font-size: 14px;
          font-weight: 500;
          margin-bottom: 15px;
          text-transform: uppercase;
          letter-spacing: 2px;
        }
        
        .otp-code {
          font-size: 48px;
          font-weight: 700;
          color: white;
          letter-spacing: 12px;
          text-shadow: 0 4px 12px rgba(0,0,0,0.3);
          font-family: 'Courier New', monospace;
          position: relative;
          z-index: 1;
          background: rgba(255, 255, 255, 0.1);
          padding: 20px 30px;
          border-radius: 12px;
          display: inline-block;
          backdrop-filter: blur(10px);
        }
        
        .validity {
          color: rgba(255, 255, 255, 0.8);
          font-size: 13px;
          margin-top: 15px;
          font-weight: 500;
        }
        
        .divider {
          height: 2px;
          background: linear-gradient(90deg, transparent, #667eea, transparent);
          margin: 30px 0;
        }
        
        .footer {
          background: #f8f9fa;
          padding: 30px 40px;
          text-align: center;
          border-top: 2px solid #e9ecef;
        }
        
        .footer p {
          color: #666;
          font-size: 14px;
          line-height: 1.6;
          margin-bottom: 10px;
        }
        
        .security-note {
          background: linear-gradient(135deg, #ffeaa7 0%, #fdcb6e 100%);
          border-left: 4px solid #f39c12;
          padding: 20px;
          border-radius: 8px;
          margin: 30px 0;
          text-align: left;
        }
        
        .security-note strong {
          color: #d35400;
          display: block;
          margin-bottom: 8px;
          font-size: 15px;
        }
        
        .security-note p {
          color: #666;
          font-size: 13px;
          line-height: 1.5;
          margin: 0;
        }
        
        .app-name {
          font-weight: 600;
          color: #667eea;
        }
        
        @media only screen and (max-width: 600px) {
          .content {
            padding: 30px 20px;
          }
          
          .otp-code {
            font-size: 36px;
            letter-spacing: 8px;
          }
        }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <div class="logo">📧</div>
          <h1>Email Sender Pro</h1>
        </div>
        
        <div class="content">
          <div class="greeting">Hello ${name}! 👋</div>
          
          <p class="message">
            Welcome to <span class="app-name">Email Sender Pro</span>! We're excited to have you on board. 
            To complete your registration and verify your email address, please use the OTP code below.
          </p>
          
          <div class="otp-container">
            <div class="otp-label">Your Verification Code</div>
            <div class="otp-code">${otp}</div>
            <div class="validity">⏰ Valid for 10 minutes</div>
          </div>
          
          <div class="security-note">
            <strong>🔒 Security Notice</strong>
            <p>
              This OTP is confidential and meant only for you. Never share it with anyone, 
              including our support team. If you didn't request this code, please ignore this email.
            </p>
          </div>
          
          <div class="divider"></div>
          
          <p class="message" style="margin-bottom: 0;">
            Once verified, you'll have access to our powerful email management features with a beautiful, modern interface.
          </p>
        </div>
        
        <div class="footer">
          <p><strong>Need help?</strong> We're here for you 24/7</p>
          <p style="color: #999; font-size: 12px; margin-top: 20px;">
            © 2025 Email Sender Pro. All rights reserved.<br>
            This is an automated message, please do not reply.
          </p>
        </div>
      </div>
    </body>
    </html>
  `;
}

// Load contacts from Google Sheets
async function loadContactsFromSheet(sheetId, serviceAccount = null) {
  try {
    const doc = new GoogleSpreadsheet(sheetId);

    // Use service account if provided, otherwise use default
    if (serviceAccount) {
      const serviceAccountAuth = new JWT({
        email: serviceAccount.client_email,
        key: serviceAccount.private_key,
        scopes: ['https://www.googleapis.com/auth/spreadsheets.readonly'],
      });
      doc.auth = serviceAccountAuth;
    } else {
      // Use default service account from file
      const creds = require('./serviceAccount.json');
      const serviceAccountAuth = new JWT({
        email: creds.client_email,
        key: creds.private_key,
        scopes: ['https://www.googleapis.com/auth/spreadsheets.readonly'],
      });
      doc.auth = serviceAccountAuth;
    }

    await doc.loadInfo();

    // Get first sheet or sheet named 'Contacts'
    const sheet = doc.sheetsByTitle['Contacts'] || doc.sheetsByIndex[0];
    if (!sheet) throw new Error('No sheet found');

    const rows = await sheet.getRows();

    // Map rows - assuming first column is name, second is email
    return rows.map(row => {
      const rawData = row._rawData || [];
      return {
        name: rawData[0] || '',
        email: rawData[1] || ''
      };
    }).filter(contact => contact.email); // Filter out contacts without email

  } catch (error) {
    console.error('Error loading contacts:', error);
    throw error;
  }
}

// API Routes

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'Server is running' });
});

// ========================
// AUTHENTICATION ROUTES
// ========================

// Signup - Send OTP
app.post('/api/auth/signup', async (req, res) => {
  try {
    const { name, email, phone, dateOfBirth } = req.body;

    if (!name || !email || !phone || !dateOfBirth) {
      return res.status(400).json({
        success: false,
        message: 'All fields are required: name, email, phone, dateOfBirth'
      });
    }

    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'Email already registered. Please login.'
      });
    }

    // Generate OTP
    const otp = generateOTP();
    const otpExpiry = Date.now() + 10 * 60 * 1000; // 10 minutes

    // Store OTP temporarily
    otpStore.set(email, {
      otp,
      expiry: otpExpiry,
      userData: { name, email, phone, dateOfBirth },
      type: 'signup'
    });

    // Send OTP email
    const transporter = createOtpTransporter();
    const htmlContent = createOtpEmailTemplate(name, otp);

    await transporter.sendMail({
      from: '"Email Sender Pro" <jay440470@gmail.com>',
      to: email,
      subject: '🔐 Your OTP Code - Email Sender Pro',
      html: htmlContent
    });

    res.json({
      success: true,
      message: 'OTP sent successfully to your email',
      email: email
    });

  } catch (error) {
    console.error('Signup error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to send OTP: ' + error.message
    });
  }
});

// Verify OTP and Complete Signup
app.post('/api/auth/verify-otp', async (req, res) => {
  try {
    const { email, otp } = req.body;

    if (!email || !otp) {
      return res.status(400).json({
        success: false,
        message: 'Email and OTP are required'
      });
    }

    // Check if OTP exists
    const otpData = otpStore.get(email);
    if (!otpData) {
      return res.status(400).json({
        success: false,
        message: 'Invalid or expired OTP. Please request a new one.'
      });
    }

    // Check if OTP is expired
    if (Date.now() > otpData.expiry) {
      otpStore.delete(email);
      return res.status(400).json({
        success: false,
        message: 'OTP has expired. Please request a new one.'
      });
    }

    // Verify OTP
    if (otpData.otp !== otp) {
      return res.status(400).json({
        success: false,
        message: 'Invalid OTP. Please try again.'
      });
    }

    // Create user account
    const userId = `user_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    const user = new User({
      userId,
      ...otpData.userData,
      isVerified: true
    });

    await user.save();
    otpStore.delete(email);

    res.json({
      success: true,
      message: 'Account created successfully!',
      user: {
        userId: user.userId,
        name: user.name,
        email: user.email,
        phone: user.phone,
        dateOfBirth: user.dateOfBirth,
        savedEmail: user.savedEmail,
        savedPassword: user.savedPassword,
        savedProvider: user.savedProvider
      }
    });

  } catch (error) {
    console.error('OTP verification error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to verify OTP: ' + error.message
    });
  }
});

// Login - Send OTP
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: 'Email is required'
      });
    }

    // Check if user exists
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Email not registered. Please signup first.'
      });
    }

    // Generate OTP
    const otp = generateOTP();
    const otpExpiry = Date.now() + 10 * 60 * 1000; // 10 minutes

    // Store OTP temporarily
    otpStore.set(email, {
      otp,
      expiry: otpExpiry,
      type: 'login'
    });

    // Send OTP email
    const transporter = createOtpTransporter();
    const htmlContent = createOtpEmailTemplate(user.name, otp);

    await transporter.sendMail({
      from: '"Email Sender Pro" <jay440470@gmail.com>',
      to: email,
      subject: '🔐 Your Login OTP - Email Sender Pro',
      html: htmlContent
    });

    res.json({
      success: true,
      message: 'OTP sent successfully to your email',
      email: email
    });

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to send OTP: ' + error.message
    });
  }
});

// Verify Login OTP
app.post('/api/auth/verify-login-otp', async (req, res) => {
  try {
    const { email, otp } = req.body;

    if (!email || !otp) {
      return res.status(400).json({
        success: false,
        message: 'Email and OTP are required'
      });
    }

    // Check if OTP exists
    const otpData = otpStore.get(email);
    if (!otpData || otpData.type !== 'login') {
      return res.status(400).json({
        success: false,
        message: 'Invalid or expired OTP. Please request a new one.'
      });
    }

    // Check if OTP is expired
    if (Date.now() > otpData.expiry) {
      otpStore.delete(email);
      return res.status(400).json({
        success: false,
        message: 'OTP has expired. Please request a new one.'
      });
    }

    // Verify OTP
    if (otpData.otp !== otp) {
      return res.status(400).json({
        success: false,
        message: 'Invalid OTP. Please try again.'
      });
    }

    // Get user data
    const user = await User.findOne({ email });
    if (user) {
      user.lastLogin = new Date();
      await user.save();
    }
    otpStore.delete(email);

    res.json({
      success: true,
      message: 'Login successful!',
      user: {
        userId: user.userId,
        name: user.name,
        email: user.email,
        phone: user.phone,
        dateOfBirth: user.dateOfBirth,
        savedEmail: user.savedEmail,
        savedPassword: user.savedPassword,
        savedProvider: user.savedProvider
      }
    });

  } catch (error) {
    console.error('Login OTP verification error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to verify OTP: ' + error.message
    });
  }
});

// Get User Profile
app.get('/api/auth/profile/:email', async (req, res) => {
  try {
    const { email } = req.params;

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.json({
      success: true,
      user: {
        userId: user.userId,
        name: user.name,
        email: user.email,
        phone: user.phone,
        dateOfBirth: user.dateOfBirth,
        savedEmail: user.savedEmail,
        savedPassword: user.savedPassword,
        savedProvider: user.savedProvider
      }
    });

  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Update User Profile (email cannot be changed)
app.put('/api/auth/profile', async (req, res) => {
  try {
    const { email, name, phone, dateOfBirth, savedEmail, savedPassword, savedProvider } = req.body;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: 'Email is required'
      });
    }

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Update user data (email remains unchanged)
    if (name) user.name = name;
    if (phone) user.phone = phone;
    if (dateOfBirth) user.dateOfBirth = dateOfBirth;
    if (savedEmail !== undefined) user.savedEmail = savedEmail;
    if (savedPassword !== undefined) user.savedPassword = savedPassword;
    if (savedProvider !== undefined) user.savedProvider = savedProvider;

    await user.save();

    res.json({
      success: true,
      message: 'Profile updated successfully',
      user: {
        userId: user.userId,
        name: user.name,
        email: user.email,
        phone: user.phone,
        dateOfBirth: user.dateOfBirth,
        savedEmail: user.savedEmail,
        savedPassword: user.savedPassword,
        savedProvider: user.savedProvider
      }
    });

  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// ========================
// TRACKING ROUTES
// ========================

// Email open tracking - Serves 1x1 transparent pixel
app.get('/track/open/:trackingId', async (req, res) => {
  try {
    const { trackingId } = req.params;

    // Find the email event
    const emailEvent = await EmailEvent.findOne({ trackingId });

    if (emailEvent) {
      const now = new Date();
      const userAgent = req.headers['user-agent'] || '';
      const ipAddress = getClientIP(req);
      const deviceInfo = parseUserAgent(userAgent);
      const location = getLocationFromIP(ipAddress);

      // Update open count
      emailEvent.openCount += 1;

      // Set first opened timestamp if not already set
      if (!emailEvent.firstOpenedAt) {
        emailEvent.firstOpenedAt = now;
      }

      // Update last opened timestamp
      emailEvent.lastOpenedAt = now;

      // Update status to opened if not already
      if (emailEvent.status === 'sent' || emailEvent.status === 'delivered') {
        emailEvent.status = 'opened';
      }

      // Add open event to events array
      emailEvent.events.push({
        type: 'opened',
        timestamp: now,
        metadata: {
          userAgent,
          ipAddress,
          device: deviceInfo.device,
          browser: deviceInfo.browser,
          os: deviceInfo.os,
          location: `${location.city}, ${location.country}`
        }
      });

      // Update metadata
      if (!emailEvent.metadata) {
        emailEvent.metadata = {};
      }
      emailEvent.metadata.userAgent = userAgent;
      emailEvent.metadata.ipAddress = ipAddress;
      emailEvent.metadata.device = deviceInfo.device;
      emailEvent.metadata.location = `${location.city}, ${location.country}`;

      await emailEvent.save();

      // Update campaign statistics
      const campaign = await Campaign.findById(emailEvent.campaignId);
      if (campaign) {
        // Count unique opens
        const uniqueOpens = await EmailEvent.countDocuments({
          campaignId: campaign._id,
          status: { $in: ['opened', 'clicked'] }
        });
        campaign.openedCount = uniqueOpens;
        await campaign.save();

        // Emit real-time update
        const campaignRoom = `campaign-${campaign._id.toString()}`;
        io.to(campaignRoom).emit('campaign-update', {
          campaignId: campaign._id,
          stats: calculateStats(campaign)
        });

        console.log(`👁️ Email open tracked for campaign: ${campaign.subject}`);

        io.emit('email-open', {
          campaignId: campaign._id,
          recipientEmail: emailEvent.recipientEmail,
          trackingId: emailEvent.trackingId,
          timestamp: now
        });
      }
    }

    // Serve 1x1 transparent GIF pixel
    const pixel = Buffer.from(
      'R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7',
      'base64'
    );

    res.writeHead(200, {
      'Content-Type': 'image/gif',
      'Content-Length': pixel.length,
      'Cache-Control': 'no-store, no-cache, must-revalidate, private',
      'Pragma': 'no-cache',
      'Expires': '0'
    });
    res.end(pixel);

  } catch (error) {
    console.error('Tracking pixel error:', error);
    // Still serve the pixel even on error
    const pixel = Buffer.from(
      'R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7',
      'base64'
    );
    res.writeHead(200, {
      'Content-Type': 'image/gif',
      'Content-Length': pixel.length
    });
    res.end(pixel);
  }
});

// Link click tracking - Redirects to original URL and records click
app.get('/track/click/:linkId', async (req, res) => {
  try {
    const { linkId } = req.params;

    // Find the tracked link
    const trackedLink = await TrackedLink.findOne({ linkId });

    if (!trackedLink) {
      return res.status(404).send('Link not found');
    }

    const now = new Date();
    const userAgent = req.headers['user-agent'] || '';
    const ipAddress = getClientIP(req);
    const deviceInfo = parseUserAgent(userAgent);
    const location = getLocationFromIP(ipAddress);

    // Update click count and add click record
    trackedLink.clickCount += 1;
    trackedLink.clicks.push({
      timestamp: now,
      userAgent,
      ipAddress,
      location: `${location.city}, ${location.country}`,
      device: deviceInfo.device
    });
    await trackedLink.save();

    // Update email event
    const emailEvent = await EmailEvent.findOne({ trackingId: trackedLink.emailTrackingId });
    if (emailEvent) {
      emailEvent.clickCount += 1;

      // Update status to clicked
      if (emailEvent.status !== 'clicked') {
        emailEvent.status = 'clicked';
      }

      // Add click event
      emailEvent.events.push({
        type: 'clicked',
        timestamp: now,
        metadata: {
          url: trackedLink.originalUrl,
          userAgent,
          ipAddress,
          device: deviceInfo.device,
          location: `${location.city}, ${location.country}`
        }
      });

      // Add to clicked links
      if (!emailEvent.metadata) {
        emailEvent.metadata = {};
      }
      if (!emailEvent.metadata.clickedLinks) {
        emailEvent.metadata.clickedLinks = [];
      }
      emailEvent.metadata.clickedLinks.push({
        url: trackedLink.originalUrl,
        timestamp: now
      });

      await emailEvent.save();

      // Update campaign statistics
      const campaign = await Campaign.findById(emailEvent.campaignId);
      if (campaign) {
        // Count unique clicks
        const uniqueClicks = await EmailEvent.countDocuments({
          campaignId: campaign._id,
          status: 'clicked'
        });
        campaign.clickedCount = uniqueClicks;
        await campaign.save();

        // Emit real-time update
        const campaignRoom = `campaign-${campaign._id.toString()}`;
        io.to(campaignRoom).emit('campaign-update', {
          campaignId: campaign._id,
          stats: calculateStats(campaign)
        });

        console.log(`🖱️ Link click tracked for campaign: ${campaign.subject}`);

        io.emit('email-click', {
          campaignId: campaign._id,
          recipientEmail: emailEvent.recipientEmail,
          trackingId: emailEvent.trackingId,
          url: trackedLink.originalUrl,
          timestamp: now
        });
      }
    }

    // Redirect to original URL
    res.redirect(trackedLink.originalUrl);

  } catch (error) {
    console.error('Link tracking error:', error);
    res.status(500).send('Error processing link');
  }
});

// ========================
// EMAIL SENDING ROUTES
// ========================

// Test email configuration
app.post('/api/test-email', async (req, res) => {
  try {
    const { provider, email, password } = req.body;

    if (!provider || !email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: provider, email, password'
      });
    }

    const transporter = createTransporter({ provider, email, password });

    // Verify connection
    await transporter.verify();

    res.json({
      success: true,
      message: 'Email configuration is valid!'
    });

  } catch (error) {
    console.error('Email test error:', error);
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
});

// Test Google Sheets connection
app.post('/api/test-sheet', async (req, res) => {
  try {
    const { sheetId } = req.body;

    if (!sheetId) {
      return res.status(400).json({
        success: false,
        message: 'Sheet ID is required'
      });
    }

    const contacts = await loadContactsFromSheet(sheetId);

    res.json({
      success: true,
      message: `Successfully loaded ${contacts.length} contacts`,
      contactCount: contacts.length,
      preview: contacts.slice(0, 3) // Show first 3 contacts as preview
    });

  } catch (error) {
    console.error('Sheet test error:', error);
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
});

// Send bulk emails (with attachment support and tracking)
app.post('/api/send-emails', upload.array('attachments', 10), async (req, res) => {
  try {
    const {
      provider,
      email,
      password,
      sheetId,
      subject,
      template,
      senderName,
      recipients,
      delayMs = 3000,
      userId
    } = req.body;

    // Parse recipients if it's a string
    let parsedRecipients = recipients;
    if (typeof recipients === 'string') {
      try {
        parsedRecipients = JSON.parse(recipients);
      } catch (e) {
        parsedRecipients = null;
      }
    }

    // Validate required fields
    if (!userId || !provider || !email || !password || (!sheetId && !parsedRecipients) || !subject || !template) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: userId, recipients or sheetId is required'
      });
    }

    // Create transporter
    const transporter = createTransporter({ provider, email, password });

    // Load contacts
    let contacts = [];
    if (parsedRecipients && Array.isArray(parsedRecipients) && parsedRecipients.length > 0) {
      contacts = parsedRecipients;
    } else {
      contacts = await loadContactsFromSheet(sheetId);
    }

    if (contacts.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No contacts found in the sheet'
      });
    }

    // Prepare attachments array
    const attachments = [];
    if (req.files && req.files.length > 0) {
      for (const file of req.files) {
        attachments.push({
          filename: file.originalname,
          path: file.path
        });
      }
    }

    // Create campaign record
    const campaign = new Campaign({
      subject,
      template,
      senderEmail: email,
      senderName: senderName || '',
      totalEmails: contacts.length,
      status: 'sending',
      userId: userId,
      metadata: {
        provider,
        attachmentCount: attachments.length,
        delayMs
      }
    });
    await campaign.save();

    // Get base URL for tracking
    const baseUrl = process.env.BASE_URL || `http://localhost:${PORT}`;

    // Send emails with tracking
    const results = [];
    let successCount = 0;
    const startTime = Date.now();

    for (let i = 0; i < contacts.length; i++) {
      const contact = contacts[i];

      try {
        // Generate unique tracking ID for this email
        const trackingId = generateTrackingId();

        // Replace placeholders in template
        const personalizedSubject = subject.replace(/\{\{name\}\}/gi, contact.name);
        let personalizedHtml = template
          .replace(/\{\{name\}\}/gi, contact.name)
          .replace(/\{\{email\}\}/gi, contact.email);

        // Inject tracking pixel
        personalizedHtml = injectTrackingPixel(personalizedHtml, trackingId, baseUrl);

        // Replace links with tracked versions
        const { html: trackedHtml, linkMappings } = replaceLinksWithTracking(
          personalizedHtml,
          trackingId,
          baseUrl,
          generateShortId
        );

        // Save tracked links to database
        for (const linkMapping of linkMappings) {
          const trackedLink = new TrackedLink({
            linkId: linkMapping.linkId,
            campaignId: campaign._id,
            emailTrackingId: trackingId,
            originalUrl: linkMapping.originalUrl
          });
          await trackedLink.save();
        }

        const personalizedText = trackedHtml.replace(/<[^>]*>/g, '');

        const mailOptions = {
          from: senderName ? `"${senderName}" <${email}>` : email,
          to: `${contact.name} <${contact.email}>`,
          subject: personalizedSubject,
          text: personalizedText,
          html: trackedHtml
        };

        // Add attachments if any
        if (attachments.length > 0) {
          mailOptions.attachments = attachments;
        }

        const info = await transporter.sendMail(mailOptions);

        // Create email event record
        const emailEvent = new EmailEvent({
          campaignId: campaign._id,
          trackingId,
          recipientEmail: contact.email,
          recipientName: contact.name,
          status: 'sent',
          events: [{
            type: 'sent',
            timestamp: new Date(),
            metadata: {
              messageId: info.messageId
            }
          }]
        });
        await emailEvent.save();

        results.push({
          email: contact.email,
          name: contact.name,
          success: true,
          messageId: info.messageId,
          trackingId
        });

        successCount++;

        // Update campaign progress
        campaign.sentCount = successCount;
        await campaign.save();

        // Emit real-time progress via WebSocket
        const progress = {
          campaignId: campaign._id,
          total: contacts.length,
          sent: successCount,
          failed: i + 1 - successCount,
          percentage: ((successCount / contacts.length) * 100).toFixed(2),
          currentEmail: contact.email,
          elapsedTime: Date.now() - startTime,
          estimatedTimeRemaining: ((Date.now() - startTime) / (i + 1)) * (contacts.length - (i + 1))
        };
        io.emit('email-progress', progress);

        // Delay between emails (except for last one)
        if (i < contacts.length - 1) {
          await new Promise(resolve => setTimeout(resolve, delayMs));
        }

      } catch (error) {
        console.error(`Failed to send to ${contact.email}:`, error);

        // Create failed email event record
        const trackingId = generateTrackingId();
        const emailEvent = new EmailEvent({
          campaignId: campaign._id,
          trackingId,
          recipientEmail: contact.email,
          recipientName: contact.name,
          status: 'failed',
          errorMessage: error.message,
          events: [{
            type: 'failed',
            timestamp: new Date(),
            metadata: {
              error: error.message
            }
          }]
        });
        await emailEvent.save();

        results.push({
          email: contact.email,
          name: contact.name,
          success: false,
          error: error.message
        });

        // Update campaign failed count
        campaign.failedCount++;
        await campaign.save();

        // Emit progress update
        const progress = {
          campaignId: campaign._id,
          total: contacts.length,
          sent: successCount,
          failed: campaign.failedCount,
          percentage: (((successCount + campaign.failedCount) / contacts.length) * 100).toFixed(2),
          currentEmail: contact.email,
          error: error.message
        };
        io.emit('email-progress', progress);
      }
    }

    // Update campaign as completed
    campaign.status = 'completed';
    campaign.completedAt = new Date();
    campaign.deliveredCount = successCount; // Initially assume all sent emails are delivered
    await campaign.save();

    // Emit completion event
    io.emit('email-complete', {
      campaignId: campaign._id,
      totalSent: successCount,
      totalFailed: campaign.failedCount,
      stats: calculateStats(campaign)
    });

    // Clean up uploaded files after sending all emails
    if (req.files && req.files.length > 0) {
      for (const file of req.files) {
        try {
          fs.unlinkSync(file.path);
        } catch (err) {
          console.error('Error deleting file:', err);
        }
      }
    }

    res.json({
      success: true,
      message: `Sent ${successCount} out of ${contacts.length} emails`,
      campaignId: campaign._id,
      totalContacts: contacts.length,
      successCount,
      failedCount: contacts.length - successCount,
      attachmentCount: attachments.length,
      results
    });

  } catch (error) {
    console.error('Bulk email error:', error);

    // Clean up uploaded files in case of error
    if (req.files && req.files.length > 0) {
      for (const file of req.files) {
        try {
          fs.unlinkSync(file.path);
        } catch (err) {
          console.error('Error deleting file:', err);
        }
      }
    }

    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// ========================
// ANALYTICS ROUTES
// ========================

// Get all campaigns for a user
app.get('/api/campaigns', async (req, res) => {
  try {
    const { userId } = req.query;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'User ID is required'
      });
    }

    const campaigns = await Campaign.find({ userId })
      .sort({ createdAt: -1 })
      .limit(100);

    const campaignsWithStats = campaigns.map(campaign => ({
      id: campaign._id,
      subject: campaign.subject,
      senderEmail: campaign.senderEmail,
      senderName: campaign.senderName,
      totalEmails: campaign.totalEmails,
      sentCount: campaign.sentCount,
      deliveredCount: campaign.deliveredCount,
      openedCount: campaign.openedCount,
      clickedCount: campaign.clickedCount,
      failedCount: campaign.failedCount,
      status: campaign.status,
      openRate: campaign.openRate,
      clickRate: campaign.clickRate,
      deliveryRate: campaign.deliveryRate,
      failureRate: campaign.failureRate,
      createdAt: campaign.createdAt,
      completedAt: campaign.completedAt
    }));

    res.json({
      success: true,
      campaigns: campaignsWithStats
    });

  } catch (error) {
    console.error('Get campaigns error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Get campaign details with full analytics
app.get('/api/campaigns/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { userId } = req.query;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'User ID is required'
      });
    }

    const campaign = await Campaign.findOne({ _id: id, userId });
    if (!campaign) {
      return res.status(404).json({
        success: false,
        message: 'Campaign not found or unauthorized'
      });
    }

    // Get all email events for this campaign
    const events = await EmailEvent.find({ campaignId: id })
      .sort({ createdAt: -1 });

    // Get tracked links for this campaign
    const trackedLinks = await TrackedLink.find({ campaignId: id });

    // Calculate detailed statistics
    const stats = {
      total: campaign.totalEmails,
      sent: campaign.sentCount,
      delivered: campaign.deliveredCount,
      opened: campaign.openedCount,
      clicked: campaign.clickedCount,
      failed: campaign.failedCount,
      openRate: campaign.openRate,
      clickRate: campaign.clickRate,
      deliveryRate: campaign.deliveryRate,
      failureRate: campaign.failureRate,
      uniqueOpens: events.filter(e => e.openCount > 0).length,
      uniqueClicks: events.filter(e => e.clickCount > 0).length,
      totalClicks: trackedLinks.reduce((sum, link) => sum + link.clickCount, 0),
      topLinks: trackedLinks
        .sort((a, b) => b.clickCount - a.clickCount)
        .slice(0, 5)
        .map(link => ({
          url: link.originalUrl,
          clicks: link.clickCount
        }))
    };

    res.json({
      success: true,
      campaign: {
        id: campaign._id,
        subject: campaign.subject,
        template: campaign.template,
        senderEmail: campaign.senderEmail,
        senderName: campaign.senderName,
        status: campaign.status,
        createdAt: campaign.createdAt,
        completedAt: campaign.completedAt,
        metadata: campaign.metadata
      },
      stats,
      eventCount: events.length
    });

  } catch (error) {
    console.error('Get campaign details error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Get all events for a campaign
app.get('/api/campaigns/:id/events', async (req, res) => {
  try {
    const { id } = req.params;
    const { status, limit = 100, offset = 0 } = req.query;

    const query = { campaignId: id };
    if (status) {
      query.status = status;
    }

    const events = await EmailEvent.find(query)
      .sort({ createdAt: -1 })
      .limit(parseInt(limit))
      .skip(parseInt(offset));

    const total = await EmailEvent.countDocuments(query);

    const formattedEvents = events.map(event => ({
      id: event._id,
      trackingId: event.trackingId,
      recipientEmail: event.recipientEmail,
      recipientName: event.recipientName,
      status: event.status,
      openCount: event.openCount,
      clickCount: event.clickCount,
      firstOpenedAt: event.firstOpenedAt,
      lastOpenedAt: event.lastOpenedAt,
      metadata: event.metadata,
      events: event.events,
      createdAt: event.createdAt
    }));

    res.json({
      success: true,
      events: formattedEvents,
      total,
      limit: parseInt(limit),
      offset: parseInt(offset)
    });

  } catch (error) {
    console.error('Get campaign events error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Get aggregated statistics for a campaign
app.get('/api/campaigns/:id/stats', async (req, res) => {
  try {
    const { id } = req.params;

    const campaign = await Campaign.findById(id);
    if (!campaign) {
      return res.status(404).json({
        success: false,
        message: 'Campaign not found'
      });
    }

    // Get hourly open/click distribution
    const events = await EmailEvent.find({ campaignId: id });

    const hourlyStats = {};
    events.forEach(event => {
      event.events.forEach(e => {
        const hour = new Date(e.timestamp).getHours();
        if (!hourlyStats[hour]) {
          hourlyStats[hour] = { opens: 0, clicks: 0 };
        }
        if (e.type === 'opened') hourlyStats[hour].opens++;
        if (e.type === 'clicked') hourlyStats[hour].clicks++;
      });
    });

    // Device breakdown
    const deviceStats = {};
    events.forEach(event => {
      if (event.metadata && event.metadata.device) {
        const device = event.metadata.device;
        deviceStats[device] = (deviceStats[device] || 0) + 1;
      }
    });

    // Location breakdown
    const locationStats = {};
    events.forEach(event => {
      if (event.metadata && event.metadata.location) {
        const location = event.metadata.location;
        locationStats[location] = (locationStats[location] || 0) + 1;
      }
    });

    res.json({
      success: true,
      stats: calculateStats(campaign),
      hourlyStats,
      deviceStats,
      locationStats
    });

  } catch (error) {
    console.error('Get campaign stats error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// WebSocket connection handler
io.on('connection', (socket) => {
  console.log('📱 Client connected:', socket.id);

  socket.on('disconnect', () => {
    console.log('📱 Client disconnected:', socket.id);
  });

  socket.on('subscribe-campaign', (campaignId) => {
    socket.join(`campaign-${campaignId}`);
    console.log(`📱 Client ${socket.id} subscribed to campaign ${campaignId}`);
  });

  socket.on('unsubscribe-campaign', (campaignId) => {
    socket.leave(`campaign-${campaignId}`);
    console.log(`📱 Client ${socket.id} unsubscribed from campaign ${campaignId}`);
  });
});

// Start server with WebSocket support
server.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📧 Email API ready`);
  console.log(`🔌 WebSocket ready`);
  console.log(`🌐 http://localhost:${PORT}`);
});

module.exports = app;

