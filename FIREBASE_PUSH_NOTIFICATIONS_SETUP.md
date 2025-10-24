# Firebase Push Notifications Setup Guide

## 📋 Overview

This guide explains how to configure Firebase Cloud Messaging (FCM) for push notifications in the GivingBridge backend.

## 🚀 Quick Start

### Step 1: Generate Firebase Service Account Key

1. **Go to Firebase Console**

   - Navigate to: https://console.firebase.google.com/
   - Select your project: `giving-bridge`

2. **Access Service Accounts**

   - Click the ⚙️ gear icon (Project Settings)
   - Navigate to **"Service Accounts"** tab

3. **Generate Private Key**

   - Click **"Generate New Private Key"**
   - Click **"Generate Key"** in the confirmation dialog
   - A JSON file will be downloaded to your computer

4. **Rename and Place the File**
   - Rename the downloaded file to: `firebase-service-account.json`
   - Move it to: `backend/config/firebase-service-account.json`

### Step 2: Verify File Placement

Your backend directory structure should look like this:

```
backend/
├── config/
│   ├── db.js
│   ├── index.js
│   └── firebase-service-account.json  ← Service account file here
├── src/
│   ├── services/
│   │   └── pushNotificationService.js
│   └── server.js
└── package.json
```

### Step 3: Restart Backend Server

```bash
cd backend
npm run dev
```

You should see:

```
✅ Firebase Admin initialized successfully
📱 Push notifications enabled for project: giving-bridge
```

## 🔒 Security Notes

### ⚠️ IMPORTANT: Keep Service Account Secure

The `firebase-service-account.json` file contains sensitive credentials that grant administrative access to your Firebase project.

**DO NOT:**

- ❌ Commit this file to Git
- ❌ Share it publicly
- ❌ Include it in Docker images
- ❌ Upload it to cloud storage

**DO:**

- ✅ Add to `.gitignore` (already configured)
- ✅ Use environment variables in production
- ✅ Restrict file permissions (`chmod 600`)
- ✅ Store in secure secrets management in production

### .gitignore Configuration

Ensure your `.gitignore` includes:

```
# Firebase credentials
firebase-service-account.json
config/firebase-service-account.json
backend/config/firebase-service-account.json
```

## 🌐 Production Deployment

### Option 1: Environment Variables (Recommended)

Instead of using a file, pass the service account as an environment variable:

```javascript
// In pushNotificationService.js (alternative initialization)
const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});
```

Then set the environment variable:

```bash
export FIREBASE_SERVICE_ACCOUNT='{"type":"service_account","project_id":"giving-bridge",...}'
```

### Option 2: Docker Secrets

For Docker deployments, use Docker secrets:

```yaml
# docker-compose.yml
services:
  backend:
    secrets:
      - firebase_service_account

secrets:
  firebase_service_account:
    file: ./config/firebase-service-account.json
```

### Option 3: Kubernetes Secrets

For Kubernetes deployments:

```bash
kubectl create secret generic firebase-service-account \
  --from-file=service-account.json=./config/firebase-service-account.json
```

## 📱 Testing Push Notifications

### 1. Save FCM Token from Frontend

Frontend automatically saves FCM token after login via:

```
POST /api/auth/fcm-token
Authorization: Bearer <token>
{
  "fcmToken": "eXaMP1e_FCM_t0k3n..."
}
```

### 2. Send Test Message

Use the messaging screen or test the socket event:

```javascript
// Via Socket.IO
socket.emit("send_message", {
  receiverId: 2,
  content: "Test push notification!",
});
```

### 3. Check Logs

Backend logs will show:

```
✅ Notification sent successfully: projects/giving-bridge/messages/0:1234567890
📩 Push notification sent to John Doe
```

## 🔧 Troubleshooting

### Issue: "Firebase service account file not found"

**Solution:**

- Verify file exists at `backend/config/firebase-service-account.json`
- Check file permissions (should be readable by Node.js process)
- Ensure file is valid JSON

### Issue: "Firebase Admin initialization failed"

**Solution:**

- Verify the service account JSON is valid
- Check that the project ID matches your Firebase project
- Ensure you downloaded the correct service account key

### Issue: "Invalid registration token"

**Solution:**

- FCM token may have expired
- User needs to log in again on frontend
- Frontend will automatically refresh token

### Issue: "messaging/invalid-registration-token"

**Solution:**

- This is normal - token is invalid or expired
- Backend automatically handles this and marks for removal
- User will get new token on next login

## 📊 Service Account File Structure

Expected JSON structure:

```json
{
  "type": "service_account",
  "project_id": "giving-bridge",
  "private_key_id": "abc123...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-xxxxx@giving-bridge.iam.gserviceaccount.com",
  "client_id": "123456789...",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/..."
}
```

## 🎯 API Endpoints

### Save FCM Token

```http
POST /api/auth/fcm-token
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "fcmToken": "string"
}
```

**Response:**

```json
{
  "message": "FCM token updated successfully",
  "success": true
}
```

## 📚 Push Notification Types

### 1. New Message

Sent when user receives a new message

- **Title:** "New message from {senderName}"
- **Body:** Message preview (100 chars)
- **Action:** Opens messages screen

### 2. Request Status Change

Sent when donation request is approved/rejected

- **Title:** "✅ Request Approved!" or "❌ Request Rejected"
- **Body:** Donation title
- **Action:** Opens requests screen

### 3. New Request

Sent to donor when someone requests their donation

- **Title:** "📬 New Donation Request"
- **Body:** "{receiverName} requested {donationTitle}"
- **Action:** Opens incoming requests screen

### 4. New Donation

Sent to topic when new donation is posted

- **Title:** "🎁 New Donation Available"
- **Body:** "{donorName} donated {title} ({category})"
- **Action:** Opens browse donations screen

## 🔔 Notification Flow

```mermaid
graph TB
    A[User Action] --> B{Event Type}
    B -->|Message| C[Create Message]
    B -->|Request| D[Create Request]
    B -->|Donation| E[Create Donation]

    C --> F[Save to Database]
    D --> F
    E --> F

    F --> G[Socket.IO Notification]
    F --> H[Push Notification]

    G -->|Online| I[Real-time Update]
    H -->|Offline/Different Device| J[FCM Push]

    J --> K[User's Device]
    K --> L[Notification Displayed]
```

## ✅ Verification Checklist

- [ ] Service account file downloaded from Firebase Console
- [ ] File renamed to `firebase-service-account.json`
- [ ] File placed in `backend/config/`
- [ ] File added to `.gitignore`
- [ ] Backend server restarted
- [ ] Log shows "✅ Firebase Admin initialized successfully"
- [ ] Frontend saves FCM token after login
- [ ] Test notification sent successfully
- [ ] Production deployment uses secure secret management

## 🎉 Success!

Once configured, GivingBridge will automatically send push notifications for:

- ✉️ New messages
- 📬 New donation requests
- ✅ Request approvals/rejections
- 🎁 New donations posted

Users will receive notifications even when:

- App is in background
- App is completely closed
- User is on a different device
- User is offline (delivered when back online)
