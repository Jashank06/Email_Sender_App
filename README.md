# Gmail Bulk Email Sender

A Node.js script to send personalized bulk emails using Gmail SMTP and Google Sheets as the data source.

## Prerequisites

1. Node.js 14.x or higher
2. Gmail account with 2FA enabled
3. Google Cloud Project with Google Sheets API enabled
4. Service account credentials for Google Sheets API

## Setup

1. Install dependencies:
   ```bash
   npm install
   ```
2. Create a `.env` file based on `.env.example` and fill in your details
3. Place your Google Service Account JSON file as `serviceAccount.json` in the project root

## Google Sheets Setup

1. Create a Google Sheet with a worksheet named "Contacts"
2. Add these columns to the sheet:
   - ContactName
   - ContactEmail
3. Share the Google Sheet with your service account email (found in serviceAccount.json)

## Gmail Setup

1. Enable 2FA on your Gmail account
2. Generate an App Password:
   - Go to your Google Account > Security
   - Under "Signing in to Google," select 2-Step Verification
   - At the bottom, select "App passwords"
   - Generate a new app password for "Mail" and "Other (Custom name)"
   - Use this password in your `.env` file

## Usage

```bash
node sendEmails.js
```

## Configuration

Edit the `CONFIG` object in `sendEmails.js` to customize:
- Email templates (HTML and plain text)
- Email subject
- Delay between emails

## License

MIT
