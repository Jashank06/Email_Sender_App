require('dotenv').config();
const express = require('express');
const nodemailer = require('nodemailer');
const { GoogleSpreadsheet } = require('google-spreadsheet');
const { JWT } = require('google-auth-library');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
const PORT = process.env.PORT || 3000;

// In-memory storage for users and OTPs (in production, use a database)
const users = new Map();
const otpStore = new Map();

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Helper function to create OTP email transporter (using provided Gmail credentials)
function createOtpTransporter() {
  return nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: 'jay440470@gmail.com',
      pass: 'gwrsxziiwwzartep'
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
    if (users.has(email)) {
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
    const user = {
      userId,
      ...otpData.userData,
      createdAt: new Date().toISOString(),
      isVerified: true
    };

    users.set(email, user);
    otpStore.delete(email);

    res.json({
      success: true,
      message: 'Account created successfully!',
      user: {
        userId: user.userId,
        name: user.name,
        email: user.email,
        phone: user.phone,
        dateOfBirth: user.dateOfBirth
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
    const user = users.get(email);
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
    const user = users.get(email);
    otpStore.delete(email);

    res.json({
      success: true,
      message: 'Login successful!',
      user: {
        userId: user.userId,
        name: user.name,
        email: user.email,
        phone: user.phone,
        dateOfBirth: user.dateOfBirth
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
app.get('/api/auth/profile/:email', (req, res) => {
  try {
    const { email } = req.params;

    const user = users.get(email);
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
        dateOfBirth: user.dateOfBirth
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
app.put('/api/auth/profile', (req, res) => {
  try {
    const { email, name, phone, dateOfBirth } = req.body;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: 'Email is required'
      });
    }

    const user = users.get(email);
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
    user.updatedAt = new Date().toISOString();

    users.set(email, user);

    res.json({
      success: true,
      message: 'Profile updated successfully',
      user: {
        userId: user.userId,
        name: user.name,
        email: user.email,
        phone: user.phone,
        dateOfBirth: user.dateOfBirth
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

// Send bulk emails
app.post('/api/send-emails', async (req, res) => {
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
      delayMs = 3000
    } = req.body;

    // Validate required fields
    if (!provider || !email || !password || (!sheetId && !recipients) || !subject || !template) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: recipients or sheetId is required'
      });
    }

    // Create transporter
    const transporter = createTransporter({ provider, email, password });

    // Load contacts
    let contacts = [];
    if (recipients && Array.isArray(recipients) && recipients.length > 0) {
      contacts = recipients;
    } else {
      contacts = await loadContactsFromSheet(sheetId);
    }

    if (contacts.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No contacts found in the sheet'
      });
    }

    // Send emails
    const results = [];
    let successCount = 0;

    for (let i = 0; i < contacts.length; i++) {
      const contact = contacts[i];

      try {
        // Replace placeholders in template
        const personalizedSubject = subject.replace(/\{\{name\}\}/gi, contact.name);
        const personalizedHtml = template
          .replace(/\{\{name\}\}/gi, contact.name)
          .replace(/\{\{email\}\}/gi, contact.email);

        const personalizedText = personalizedHtml.replace(/<[^>]*>/g, '');

        const info = await transporter.sendMail({
          from: senderName ? `"${senderName}" <${email}>` : email,
          to: `${contact.name} <${contact.email}>`,
          subject: personalizedSubject,
          text: personalizedText,
          html: personalizedHtml
        });

        results.push({
          email: contact.email,
          name: contact.name,
          success: true,
          messageId: info.messageId
        });

        successCount++;

        // Delay between emails (except for last one)
        if (i < contacts.length - 1) {
          await new Promise(resolve => setTimeout(resolve, delayMs));
        }

      } catch (error) {
        console.error(`Failed to send to ${contact.email}:`, error);
        results.push({
          email: contact.email,
          name: contact.name,
          success: false,
          error: error.message
        });
      }
    }

    res.json({
      success: true,
      message: `Sent ${successCount} out of ${contacts.length} emails`,
      totalContacts: contacts.length,
      successCount,
      failedCount: contacts.length - successCount,
      results
    });

  } catch (error) {
    console.error('Bulk email error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Get email sending status (for progress tracking)
let emailProgress = {
  isRunning: false,
  total: 0,
  sent: 0,
  failed: 0
};

app.get('/api/email-progress', (req, res) => {
  res.json(emailProgress);
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📧 Email API ready`);
  console.log(`🌐 http://localhost:${PORT}`);
});

module.exports = app;
