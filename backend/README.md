# GivingBridge Backend API

## Overview

The GivingBridge Backend API provides a comprehensive platform for charitable giving and receiving. It includes user management, donation listing, request processing, messaging, notifications, and administrative features.

## Features

- User authentication (registration, login, password reset)
- Email verification system
- Donation management (create, update, delete, browse)
- Request system (request donations, approve/decline requests)
- Request image attachment support
- Advanced search and filtering for donations and requests
- Comprehensive analytics dashboard for admin users
- Donation history and receipt generation for tax purposes
- Detailed transaction history with export functionality
- Request milestones/updates for funded requests
- Social features (comments, sharing, social proof)
- Verification system (identity verification, document upload)
- **Rate limiting to prevent API abuse**
- Real-time messaging with Socket.IO
- Comprehensive notification system:
  - Email notifications (registration, password reset, request approvals, donation confirmations)
  - Push notifications (via Firebase Cloud Messaging)
  - In-app notifications
  - Notification preferences management
- Rating and review system
- Admin dashboard with analytics
- Activity logging

## API Endpoints

### Authentication

- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/logout` - Logout user
- `GET /api/auth/me` - Get current user profile
- `POST /api/auth/fcm-token` - Update FCM token for push notifications
- `POST /api/auth/verify-email` - Verify email address
- `POST /api/auth/resend-verification` - Resend verification email
- `POST /api/auth/forgot-password` - Request password reset
- `POST /api/auth/reset-password` - Reset password

### Users

- `GET /api/users` - Get all users (admin only)
- `GET /api/users/search/conversation` - Search users for conversations
- `GET /api/users/:id` - Get user by ID
- `PUT /api/users/:id` - Update user profile
- `DELETE /api/users/:id` - Delete user (admin only)
- `GET /api/users/:id/requests` - Get user's requests
- `POST /api/users/:id/block` - Block a user
- `DELETE /api/users/:id/block` - Unblock a user
- `GET /api/users/blocked/list` - Get blocked users list
- `GET /api/users/:id/blocked` - Check if user is blocked
- `POST /api/users/:id/report` - Report a user
- `GET /api/users/reports/my` - Get user's submitted reports
- `GET /api/users/blocked` - Get blocked users
- `GET /api/users/reports/all` - Get all reports (admin only)
- `PATCH /api/users/reports/:reportId` - Update report status (admin only)
- `POST /api/users/avatar` - Upload user avatar
- `DELETE /api/users/avatar` - Delete user avatar

### Donations

- `GET /api/donations` - Get all donations
- `GET /api/donations/:id` - Get donation by ID
- `GET /api/donations/:id/social-proof` - Get social proof data for a donation
- `POST /api/donations` - Create new donation
- `PUT /api/donations/:id` - Update donation
- `DELETE /api/donations/:id` - Delete donation
- `GET /api/donations/user/my-donations` - Get user's donations
- `GET /api/donations/stats` - Get donation statistics (admin only)

### Requests

- `GET /api/requests` - Get all requests
- `GET /api/requests/:id` - Get request by ID
- `GET /api/requests/receiver/my-requests` - Get my requests as receiver
- `GET /api/requests/donor/incoming-requests` - Get requests for my donations
- `POST /api/requests` - Create new request
- `PUT /api/requests/:id/status` - Update request status
- `DELETE /api/requests/:id` - Delete request
- `GET /api/requests/admin/stats` - Get request statistics (admin only)
- `POST /api/requests/:id/attachment` - Upload/update request attachment
- `DELETE /api/requests/:id/attachment` - Delete request attachment

### Request Updates

- `GET /api/request-updates/:requestId` - Get updates for a request
- `POST /api/request-updates` - Create a new request update
- `PUT /api/request-updates/:id` - Update a request update
- `DELETE /api/request-updates/:id` - Delete a request update

### Comments

- `GET /api/comments/:donationId` - Get comments for a donation
- `POST /api/comments/:donationId` - Create a new comment
- `PUT /api/comments/:id` - Update a comment
- `DELETE /api/comments/:id` - Delete a comment

### Shares

- `GET /api/shares/:donationId` - Get shares for a donation
- `POST /api/shares/:donationId` - Create a new share
- `DELETE /api/shares/:id` - Delete a share

### Verification

- `POST /api/verification/user/documents` - Upload user verification document
- `GET /api/verification/user/documents` - Get user verification documents
- `PUT /api/verification/user/documents/:documentId/verify` - Verify user document
- `POST /api/verification/request/:requestId/documents` - Upload request verification document
- `GET /api/verification/request/:requestId/documents` - Get request verification documents
- `PUT /api/verification/request/documents/:documentId/verify` - Verify request document
- `GET /api/verification/statistics` - Get verification statistics
- `GET /api/verification/pending/:type` - Get pending verification documents

### Messages

- `GET /api/messages/conversations` - Get all conversations
- `GET /api/messages/conversation/:userId` - Get messages for a conversation
- `POST /api/messages` - Send a new message
- `PUT /api/messages/:id/read` - Mark a message as read
- `PUT /api/messages/conversation/:userId/read` - Mark all messages in a conversation as read
- `GET /api/messages/unread-count` - Get unread message count
- `DELETE /api/messages/:id` - Delete a message
- `GET /api/messages/admin/stats` - Get message statistics (admin only)
- `GET /api/messages/conversations/archived` - Get archived conversations
- `PUT /api/messages/conversation/:userId/archive` - Archive a conversation
- `PUT /api/messages/conversation/:userId/unarchive` - Unarchive a conversation

### Notifications

- `GET /api/notifications` - Get all notifications
- `GET /api/notifications/unread-count` - Get unread notification count
- `PUT /api/notifications/:id/read` - Mark notification as read
- `PUT /api/notifications/read-all` - Mark all notifications as read
- `DELETE /api/notifications/:id` - Delete notification
- `DELETE /api/notifications` - Delete all notifications

### Ratings

- `GET /api/ratings/:userId` - Get user ratings
- `POST /api/ratings` - Submit a rating
- `PUT /api/ratings/:id` - Update a rating
- `DELETE /api/ratings/:id` - Delete a rating

### Analytics

- `GET /api/analytics/overview` - Get overview statistics
- `GET /api/analytics/donations/trends` - Get donation trends
- `GET /api/analytics/users/growth` - Get user growth
- `GET /api/analytics/donations/category-distribution` - Get category distribution
- `GET /api/analytics/requests/status-distribution` - Get status distribution
- `GET /api/analytics/donors/top` - Get top donors
- `GET /api/analytics/receivers/top` - Get top receivers
- `GET /api/analytics/donations/geographic-distribution` - Get geographic distribution
- `GET /api/analytics/requests/success-rate` - Get request success rate
- `GET /api/analytics/donations/statistics-over-time` - Get donation statistics over time
- `GET /api/analytics/activity/recent` - Get recent activity
- `GET /api/analytics/platform/stats` - Get platform statistics

### Activity

- `GET /api/activity/user/:userId` - Get user activity
- `GET /api/activity/donation/:donationId` - Get donation activity
- `GET /api/activity/request/:requestId` - Get request activity
- `GET /api/activity/admin/recent` - Get recent admin activity

### Search

- `GET /api/search/donations` - Search donations
- `GET /api/search/requests` - Search requests
- `GET /api/search/donations/filters` - Get donation filter options
- `GET /api/search/requests/filters` - Get request filter options

### Donation History

- `GET /api/donation-history/user/:userId` - Get user donation history
- `GET /api/donation-history/donation/:donationId` - Get donation history
- `GET /api/donation-history/export/:userId` - Export user donation history
- `GET /api/donation-history/receipt/:transactionId` - Get donation receipt

### Notification Preferences

- `GET /api/notification-preferences` - Get notification preferences
- `PUT /api/notification-preferences` - Update notification preferences

## Rate Limiting

To prevent API abuse and ensure fair usage, rate limiting is applied to various endpoints:

### General API Endpoints

- **Rate**: 100 requests per 15 minutes per IP
- **Applied to**: Most public and authenticated API endpoints

### Authentication Endpoints

- **Rate**: 5 requests per 15 minutes per IP
- **Applied to**: Login and registration endpoints

### Registration Endpoints

- **Rate**: 3 requests per hour per IP
- **Applied to**: User registration endpoints

### Password Reset Endpoints

- **Rate**: 3 requests per hour per IP
- **Applied to**: Password reset request endpoints

### Email Verification Endpoints

- **Rate**: 5 requests per hour per IP
- **Applied to**: Email verification endpoints

### File Upload Endpoints

- **Rate**: 20 requests per hour per IP
- **Applied to**: File upload endpoints

### Heavy Operation Endpoints

- **Rate**: 30 requests per 15 minutes per IP
- **Applied to**: Analytics, statistics, and search endpoints

When rate limits are exceeded, the API returns a 429 (Too Many Requests) status code with an appropriate error message.

## Setup and Installation
