# Request Image Upload Implementation Summary

## Overview

This document summarizes the implementation of image upload functionality for donation requests in the GivingBridge platform. The feature allows receivers to attach images to their requests to provide additional context or proof of need.

## Components Implemented

### 1. Request Image Upload Middleware

- **File**: `backend/src/middleware/requestImageUpload.js`
- **Features**:
  - Multer configuration for handling image uploads
  - File type validation (JPEG, JPG, PNG, GIF, WebP)
  - File size limits (5MB maximum)
  - Automatic unique filename generation
  - Dedicated storage directory (`uploads/request-images/`)

### 2. Request Model Updates

- **File**: `backend/src/models/Request.js`
- **Added Fields**:
  - `attachmentUrl`: URL path to the uploaded image
  - `attachmentName`: Original filename of the uploaded image
  - `attachmentSize`: Size of the uploaded image in bytes

### 3. Database Migration

- **File**: `backend/src/migrations/017_add_attachment_fields_to_requests.js`
- **Purpose**: Add attachment fields to the requests table

### 4. Request Controller Updates

- **File**: `backend/src/controllers/requestController.js`
- **Added Methods**:
  - `updateRequestAttachment`: Handle updating request attachments
  - `deleteRequestAttachment`: Handle deleting request attachments
- **Enhanced**: `createRequest` method to support image attachments

### 5. Request Routes Updates

- **File**: `backend/src/routes/requests.js`
- **Added Endpoints**:
  - `POST /api/requests/:id/attachment`: Upload/update request attachment
  - `DELETE /api/requests/:id/attachment`: Delete request attachment
- **Enhanced**: `POST /api/requests` endpoint to support multipart form data with attachments

### 6. Documentation Updates

- **Files**:
  - `backend/README.md`: Updated feature list and documentation
  - `backend/API_DOCUMENTATION.md`: Detailed API documentation for new endpoints

## Implementation Details

### File Storage

- Images are stored in `backend/uploads/request-images/`
- Filenames are automatically generated in the format: `request-{id}-{timestamp}-{random}.{ext}`
- Previous attachments are automatically deleted when replaced
- Upload directory is created automatically if it doesn't exist

### Security

- File type validation prevents non-image uploads
- File size limits prevent excessive storage usage
- Access to attachments is controlled through request permissions
- Only request receivers can upload/update/delete their request attachments
- Admin users have access to all attachments

### Error Handling

- Proper error handling for file upload failures
- Automatic cleanup of uploaded files when database operations fail
- Validation errors for invalid file types or sizes
- Permission checks for attachment operations

## API Endpoints

### Create Request with Attachment

- **Method**: POST
- **URL**: `/api/requests`
- **Content-Type**: multipart/form-data
- **Parameters**:
  - `donationId`: ID of the donation being requested
  - `message`: Optional message to the donor
  - `attachment`: Image file to attach to the request

### Upload/Update Request Attachment

- **Method**: POST
- **URL**: `/api/requests/:id/attachment`
- **Content-Type**: multipart/form-data
- **Parameters**:
  - `attachment`: Image file to attach to the request

### Delete Request Attachment

- **Method**: DELETE
- **URL**: `/api/requests/:id/attachment`
- **Description**: Removes the attachment from the request and deletes the file from storage

## Future Enhancements

1. Add support for multiple attachments per request
2. Implement image compression to reduce storage requirements
3. Add thumbnail generation for faster loading in UI
4. Implement cloud storage integration (AWS S3, Google Cloud Storage)
5. Add support for video attachments
6. Implement attachment preview functionality
