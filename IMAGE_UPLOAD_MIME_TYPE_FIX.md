# Image Upload MIME Type Fix

## Problem
When uploading PNG images, the backend rejects them with an error message about invalid file type, even though PNG is an allowed format.

## Root Cause
The frontend was not explicitly setting the MIME type when uploading files via multipart/form-data. The `http.MultipartFile.fromPath()` method should auto-detect MIME types, but this can fail in some environments (especially web).

## Solution Applied

### 1. Added MIME Type Detection Packages
**File**: `frontend/pubspec.yaml`

Added required packages:
```yaml
http_parser: ^4.0.2
mime: ^1.0.4
```

### 2. Updated Multipart Upload Methods
**File**: `frontend/lib/repositories/base_repository.dart`

Added explicit MIME type detection:
```dart
// Before (no MIME type):
final file = await http.MultipartFile.fromPath(
  entry.key,
  entry.value,
);

// After (with MIME type):
final mimeType = lookupMimeType(entry.value) ?? 'application/octet-stream';
final file = await http.MultipartFile.fromPath(
  entry.key,
  entry.value,
  contentType: MediaType.parse(mimeType),
);
```

### 3. Added Backend Logging
**File**: `backend/src/middleware/imageUpload.js`

Added detailed logging to help debug file upload issues:
```javascript
console.log("File upload attempt:", {
  originalname: file.originalname,
  mimetype: file.mimetype,
  size: file.size,
});

console.log("Validation results:", {
  extname: extname,
  mimetype: mimetype,
  extension: path.extname(file.originalname).toLowerCase(),
  mimetypeValue: file.mimetype,
});
```

## How It Works

### MIME Type Detection
The `mime` package detects MIME types based on file extensions:
- `.png` → `image/png`
- `.jpg` / `.jpeg` → `image/jpeg`
- `.gif` → `image/gif`
- `.webp` → `image/webp`

### Backend Validation
The backend validates both:
1. **File extension**: Must be `.jpeg`, `.jpg`, `.png`, `.gif`, or `.webp`
2. **MIME type**: Must match `image/jpeg`, `image/jpg`, `image/png`, `image/gif`, or `image/webp`

## Steps to Apply Fix

### 1. Install New Packages
```bash
cd frontend
flutter pub get
```

### 2. Restart Backend (to apply logging)
```bash
cd backend
npm start
```

### 3. Test Image Upload
1. Log in to the app
2. Create a new donation
3. Try uploading a PNG image
4. Check backend console for detailed logs

## Expected Backend Logs

### Successful Upload:
```
File upload attempt: {
  originalname: 'test.png',
  mimetype: 'image/png',
  size: 123456
}
Validation results: {
  extname: true,
  mimetype: true,
  extension: '.png',
  mimetypeValue: 'image/png'
}
```

### Failed Upload (if still failing):
```
File upload attempt: {
  originalname: 'test.png',
  mimetype: 'application/octet-stream',  // ❌ Wrong MIME type
  size: 123456
}
Validation results: {
  extname: true,
  mimetype: false,  // ❌ Validation failed
  extension: '.png',
  mimetypeValue: 'application/octet-stream'
}
File rejected: {
  reason: 'Invalid MIME type',
  mimetype: 'application/octet-stream',
  extension: '.png'
}
```

## Supported Image Formats

| Format | Extension | MIME Type |
|--------|-----------|-----------|
| JPEG | `.jpg`, `.jpeg` | `image/jpeg` |
| PNG | `.png` | `image/png` |
| GIF | `.gif` | `image/gif` |
| WebP | `.webp` | `image/webp` |

## Troubleshooting

### If PNG Still Fails After Fix:

1. **Check Backend Logs**
   - Look for "File upload attempt" in console
   - Check what MIME type is being received

2. **Verify File Extension**
   - Make sure file actually has `.png` extension
   - Some files might have wrong extensions

3. **Check File Size**
   - Maximum size: 5MB
   - Files larger than 5MB will be rejected

4. **Try Different Image**
   - Some corrupted images might fail
   - Try with a fresh PNG from a screenshot

5. **Clear Cache**
   - Clear browser cache
   - Restart the app
   - Try again

### Common Issues:

**Issue**: "Only image files (jpeg, jpg, png, gif, webp) are allowed!"
**Cause**: MIME type doesn't match allowed types
**Solution**: This fix should resolve it by explicitly setting MIME type

**Issue**: "File too large"
**Cause**: Image exceeds 5MB limit
**Solution**: Compress the image or use a smaller one

**Issue**: File uploads but doesn't appear
**Cause**: Image path might be incorrect
**Solution**: Check that image URL starts with `/uploads/images/`

## Files Modified

### Frontend
1. ✅ `frontend/pubspec.yaml` - Added mime and http_parser packages
2. ✅ `frontend/lib/repositories/base_repository.dart` - Added MIME type detection

### Backend
1. ✅ `backend/src/middleware/imageUpload.js` - Added detailed logging

## Testing Checklist

- [ ] Run `flutter pub get` in frontend directory
- [ ] Restart backend server
- [ ] Log in to the app
- [ ] Create a new donation
- [ ] Upload a PNG image
- [ ] Verify image uploads successfully
- [ ] Check backend logs for MIME type
- [ ] Try uploading JPEG image
- [ ] Try uploading WebP image
- [ ] Verify all formats work

## Next Steps

After applying this fix:
1. Install packages: `cd frontend && flutter pub get`
2. Restart backend: `cd backend && npm start`
3. Test uploading PNG images
4. Check backend console logs
5. If still failing, share the backend logs for further debugging
