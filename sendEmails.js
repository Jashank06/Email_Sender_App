require('dotenv').config();
const nodemailer = require('nodemailer');
const { GoogleSpreadsheet } = require('google-spreadsheet');
const { promisify } = require('util');
const sleep = promisify(setTimeout);

// Configuration
const CONFIG = {
  email: {
    from: `"Jashank" <${process.env.GMAIL_USER}>`,
    subject: 'A custom website for {{name}}',
    getHtml: (name) => `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; color: #333;">
        <h2>Hello ${name},</h2>
        <p>I hope you are doing well.</p>
        <p>My name is <strong>Jashank</strong>, a freelance <strong>website & app developer</strong> working with international clients to build modern, responsive, and high-performing websites.</p>
        <p>I can create a personalized website for your business, priced between <strong>$500 – $1000</strong>, tailored to your needs and audience.</p>
        <p>If you're interested, feel free to reach out:</p>
        <ul>
          <li>Email: <a href="mailto:jay440470@gmail.com">jay440470@gmail.com</a></li>
          <li>WhatsApp / Call: +91 9911752744</li>
        </ul>
        <p>Looking forward to connecting!</p>
        <p>Best regards,<br><strong>Jashank</strong><br>Freelance Website & App Developer</p>
      </div>
    `,
    getText: (name) => 
      `Hello ${name},\n\n` +
      `I hope you are doing well.\n\n` +
      `My name is Jashank, a freelance website & app developer working with international clients to build modern, responsive, and high-performing websites.\n\n` +
      `I can create a personalized website for your business, priced between $500 – $1000, tailored to your needs and audience.\n\n` +
      `If you're interested, feel free to reach out:\n` +
      `Email: jay440470@gmail.com\n` +
      `WhatsApp / Call: +91 9911752744\n\n` +
      `Looking forward to connecting!\n\n` +
      `Best regards,\nJashank\nFreelance Website & App Developer`
  },
  delay: process.env.EMAIL_DELAY_MS ? parseInt(process.env.EMAIL_DELAY_MS) : 3000,
  sheet: {
    name: 'Contacts',
    columns: {
      name: 'ContactName',
      email: 'ContactEmail'
    }
  }
};

// Initialize email transporter
function createTransporter() {
  return nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.GMAIL_USER,
      pass: process.env.GMAIL_APP_PASSWORD
    }
  });
}

// Load contacts from Google Sheets
async function loadContacts() {
  try {
    const creds = require('./serviceAccount.json');
    const doc = new GoogleSpreadsheet(process.env.SHEET_ID);
    
    // Use JWT authentication for v5.x - set auth property
    const { JWT } = require('google-auth-library');
    const serviceAccountAuth = new JWT({
      email: creds.client_email,
      key: creds.private_key,
      scopes: ['https://www.googleapis.com/auth/spreadsheets'],
    });
    
    doc.auth = serviceAccountAuth;
    
    await doc.loadInfo();
    
    const sheet = doc.sheetsByTitle[CONFIG.sheet.name];
    if (!sheet) throw new Error(`Sheet "${CONFIG.sheet.name}" not found`);
    
    const rows = await sheet.getRows();
    
    // Map rows assuming column A is name and column B is email
    return rows.map(row => {
      const rawData = row._rawData || [];
      return {
        name: rawData[0], // First column (A)
        email: rawData[1]  // Second column (B)
      };
    });
  } catch (error) {
    console.error('Error loading contacts:', error.message);
    throw error;
  }
}

// Send email to a single contact
async function sendEmail(transporter, contact) {
  const { name, email } = contact;
  
  if (!email) {
    console.warn(`Skipping contact - missing email for ${name || 'unnamed contact'}`);
    return { success: false, email, error: 'Missing email address' };
  }

  try {
    const info = await transporter.sendMail({
      from: CONFIG.email.from,
      to: `${name} <${email}>`,
      subject: CONFIG.email.subject.replace('{{name}}', name),
      text: CONFIG.email.getText(name),
      html: CONFIG.email.getHtml(name)
    });

    console.log(`✅ Email sent to ${name} (${email}) - Message ID: ${info.messageId}`);
    return { success: true, email, messageId: info.messageId };
  } catch (error) {
    console.error(`❌ Failed to send email to ${name} (${email}):`, error.message);
    return { success: false, email, error: error.message };
  }
}

// Main function
async function main() {
  console.log('🚀 Starting bulk email sender...');

  // Validate environment variables
  const requiredVars = ['GMAIL_USER', 'GMAIL_APP_PASSWORD', 'SHEET_ID'];
  const missingVars = requiredVars.filter(varName => !process.env[varName]);
  if (missingVars.length > 0) throw new Error(`Missing required environment variables: ${missingVars.join(', ')}`);

  try {
    const transporter = createTransporter();
    const contacts = await loadContacts();
    
    console.log(`📋 Found ${contacts.length} contacts to process`);
    
    let successCount = 0;
    const results = [];
    
    for (const contact of contacts) {
      const result = await sendEmail(transporter, contact);
      results.push(result);
      if (result.success) successCount++;
      if (contacts.indexOf(contact) < contacts.length - 1) await sleep(CONFIG.delay);
    }
    
    // Summary
    console.log('\n📊 Email sending summary:');
    console.log(`✅ Successful: ${successCount}`);
    console.log(`❌ Failed: ${results.length - successCount}`);
    console.log('✨ Process completed!');
    
    return { success: true, total: results.length, successCount };
  } catch (error) {
    console.error('❌ Fatal error:', error.message);
    process.exit(1);
  }
}

// Run the script
if (require.main === module) {
  main().catch(console.error);
}
