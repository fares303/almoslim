# AlMoslim Firebase Notifications

This directory contains scripts to send manual notifications to your AlMoslim app users for Adkar, Hadith, and Ayah content.

## Setup Instructions

1. **Install Node.js and npm** if you don't have them already:
   - Download from [nodejs.org](https://nodejs.org/)

2. **Install Firebase CLI**:
   ```bash
   npm install -g firebase-tools
   ```

3. **Login to Firebase**:
   ```bash
   firebase login
   ```

4. **Get your Firebase Admin SDK service account key**:
   - Go to your Firebase project in the Firebase Console
   - Go to Project Settings > Service accounts
   - Click "Generate new private key"
   - Save the JSON file as `serviceAccountKey.json` in this directory

5. **Install dependencies**:
   ```bash
   npm install firebase-admin
   ```

## Sending Notifications

### Manual Sending

To send notifications manually, run:

```bash
node send_notifications.js
```

This will send one notification of each type (Adkar, Hadith, Ayah) to all users who have subscribed to the respective topics.

### Scheduled Sending

To set up scheduled notifications, you can use a cron job or a cloud function:

#### Using Cron (Linux/Mac):

1. Open your crontab:
   ```bash
   crontab -e
   ```

2. Add a schedule (e.g., daily at 7 AM for morning Adkar):
   ```
   0 7 * * * cd /path/to/firebase && node send_notifications.js
   ```

#### Using Cloud Functions:

1. Create a new Cloud Function in your Firebase project
2. Set up a scheduled trigger (e.g., every day at specific times)
3. Use the code from `send_notifications.js` in your function

## Customizing Notifications

You can customize the notifications by editing the content in the `send_notifications.js` file:

- `adkarList`: Add more Adkar entries
- `hadithList`: Add more Hadith entries
- `ayahList`: Add more Ayah entries

## Troubleshooting

- Make sure your `serviceAccountKey.json` file is in the same directory as the script
- Check that your app users have subscribed to the topics (`daily_adkar`, `daily_hadith`, `daily_ayah`)
- Verify that your Firebase project has Cloud Messaging enabled
- Check the Firebase Console > Cloud Messaging for delivery reports

## Security Note

Keep your `serviceAccountKey.json` file secure and never commit it to version control. It contains sensitive credentials that grant administrative access to your Firebase project.
