# Donation Image Upload Fix

## Problem Summary
Donor users were unable to upload images when creating donations. The issue had two main causes:

1. **Backend Issue**: Wrong upload middleware was being used
   - The donations route was using `upload` middleware (for avatars, saves to `uploads/avatars/`)
   - Should have been using `imageUpload` middleware (for donation images, saves to `uploads/images/`)

2. **Frontend Issue**: Incorrect content type for file uploads
   - Frontend was sending JSON data (`Content-Type: application/json`)
   - Backend expects `multipart/form-data` for file uploads

## Changes Made

### Backend Changes

#### 1. Fixed `backend/src/routes/donations.js`
- Changed import from `const { upload } = require("../middleware/upload")` to `const imageUpload = require("../middleware/imageUpload")`
- Updated POST route to use `imageUpload.single("image")` instead of `upload.single("image")`
- Updated PUT route to use `imageUpload.single("image")` instead of `upload.single("image")`
- Fixed image URL path from `/uploads/${req.file.filename}` to `/uploads/images/${req.file.filename}`

### Frontend Changes

#### 1. Updated `frontend/lib/repositories/base_repository.dart`
- Added `postMultipart()` method to support multipart/form-data uploads
- Added `putMultipart()` method to support multipart/form-data updates
- Both methods handle file uploads with proper content type

#### 2. Updated `frontend/lib/repositories/donation_repository.dart`
- Changed `createDonation()` to use `postMultipart()` instead of `post()`
- Changed parameter from `imageUrl` to `imagePath` (file path instead of URL)
- Changed `updateDonation()` to use `putMultipart()` instead of `put()`
- Changed parameter from `imageUrl` to `imagePath`

#### 3. Updated `frontend/lib/providers/donation_provider.dart`
- Changed `createDonation()` parameter from `imageUrl` to `imagePath`
- Changed `updateDonation()` parameter from `imageUrl` to `imagePath`
- Updated method calls to pass `imagePath` instead of `imageUrl`

#### 4. Updated `frontend/lib/screens/create_donation_screen_enhanced.dart`
- Modified `_submitDonation()` to extract image path from `_selectedImages`
- Pass `imagePath` (file path) instead of `imageUrl` to provider methods
- Image is now properly sent as multipart/form-data

## How It Works Now

### Creating a Donation with Image:
1. User selects image(s) in the frontend
2. Frontend extracts the file path from the selected image
3. Frontend sends a multipart/form-data request with:
   - Form fields: title, description, category, condition, location
   - File field: image (the actual image file)
4. Backend receives the request via `imageUpload` middleware
5. Middleware saves the file to `backend/uploads/images/`
6. Backend stores the image URL path in the database
7. Donation is created successfully

### File Storage:
- Avatar images: `backend/uploads/avatars/`
- Donation images: `backend/uploads/images/`
- Request attachments: `backend/uploads/request-images/`

## Testing
To test the fix:
1. Restart the backend server
2. Restart the frontend app
3. Login as a donor user
4. Create a new donation
5. Select an image in step 3 (Images step)
6. Complete the form and submit
7. Verify the donation is created with the image

## Notes
- The fix maintains backward compatibility
- Donations without images still work (image is optional)
- File size limit: 5MB per image
- Supported formats: JPEG, JPG, PNG, GIF, WebP
- The `uploads/images/` directory already exists and has proper permissions
