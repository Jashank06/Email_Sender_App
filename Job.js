require('dotenv').config();
const nodemailer = require('nodemailer');
const { GoogleSpreadsheet } = require('google-spreadsheet');
const { promisify } = require('util');
const sleep = promisify(setTimeout);

// ================= CONFIGURATION =================
const CONFIG = {
  email: {
    from: `"Jashank" <${process.env.GMAIL_USER}>`,
    subject: 'Application for Full Stack / MERN / DevOps Developer Role',

    getHtml: (name) => `
      <div style="background:#f4f6f9;padding:30px 0;">
        <div style="
          max-width:650px;
          margin:0 auto;
          background:#ffffff;
          border-radius:14px;
          box-shadow:0 12px 35px rgba(0,0,0,0.1);
          overflow:hidden;
          font-family:'Segoe UI',Arial,sans-serif;
          color:#333;
        ">

          <!-- HEADER -->
          <div style="
            background:linear-gradient(135deg,#0f2027,#203a43,#2c5364);
            padding:30px;
            text-align:center;
            color:#ffffff;
          ">
            <h1 style="margin:0;font-size:26px;letter-spacing:1px;">
              Jashank
            </h1>
            <p style="margin-top:8px;font-size:15px;opacity:0.9;">
              Full Stack • MERN • DevOps Developer
            </p>
          </div>

          <!-- BODY -->
          <div style="padding:30px;line-height:1.8;font-size:15px;">
            <p>
              Hello <strong>${name || 'Hiring Manager'}</strong>,
            </p>

            <p>
              I hope you are doing well. I am reaching out to explore
              <strong>technical opportunities</strong> within your organization.
            </p>

            <p>
              I have <strong>1 year of hands-on experience in Full Stack Development</strong>,
              working on scalable, performance-driven, and production-ready web applications.
            </p>

            <!-- ROLES -->
            <div style="margin:25px 0;">
              <h3 style="color:#2c5364;margin-bottom:10px;">
                🎯 Open To Roles
              </h3>
              <table width="100%" cellpadding="8" style="font-size:14px;">
                <tr>
                  <td>✔ Full Stack Developer</td>
                  <td>✔ MERN Stack Developer</td>
                </tr>
                <tr>
                  <td>✔ DevOps / Cloud Engineer (Junior)</td>
                  <td>✔ Frontend / Backend Developer</td>
                </tr>
              </table>
            </div>

            <!-- SKILLS -->
            <div style="margin:25px 0;">
              <h3 style="color:#2c5364;margin-bottom:10px;">
                🛠 Technical Skills
              </h3>
              <ul style="padding-left:20px;">
                <li><strong>Frontend:</strong> HTML, CSS, JavaScript, React.js</li>
                <li><strong>Backend:</strong> Node.js, Express.js</li>
                <li><strong>Databases:</strong> MongoDB, SQL</li>
                <li><strong>DevOps:</strong> Docker, Linux, CI/CD fundamentals</li>
                <li><strong>Tools:</strong> Git, GitHub, REST APIs</li>
              </ul>
            </div>

            <p>
              I am highly motivated, quick to adapt, and excited to contribute
              to innovative engineering teams.
            </p>

            <!-- CONTACT -->
            <div style="
              margin-top:30px;
              padding:20px;
              background:#f0f6ff;
              border-left:5px solid #2c5364;
              border-radius:6px;
            ">
              <p style="margin:0 0 8px;font-weight:bold;">📩 Contact Details</p>
              <p style="margin:0;">
                Email:
                <a href="mailto:jay440470@gmail.com">jay440470@gmail.com</a><br>
                Phone / WhatsApp: +91 9911752744
              </p>
            </div>
          </div>

          <!-- FOOTER -->
          <div style="
            background:#f1f3f6;
            padding:18px;
            text-align:center;
            font-size:14px;
            color:#555;
          ">
            <p style="margin:0;">
              Thank you for your time and consideration.
            </p>
            <p style="margin-top:8px;">
              <strong>Jashank</strong><br>
              Full Stack Developer
            </p>
          </div>

        </div>
      </div>
    `,

    getText: (name) =>
      `Hello ${name || 'Hiring Manager'},\n\n` +
      `I hope you are doing well.\n\n` +
      `I am applying for suitable technical roles within your organization.\n\n` +
      `I have 1 year of hands-on experience in Full Stack Development, working with modern technologies to build scalable applications.\n\n` +
      `Open Roles:\n` +
      `- Full Stack Developer\n` +
      `- MERN Stack Developer\n` +
      `- DevOps / Cloud Engineer (Junior)\n` +
      `- Frontend / Backend Developer\n\n` +
      `Technical Skills:\n` +
      `Frontend: HTML, CSS, JavaScript, React.js\n` +
      `Backend: Node.js, Express.js\n` +
      `Databases: MongoDB, SQL\n` +
      `DevOps: Docker, Linux, CI/CD basics\n` +
      `Tools: Git, GitHub, REST APIs\n\n` +
      `Contact Details:\n` +
      `Email: jay440470@gmail.com\n` +
      `Phone / WhatsApp: +91 9911752744\n\n` +
      `Best regards,\n` +
      `Jashank\n` +
      `Full Stack Developer`
  },

  resume: {
    filename: 'Jashank_Fullstack_Developer_Resume.pdf',
    path: './Jashank_Fullstack_Developer_Resume.pdf'
  },

  delay: process.env.EMAIL_DELAY_MS
    ? parseInt(process.env.EMAIL_DELAY_MS)
    : 3000,

  sheet: {
    name: 'Contacts'
  }
};

// ================= EMAIL TRANSPORTER =================
function createTransporter() {
  return nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.GMAIL_USER,
      pass: process.env.GMAIL_APP_PASSWORD
    }
  });
}

// ================= LOAD CONTACTS =================
async function loadContacts() {
  const creds = require('./serviceAccount.json');
  const doc = new GoogleSpreadsheet(process.env.SHEET_ID);

  const { JWT } = require('google-auth-library');
  doc.auth = new JWT({
    email: creds.client_email,
    key: creds.private_key,
    scopes: ['https://www.googleapis.com/auth/spreadsheets'],
  });

  await doc.loadInfo();
  const sheet = doc.sheetsByTitle[CONFIG.sheet.name];
  if (!sheet) throw new Error(`Sheet "${CONFIG.sheet.name}" not found`);

  const rows = await sheet.getRows();

  return rows.map(row => {
    const data = row._rawData || [];
    return {
      name: data[0],
      email: data[1]
    };
  });
}

// ================= SEND EMAIL =================
async function sendEmail(transporter, contact) {
  const { name, email } = contact;
  if (!email) return;

  try {
    const info = await transporter.sendMail({
      from: CONFIG.email.from,
      to: `${name || 'Hiring Manager'} <${email}>`,
      subject: CONFIG.email.subject,
      text: CONFIG.email.getText(name),
      html: CONFIG.email.getHtml(name),
      attachments: [{
        filename: CONFIG.resume.filename,
        path: CONFIG.resume.path
      }]
    });

    console.log(`✅ Sent to ${email}`);
  } catch (err) {
    console.error(`❌ Failed for ${email}:`, err.message);
  }
}

// ================= MAIN =================
async function main() {
  console.log('🚀 Bulk Job Application Mailer Started');

  const transporter = createTransporter();
  const contacts = await loadContacts();

  for (let i = 0; i < contacts.length; i++) {
    await sendEmail(transporter, contacts[i]);
    if (i < contacts.length - 1) await sleep(CONFIG.delay);
  }

  console.log('✨ All emails processed');
}

if (require.main === module) {
  main().catch(console.error);
}
