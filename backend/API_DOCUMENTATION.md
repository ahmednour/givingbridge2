# GivingBridge Backend API - Complete Documentation

## 🚀 Overview

GivingBridge Backend API is a production-ready Node.js/Express RESTful API that powers the GivingBridge donation platform. It provides comprehensive endpoints for authentication, user management, donations, requests, messaging, notifications, ratings, and analytics.

## 📋 Table of Contents

- [Technology Stack](#technology-stack)
- [Getting Started](#getting-started)
- [API Endpoints](#api-endpoints)
- [Authentication](#authentication)
- [WebSocket Events](#websocket-events)
- [Database Models](#database-models)
- [Testing Guide](#testing-guide)

---

## 🛠️ Technology Stack

- **Runtime**: Node.js 16+
- **Framework**: Express.js 4.18
- **Database**: MySQL with Sequelize ORM
- **Authentication**: JWT (JSON Web Tokens)
- **Real-time**: Socket.IO
- **Validation**: Express-validator
- **Security**: Helmet, CORS, Rate Limiting

---

## 🏁 Getting Started

### Prerequisites

```bash
# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
# Edit .env with your database credentials
```

### Environment Variables

```env
# Server
NODE_ENV=development
PORT=3000

# Database
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=givingbridge
DB_PORT=3306

# JWT
JWT_SECRET=your_secret_key_here
JWT_EXPIRES_IN=7d

# File Upload
MAX_FILE_SIZE=10
```

### Running the Server

```bash
# Development mode
npm run dev

# Production mode
npm start

# Run migrations manually
npm run migrate
```

---

## 🔐 Authentication

All protected endpoints require a JWT token in the Authorization header:

```
Authorization: Bearer <your_jwt_token>
```

### Role-Based Access Control

- **Public**: Anyone (no authentication)
- **User**: Any authenticated user
- **Donor**: Users with donor role
- **Receiver**: Users with receiver role
- **Admin**: Users with admin role

---

## 📚 API Endpoints

### Base URL

```
http://localhost:3000/api
```

---

## 1️⃣ Authentication Endpoints

### Register User

**POST** `/auth/register`

**Body:**

```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "role": "donor",
  "phone": "+1234567890",
  "location": "New York, NY"
}
```

**Response:**

```json
{
  "success": true,
  "message": "User registered successfully",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "donor"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Login

**POST** `/auth/login`

**Body:**

```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

### Get Current User

**GET** `/auth/me`

**Headers:** `Authorization: Bearer <token>`

---

## 2️⃣ User Endpoints

### Get All Users (Admin Only)

**GET** `/users?page=1&limit=10&role=donor&search=john`

### Get User by ID

**GET** `/users/:id`

### Update User

**PUT** `/users/:id`

**Body:**

```json
{
  "name": "John Updated",
  "phone": "+1234567891",
  "location": "Los Angeles, CA",
  "avatarUrl": "https://example.com/avatar.jpg"
}
```

### Delete User (Admin Only)

**DELETE** `/users/:id`

---

## 3️⃣ Donation Endpoints

### Get All Donations

**GET** `/donations?page=1&limit=20&category=clothing&status=available&search=shirt`

**Query Parameters:**

- `page`: Page number (default: 1)
- `limit`: Items per page (default: 20)
- `category`: Filter by category (clothing, food, furniture, electronics, books, toys, other)
- `status`: Filter by status (available, pending, completed, cancelled)
- `search`: Search in title and description

### Get Donation by ID

**GET** `/donations/:id`

### Create Donation (Donor Only)

**POST** `/donations`

**Body:**

```json
{
  "title": "Men's Winter Jacket",
  "description": "Warm jacket, size L, like new",
  "category": "clothing",
  "condition": "like_new",
  "quantity": 1,
  "location": "New York, NY",
  "imageUrls": ["https://example.com/image1.jpg"]
}
```

### Update Donation

**PUT** `/donations/:id`

### Delete Donation

**DELETE** `/donations/:id`

### Get My Donations (Donor)

**GET** `/donations/donor/my-donations`

### Get Donation Statistics (Admin)

**GET** `/donations/admin/stats`

---

## 4️⃣ Request Endpoints

### Get All Requests

**GET** `/requests?page=1&limit=20&status=pending&donationId=1`

### Get Request by ID

**GET** `/requests/:id`

### Create Request (Receiver Only)

**POST** `/requests`

**Body:**

```json
{
  "donationId": 1,
  "message": "I really need this for my family. Thank you!"
}
```

### Update Request Status

**PUT** `/requests/:id/status`

**Body:**

```json
{
  "status": "approved",
  "responseMessage": "Approved! Please contact me to arrange pickup."
}
```

**Status Values:**

- `pending`: Initial status
- `approved`: Donor approved the request
- `declined`: Donor declined the request
- `completed`: Donation completed
- `cancelled`: Receiver cancelled the request

### Delete Request

**DELETE** `/requests/:id`

### Get My Requests (Receiver)

**GET** `/requests/receiver/my-requests`

### Get Incoming Requests (Donor)

**GET** `/requests/donor/incoming-requests`

### Get Request Statistics (Admin)

**GET** `/requests/admin/stats`

---

## 5️⃣ Message Endpoints

### Get All Conversations

**GET** `/messages/conversations`

**Response:**

```json
{
  "success": true,
  "conversations": [
    {
      "userId": 2,
      "userName": "Jane Smith",
      "lastMessage": {...},
      "unreadCount": 3,
      "donationId": 1,
      "requestId": 5
    }
  ]
}
```

### Get Conversation Messages

**GET** `/messages/conversation/:userId?page=1&limit=50`

### Send Message

**POST** `/messages`

**Body:**

```json
{
  "receiverId": 2,
  "content": "Hi! Is this item still available?",
  "donationId": 1,
  "requestId": 5
}
```

### Mark Message as Read

**PUT** `/messages/:id/read`

### Get Unread Count

**GET** `/messages/unread-count`

### Delete Message

**DELETE** `/messages/:id`

---

## 6️⃣ Notification Endpoints

### Get All Notifications

**GET** `/notifications?page=1&limit=20&unreadOnly=true`

**Response:**

```json
{
  "success": true,
  "notifications": [
    {
      "id": 1,
      "userId": 1,
      "type": "donation_request",
      "title": "New Donation Request",
      "message": "Jane Smith requested your donation: Winter Jacket",
      "isRead": false,
      "relatedId": 5,
      "relatedType": "request",
      "metadata": {},
      "createdAt": "2025-10-20T10:00:00.000Z"
    }
  ],
  "pagination": {
    "total": 10,
    "page": 1,
    "limit": 20,
    "totalPages": 1,
    "hasMore": false
  }
}
```

### Get Unread Count

**GET** `/notifications/unread-count`

### Mark Notification as Read

**PUT** `/notifications/:id/read`

### Mark All as Read

**PUT** `/notifications/read-all`

### Delete Notification

**DELETE** `/notifications/:id`

### Delete All Notifications

**DELETE** `/notifications`

---

## 7️⃣ Rating Endpoints

### Create Rating

**POST** `/ratings`

**Body:**

```json
{
  "requestId": 5,
  "rating": 5,
  "feedback": "Great donor! Very helpful and responsive."
}
```

**Note:** Only the donor or receiver involved in a completed request can submit a rating.

### Get Rating by Request

**GET** `/ratings/request/:requestId`

### Get Donor Ratings

**GET** `/ratings/donor/:donorId`

**Response:**

```json
{
  "success": true,
  "ratings": [...],
  "average": 4.8,
  "count": 15
}
```

### Get Receiver Ratings

**GET** `/ratings/receiver/:receiverId`

### Update Rating

**PUT** `/ratings/request/:requestId`

**Body:**

```json
{
  "rating": 4,
  "feedback": "Updated feedback"
}
```

### Delete Rating

**DELETE** `/ratings/request/:requestId`

---

## 8️⃣ Analytics Endpoints (Admin Only)

### Get Overview Statistics

**GET** `/analytics/overview`

**Response:**

```json
{
  "success": true,
  "data": {
    "users": {
      "total": 150,
      "donors": 80,
      "receivers": 65,
      "admins": 5
    },
    "donations": {
      "total": 200,
      "available": 50,
      "completed": 120
    },
    "requests": {
      "total": 300,
      "pending": 30,
      "approved": 50,
      "completed": 180,
      "declined": 40
    }
  }
}
```

### Get Donation Trends

**GET** `/analytics/donations/trends?days=30`

### Get User Growth

**GET** `/analytics/users/growth?days=30`

### Get Category Distribution

**GET** `/analytics/donations/categories`

### Get Status Distribution

**GET** `/analytics/donations/status`

### Get Top Donors

**GET** `/analytics/donors/top?limit=10`

### Get Recent Activity

**GET** `/analytics/activity/recent?limit=20`

### Get Platform Statistics

**GET** `/analytics/platform/stats`

---

## 🔌 WebSocket Events

Connect to Socket.IO with JWT authentication:

```javascript
const socket = io("http://localhost:3000", {
  auth: {
    token: "your_jwt_token",
  },
});
```

### Client → Server Events

#### Send Message

```javascript
socket.emit("send_message", {
  receiverId: 2,
  content: "Hello!",
  donationId: 1, // optional
  requestId: 5, // optional
});
```

#### Typing Indicators

```javascript
socket.emit("typing", { receiverId: 2 });
socket.emit("stop_typing", { receiverId: 2 });
```

#### Mark Message as Read

```javascript
socket.emit("mark_as_read", { messageId: 123 });
socket.emit("mark_conversation_read", { otherUserId: 2 });
```

#### Notifications

```javascript
socket.emit("mark_notification_read", { notificationId: 456 });
socket.emit("mark_all_notifications_read");
socket.emit("get_unread_notification_count");
```

#### Get Unread Counts

```javascript
socket.emit("get_unread_count");
socket.emit("get_unread_notification_count");
```

### Server → Client Events

#### Connection Status

```javascript
socket.on("user_online", (data) => {
  console.log(`User ${data.userId} is online`);
});

socket.on("user_offline", (data) => {
  console.log(`User ${data.userId} is offline`);
});
```

#### Messages

```javascript
socket.on("message_sent", (data) => {
  // Confirmation of sent message
});

socket.on("new_message", (message) => {
  // New message received
  console.log(message);
});

socket.on("message_read", (data) => {
  // Someone read your message
});

socket.on("conversation_read", (data) => {
  // Someone read your conversation
});

socket.on("user_typing", (data) => {
  console.log(`User ${data.userId} is typing: ${data.typing}`);
});
```

#### Notifications

```javascript
socket.on("new_notification", (notification) => {
  console.log("New notification:", notification);
});

socket.on("unread_notification_count", (data) => {
  console.log(`Unread notifications: ${data.count}`);
});
```

#### Unread Counts

```javascript
socket.on("unread_count", (data) => {
  console.log(`Unread messages: ${data.count}`);
});
```

---

## 💾 Database Models

### User

- **Fields**: id, name, email, password, role, phone, location, avatarUrl
- **Roles**: donor, receiver, admin

### Donation

- **Fields**: id, donorId, title, description, category, condition, quantity, location, imageUrls, isAvailable, status
- **Categories**: clothing, food, furniture, electronics, books, toys, other
- **Conditions**: new, like_new, good, fair

### Request

- **Fields**: id, donationId, donorId, receiverId, donorName, receiverName, receiverEmail, receiverPhone, message, status, responseMessage, respondedAt
- **Statuses**: pending, approved, declined, completed, cancelled

### Message

- **Fields**: id, senderId, senderName, receiverId, receiverName, donationId, requestId, content, isRead

### Notification

- **Fields**: id, userId, type, title, message, isRead, relatedId, relatedType, metadata
- **Types**: donation_request, donation_approved, new_donation, message, reminder, system, celebration

### Rating

- **Fields**: id, requestId, donorId, receiverId, ratedBy, rating, feedback
- **Rating Range**: 1-5 stars

---

## 🧪 Testing Guide

### Using cURL

#### Register

```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "test123",
    "role": "donor",
    "phone": "+1234567890",
    "location": "New York, NY"
  }'
```

#### Login

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "test123"
  }'
```

#### Get Donations (with auth)

```bash
curl -X GET http://localhost:3000/api/donations \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Using Postman

1. Import the API collection (create from this documentation)
2. Set environment variable `{{baseUrl}}` = `http://localhost:3000/api`
3. Set environment variable `{{token}}` after login
4. Use `{{token}}` in Authorization header: `Bearer {{token}}`

### Testing WebSocket

```javascript
const io = require("socket.io-client");

const socket = io("http://localhost:3000", {
  auth: { token: "YOUR_TOKEN_HERE" },
});

socket.on("connect", () => {
  console.log("Connected!");

  // Send a message
  socket.emit("send_message", {
    receiverId: 2,
    content: "Test message",
  });
});

socket.on("new_message", (message) => {
  console.log("Received:", message);
});
```

---

## 🔒 Security Features

- **Helmet**: HTTP headers security
- **CORS**: Cross-Origin Resource Sharing
- **Rate Limiting**: 100 requests per 15 minutes per IP
- **JWT**: Token-based authentication with expiration
- **Password Hashing**: bcrypt with salt rounds
- **Input Validation**: express-validator
- **SQL Injection Protection**: Sequelize ORM parameterized queries

---

## 📊 Error Handling

All endpoints follow consistent error response format:

```json
{
  "success": false,
  "message": "Error description",
  "error": "Detailed error message",
  "errors": [
    {
      "field": "email",
      "message": "Email is required"
    }
  ]
}
```

**HTTP Status Codes:**

- `200`: Success
- `201`: Created
- `400`: Bad Request
- `401`: Unauthorized
- `403`: Forbidden
- `404`: Not Found
- `409`: Conflict
- `500`: Internal Server Error

---

## 🚀 Deployment

### Production Checklist

- [ ] Set `NODE_ENV=production`
- [ ] Use strong `JWT_SECRET`
- [ ] Configure production database
- [ ] Enable SSL/HTTPS
- [ ] Set up reverse proxy (nginx)
- [ ] Configure firewall
- [ ] Set up monitoring
- [ ] Enable logging
- [ ] Run migrations
- [ ] Seed initial admin user

---

## 📞 Support

For issues or questions, please contact the development team.

---

**Version**: 1.0.0  
**Last Updated**: October 20, 2025
