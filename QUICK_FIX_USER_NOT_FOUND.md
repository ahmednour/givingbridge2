# Quick Fix: "User Not Found" Error When Creating Donation

## The Problem
You're getting a "User not found" error when trying to create a donation, even though you're logged in.

## Why This Happens
Your authentication token contains a user ID that doesn't exist in the database. This can happen if:
- The database was reset/migrated
- Your user account was deleted
- You're using an old token

## Quick Solution (Try These in Order)

### Solution 1: Log Out and Log Back In ⭐ (Most Common Fix)
1. In the app, go to your profile
2. Click "Log Out"
3. Log back in with your credentials
4. Try creating a donation again

### Solution 2: Clear App Data
**On Android:**
1. Go to Settings → Apps → GivingBridge
2. Tap "Storage"
3. Tap "Clear Data"
4. Open the app and log in again

**On iOS:**
1. Delete the app
2. Reinstall from App Store
3. Log in again

**On Web:**
1. Open browser DevTools (F12)
2. Go to Application → Local Storage
3. Clear all data
4. Refresh and log in again

### Solution 3: Restart Backend Server
```bash
# Stop the backend if running
# Then restart it
cd backend
npm start
```

### Solution 4: Check Database
```bash
# In backend directory
npm run db:migrate
```

## How to Verify It's Fixed

1. Log in to the app
2. Go to "Create Donation"
3. Fill in the form:
   - Title: "Test Donation"
   - Description: "Testing donation creation"
   - Category: Select any
   - Condition: Select any
   - Location: Your location
4. (Optional) Add an image
5. Click "Create Donation"

If successful, you should see:
- ✅ "Donation created successfully" message
- The donation appears in "My Donations"

## Still Not Working?

### Check Backend Logs
When you try to create a donation, the backend will log:
```
Create donation request: {
  userId: 123,
  userEmail: "user@example.com",
  ...
}
```

Then it will show either:
- ✅ Success: "Donation created successfully"
- ❌ Error: "User not found with ID: 123"

### If You See "User not found with ID: X"
1. Note the user ID (e.g., 123)
2. Check if this user exists in the database
3. If not, you need to register a new account

### Database Check (For Developers)
```sql
-- Check if user exists
SELECT id, name, email, role FROM users WHERE id = <user_id_from_error>;

-- If user doesn't exist, check all users
SELECT id, name, email, role FROM users;
```

## Prevention
To avoid this issue in the future:
- Don't reset the database while users are logged in
- Always log out before clearing database
- Use database migrations instead of dropping tables

## Technical Details
The error occurs in `backend/src/controllers/donationController.js`:
```javascript
const user = await User.findByPk(donorId);
if (!user) {
  throw new Error(`User not found with ID: ${donorId}`);
}
```

The `donorId` comes from the JWT token in the Authorization header. If the user was deleted or the database was reset, this lookup fails.
