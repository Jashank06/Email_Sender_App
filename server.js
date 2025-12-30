require('dotenv').config();
const express = require('express');
const nodemailer = require('nodemailer');
const { GoogleSpreadsheet } = require('google-spreadsheet');
const { JWT } = require('google-auth-library');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

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
      delayMs = 3000
    } = req.body;
    
    // Validate required fields
    if (!provider || !email || !password || !sheetId || !subject || !template) {
      return res.status(400).json({ 
        success: false, 
        message: 'Missing required fields' 
      });
    }
    
    // Create transporter
    const transporter = createTransporter({ provider, email, password });
    
    // Load contacts
    const contacts = await loadContactsFromSheet(sheetId);
    
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
