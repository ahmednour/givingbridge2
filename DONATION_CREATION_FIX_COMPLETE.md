# Complete Donation Creation Fix

## Issues Identified

### 1. Image Upload Middleware Issue (FIXED)
**Problem**: Wrong upload middleware was being used for donations
- Routes were using `upload` middleware (for avatars → `uploads/avatars/`)
- Should use `imageUpload` middleware (for donations → `uploads/images/`)

**Fix Applied**:
- Changed `backend/src/routes/donations.js` to import and use `imageUpload` middleware
- Updated image URL paths to `/uploads/images/`
- Fixed `imageUpload` middleware to handle cases where `req.user` might not be set yet

### 2. Frontend Content-Type Issue (FIXED)
**Problem**: Frontend was sending JSON instead of multipart/form-data
- Backend expects `multipart/form-data` for file uploads
- Frontend was sending `Content-Type: application/json`

**Fix Applied**:
- Added `postMultipart()` and `putMultipart()` methods to `base_repository.dart`
- Updated `donation_repository.dart` to use multipart methods
- Changed parameter from `imageUrl` to `imagePath` throughout the stack
- Updated `create_donation_screen_enhanced.dart` to pass file paths

### 3. "User Not Found" Error (NEEDS INVESTIGATION)
**Problem**: Backend returns "User not found" when creating donations
- Authentication token is valid
- User ID from token doesn't exist in database

**Possible Causes**:
1. User was deleted but token is still valid
2. Database was reset but tokens weren't cleared
3. User ID in token doesn't match database
4. User needs to log out and log back in

**Debugging Added**:
- Enhanced error message to show user ID
- Added console logging to donation creation route
- Added validation for donorId before database lookup

## How to Debug "User Not Found" Error

### Step 1: Check Backend Logs
When creating a donation, check the backend console for:
```
Create donation request: {
  userId: <number>,
  userEmail: <email>,
  hasFile: <boolean>,
  body: { ... }
}
```

### Step 2: Verify User Exists
Run this SQL query to check if the user exists:
```sql
SELECT id, name, email, role FROM users WHERE id = <userId_from_log>;
```

### Step 3: Check Token
The token might contain an old user ID. Solutions:
1. **User should log out and log back in**
2. Clear app data/cache
3. Check if user was deleted from database

### Step 4: Verify Authentication
Test the `/auth/me` endpoint:
```bash
curl -H "Authorization: Bearer <token>" http://localhost:5000/api/auth/me
```

## Files Modified

### Backend
1. `backend/src/routes/donations.js`
   - Changed import to use `imageUpload` middleware
   - Updated POST and PUT routes
   - Added debug logging
   - Fixed image URL paths

2. `backend/src/middleware/imageUpload.js`
   - Added null-safe access to `req.user?.id`
   - Handles cases where user might not be set

3. `backend/src/controllers/donationController.js`
   - Enhanced error messages
   - Added donorId validation
   - Better error reporting

### Frontend
1. `frontend/lib/repositories/base_repository.dart`
   - Added `postMultipart()` method
   - Added `putMultipart()` method

2. `frontend/lib/repositories/donation_repository.dart`
   - Changed `createDonation()` to use multipart
   - Changed `updateDonation()` to use multipart
   - Changed parameter from `imageUrl` to `imagePath`

3. `frontend/lib/providers/donation_provider.dart`
   - Updated method signatures
   - Changed parameter from `imageUrl` to `imagePath`

4. `frontend/lib/screens/create_donation_screen_enhanced.dart`
   - Extract image path from selected images
   - Pass `imagePath` instead of `imageUrl`

## Testing Steps

### 1. Test Without Image
1. Restart backend server
2. Log in as a donor user
3. Create a donation without selecting an image
4. Verify donation is created successfully

### 2. Test With Image
1. Create a donation
2. Select an image in step 3
3. Complete and submit
4. Verify:
   - Image is uploaded to `backend/uploads/images/`
   - Donation is created with image URL
   - Image is displayed in the app

### 3. Test "User Not Found" Error
If you still get "User not found":
1. Check backend console logs
2. Note the user ID from logs
3. Verify user exists in database
4. Try logging out and logging back in
5. If issue persists, check if database was reset

## Quick Fix for "User Not Found"

If the user exists but still getting the error:

### Option 1: Log Out and Log Back In
```dart
// In the app
await authProvider.logout();
await authProvider.login(email, password);
```

### Option 2: Clear Token Storage
```dart
// In the app
await ApiService.deleteToken();
// Then log in again
```

### Option 3: Verify Database Connection
```bash
# In backend directory
npm run db:migrate
npm run db:seed  # If needed
```

## Next Steps

1. **Restart the backend server** to apply changes
2. **Clear app cache** or reinstall the app
3. **Log out and log back in** to get a fresh token
4. **Try creating a donation** and check backend logs
5. **Report the user ID** from logs if error persists

## Support

If the issue persists after trying these steps:
1. Share the backend console logs
2. Share the user ID from the error
3. Confirm if the user exists in the database
4. Check if you can access other authenticated endpoints
