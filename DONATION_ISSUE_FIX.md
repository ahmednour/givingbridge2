# Donation Creation Issue - Fix Guide

## Problem

When trying to create a donation as a donor user:

- The wizard modal opens and you can fill in all information
- You can navigate through all steps
- When you click the final button to create the donation, nothing happens
- The modal doesn't close and no error is shown

## Root Cause

The frontend is built and running in a Docker container, and when the browser tries to connect to `http://localhost:3000/api`, it may be blocked or unable to reach the backend from the Docker network.

## Quick Test

### Open Browser Console

1. Open http://localhost:8080
2. Press `F12` to open Developer Tools
3. Go to the "Console" tab
4. Try to login and create a donation
5. Look for any red error messages, especially:
   - CORS errors (Cross-Origin Resource Sharing)
   - Network errors
   - Failed to fetch errors

## Solution Options

### Option 1: Check for Errors (Recommended First)

1. Open browser console (F12)
2. Try to create donation
3. Share any error messages you see

### Option 2: Test Direct API Access

Open a new browser tab and go to:

```
http://localhost:3000/health
```

You should see:

```json
{
  "status": "healthy",
  "database": "connected",
  "timestamp": "..."
}
```

If this doesn't work, the frontend can't reach the backend.

### Option 3: Rebuild Frontend (If API is unreachable)

If the health check doesn't work, the frontend needs to be configured to connect to the backend:

```bash
# Stop containers
docker-compose down

# Start them again
docker-compose up -d

# Check if backend is reachable
curl http://localhost:3000/health
```

### Option 4: Use Development Mode (Temporary)

Instead of using Docker frontend, run Flutter locally:

```bash
# Stop only the frontend container
docker stop givingbridge_frontend

# In a new terminal, navigate to frontend
cd frontend

# Run Flutter in development mode
flutter run -d chrome --web-port 8080

# This will use hot reload and connect properly to localhost:3000
```

## Expected Behavior

When you successfully create a donation:

1. A success message should appear: "Donation created successfully" (or in Arabic)
2. The modal should close automatically
3. You should be redirected to "My Donations" screen
4. The new donation should appear at the top of the list

## Verification

After fixing, test:

1. Login as donor (demo@example.com / demo123)
2. Click "Create Donation"
3. Fill in:
   - Title: "Winter Clothes"
   - Description: "Warm jackets for winter"
   - Category: Clothes
   - Condition: Good
   - Location: "New York, NY"
4. Click "Next" through all steps
5. Click final "Submit" or "Create" button
6. **Expected**: Modal closes, success message shows, donation appears in list

## Manual API Test

You can verify the backend works by creating a donation via PowerShell:

```powershell
# 1. Login to get token
$body = @{email='demo@example.com';password='demo123'} | ConvertTo-Json
$response = Invoke-WebRequest -Uri http://localhost:3000/api/auth/login -Method POST -Body $body -ContentType 'application/json'
$token = ($response.Content | ConvertFrom-Json).token

# 2. Create donation
$donationBody = @{
    title='Test Donation'
    description='Testing donation creation'
    category='clothes'
    condition='good'
    location='New York, NY'
} | ConvertTo-Json

$headers = @{Authorization="Bearer $token"}
Invoke-WebRequest -Uri http://localhost:3000/api/donations -Method POST -Body $donationBody -ContentType 'application/json' -Headers $headers

# 3. Check if it was created
Invoke-WebRequest -Uri http://localhost:3000/api/donations -Method GET | Select-Object -ExpandProperty Content
```

## Debug Information

If you see errors in the browser console, they might look like:

### CORS Error:

```
Access to XMLHttpRequest at 'http://localhost:3000/api/donations' from origin 'http://localhost:8080'
has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present
```

**Fix**: Backend CORS is already configured, but restart might be needed.

### Network Error:

```
Failed to fetch
net::ERR_CONNECTION_REFUSED
```

**Fix**: Backend is not running or not accessible. Check `docker ps` and `docker logs givingbridge_backend`

### Timeout Error:

```
The request timed out
```

**Fix**: Backend is slow or not responding. Check backend logs.

## Need Help?

If none of these solutions work, please share:

1. What you see in the browser console (F12 → Console tab)
2. Output of: `docker ps`
3. Output of: `docker logs givingbridge_backend --tail 20`
4. Can you access: http://localhost:3000/health in your browser?

---

**Created:** October 14, 2025  
**Status:** Investigating donation creation issue
