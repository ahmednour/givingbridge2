# Debug 403 Forbidden Error - Complete Guide

## You said you're already logged in as admin but still getting 403 errors

This means one of these issues:

### Issue 1: Token doesn't have admin role (most likely)
Even though you logged in as admin, the JWT token might not have the admin role.

### Issue 2: Token expired
Your token might have expired and needs refresh.

### Issue 3: Wrong token being sent
The frontend might be sending a different token than expected.

## Quick Diagnosis (Choose One Method)

### Method 1: Use Debug Page (Easiest)

1. Open `debug-admin-access.html` in your browser
2. It will automatically check:
   - If you have a token
   - What role is in your token
   - If admin endpoints work
3. Follow the on-screen instructions

### Method 2: Browser Console (Quick)

Open browser console and run:

```javascript
// Check your token
const token = localStorage.getItem('auth_token') || localStorage.getItem('token');
console.log('Token exists:', !!token);

// Decode token to see role
if (token) {
  const payload = JSON.parse(atob(token.split('.')[1]));
  console.log('Your role:', payload.role);
  console.log('User ID:', payload.userId);
  console.log('Email:', payload.email);
  console.log('Is Admin?', payload.role === 'admin');
}

// Test approval endpoint
fetch('http://localhost:3000/api/donations/7/approve', {
  method: 'PUT',
  headers: {
    'Authorization': 'Bearer ' + token,
    'Content-Type': 'application/json'
  }
})
.then(r => r.json())
.then(data => console.log('Result:', data))
.catch(err => console.error('Error:', err));
```

### Method 3: Test Token with Script

```bash
cd backend

# Get your token from browser:
# 1. Open browser console
# 2. Run: localStorage.getItem('auth_token')
# 3. Copy the token

# Test it:
node test-auth.js YOUR_TOKEN_HERE
```

## Common Scenarios & Solutions

### Scenario A: Token has role "donor" or "receiver" instead of "admin"

**Problem:** You logged in with the wrong account, or the account isn't actually admin.

**Solution:**
```bash
cd backend
node scripts/list-users.js  # Check which users are admin
```

If `admin@givingbridge.com` is admin, logout and login with that account.

If your current account needs to be admin:
```bash
node scripts/make-admin.js your-email@example.com
```
Then **logout and login again** to get a new token.

### Scenario B: Token is valid but still getting 403

**Problem:** Backend might not be recognizing the token properly.

**Check:**
1. Is backend running? `http://localhost:3000`
2. Check backend logs for errors
3. Verify JWT_SECRET in backend/.env matches what was used to sign the token

**Solution:**
```bash
# Restart backend
cd backend
npm start

# Or check logs
tail -f backend/logs/app.log
```

### Scenario C: Token expired

**Problem:** Token has expired (default is 7 days).

**Solution:** Simply logout and login again to get a fresh token.

### Scenario D: CORS or Network Issue

**Problem:** Request isn't reaching the backend.

**Check browser console for:**
- CORS errors
- Network errors
- Failed requests

**Solution:**
1. Check backend is running on port 3000
2. Check CORS settings in backend/.env:
   ```
   FRONTEND_URL=http://localhost:8080
   CORS_ORIGIN=http://localhost:8080,http://localhost:3000
   ```

## Step-by-Step Debugging Process

### Step 1: Verify You're Logged In
```javascript
// Browser console
console.log('Token:', localStorage.getItem('auth_token'));
```
- ✅ If token exists → Go to Step 2
- ❌ If no token → You're not logged in, login first

### Step 2: Check Token Role
```javascript
// Browser console
const token = localStorage.getItem('auth_token');
const payload = JSON.parse(atob(token.split('.')[1]));
console.log('Role:', payload.role);
```
- ✅ If role is "admin" → Go to Step 3
- ❌ If role is NOT "admin" → See Scenario A above

### Step 3: Test Backend Directly
```javascript
// Browser console
fetch('http://localhost:3000/api/auth/me', {
  headers: { 'Authorization': 'Bearer ' + localStorage.getItem('auth_token') }
})
.then(r => r.json())
.then(data => console.log('User:', data));
```
- ✅ If returns user with role "admin" → Go to Step 4
- ❌ If 401/403 error → Token is invalid, logout and login again

### Step 4: Test Approval Endpoint
```javascript
// Browser console
fetch('http://localhost:3000/api/donations/7/approve', {
  method: 'PUT',
  headers: {
    'Authorization': 'Bearer ' + localStorage.getItem('auth_token'),
    'Content-Type': 'application/json'
  }
})
.then(r => r.json())
.then(data => console.log('Approval result:', data));
```
- ✅ If success → Problem solved!
- ❌ If 403 → Check backend logs for details

## Still Not Working?

### Check Backend Logs

```bash
cd backend
# If using PM2
pm2 logs

# If running directly
# Check console output
```

Look for:
- Authentication errors
- JWT verification errors
- Role check failures

### Verify Database

```bash
cd backend
node scripts/list-users.js
```

Make sure the user you're logged in as has role "admin" in the database.

### Nuclear Option: Fresh Login

1. Clear all storage:
```javascript
localStorage.clear();
sessionStorage.clear();
```

2. Logout completely
3. Close browser
4. Open browser again
5. Login with `admin@givingbridge.com`
6. Try approval again

## Need More Help?

Run the debug page (`debug-admin-access.html`) and share the output. It will show exactly what's wrong.
