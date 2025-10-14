# GivingBridge API Documentation

## Base URL

- Development: `http://localhost:3000/api`
- Production: `https://api.givingbridge.com/api`

## Authentication

All protected endpoints require a JWT token in the Authorization header:

```
Authorization: Bearer <jwt_token>
```

## Response Format

All API responses follow this format:

```json
{
  "success": true|false,
  "message": "Description of the result",
  "data": {}, // Response data (if successful)
  "error": {}, // Error details (if failed)
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

## Error Codes

- `400` - Bad Request (validation errors)
- `401` - Unauthorized (invalid/missing token)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found
- `409` - Conflict (duplicate data)
- `429` - Too Many Requests (rate limited)
- `500` - Internal Server Error

---

## Authentication Endpoints

### POST /auth/register

Register a new user account.

**Request Body:**

```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "securePassword123",
  "role": "donor", // "donor", "receiver", or "admin"
  "phone": "+1234567890",
  "location": "New York, NY"
}
```

**Response (201 Created):**

```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "role": "donor",
      "phone": "+1234567890",
      "location": "New York, NY",
      "createdAt": "2024-01-15T10:30:00.000Z",
      "updatedAt": "2024-01-15T10:30:00.000Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

**Error Response (400 Bad Request):**

```json
{
  "success": false,
  "message": "Validation failed",
  "error": {
    "email": "Email already exists",
    "password": "Password must be at least 6 characters"
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

### POST /auth/login

Authenticate user and get access token.

**Request Body:**

```json
{
  "email": "john@example.com",
  "password": "securePassword123"
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "role": "donor",
      "phone": "+1234567890",
      "location": "New York, NY",
      "createdAt": "2024-01-15T10:30:00.000Z",
      "updatedAt": "2024-01-15T10:30:00.000Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

**Error Response (401 Unauthorized):**

```json
{
  "success": false,
  "message": "Invalid credentials",
  "error": {
    "code": "INVALID_CREDENTIALS",
    "details": "Email or password is incorrect"
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

### GET /auth/profile

Get current user profile (requires authentication).

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Profile retrieved successfully",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "role": "donor",
      "phone": "+1234567890",
      "location": "New York, NY",
      "avatarUrl": null,
      "createdAt": "2024-01-15T10:30:00.000Z",
      "updatedAt": "2024-01-15T10:30:00.000Z"
    }
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

---

## User Management Endpoints

### GET /users

Get all users (admin only).

**Query Parameters:**

- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 10)
- `role` (optional): Filter by role
- `search` (optional): Search by name or email

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Users retrieved successfully",
  "data": {
    "users": [
      {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com",
        "role": "donor",
        "phone": "+1234567890",
        "location": "New York, NY",
        "createdAt": "2024-01-15T10:30:00.000Z",
        "updatedAt": "2024-01-15T10:30:00.000Z"
      }
    ],
    "pagination": {
      "currentPage": 1,
      "totalPages": 5,
      "totalItems": 50,
      "itemsPerPage": 10,
      "hasNext": true,
      "hasPrev": false
    }
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

### GET /users/:id

Get user by ID.

**Response (200 OK):**

```json
{
  "success": true,
  "message": "User retrieved successfully",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "role": "donor",
      "phone": "+1234567890",
      "location": "New York, NY",
      "createdAt": "2024-01-15T10:30:00.000Z",
      "updatedAt": "2024-01-15T10:30:00.000Z"
    }
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

### PUT /users/:id

Update user profile.

**Request Body:**

```json
{
  "name": "John Smith",
  "phone": "+1987654321",
  "location": "Los Angeles, CA"
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "message": "User updated successfully",
  "data": {
    "user": {
      "id": 1,
      "name": "John Smith",
      "email": "john@example.com",
      "role": "donor",
      "phone": "+1987654321",
      "location": "Los Angeles, CA",
      "createdAt": "2024-01-15T10:30:00.000Z",
      "updatedAt": "2024-01-15T11:00:00.000Z"
    }
  },
  "timestamp": "2024-01-15T11:00:00.000Z"
}
```

---

## Donation Endpoints

### GET /donations

Get all donations with filtering and pagination.

**Query Parameters:**

- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 10)
- `category` (optional): Filter by category
- `location` (optional): Filter by location
- `status` (optional): Filter by status
- `search` (optional): Search by title or description

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Donations retrieved successfully",
  "data": {
    "donations": [
      {
        "id": 1,
        "title": "Winter Clothes Collection",
        "description": "Warm winter jackets and sweaters for adults",
        "category": "clothes",
        "condition": "excellent",
        "location": "New York, NY",
        "status": "available",
        "donorId": 1,
        "donor": {
          "id": 1,
          "name": "John Doe",
          "email": "john@example.com"
        },
        "createdAt": "2024-01-15T10:30:00.000Z",
        "updatedAt": "2024-01-15T10:30:00.000Z"
      }
    ],
    "pagination": {
      "currentPage": 1,
      "totalPages": 3,
      "totalItems": 25,
      "itemsPerPage": 10,
      "hasNext": true,
      "hasPrev": false
    }
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

### POST /donations

Create a new donation (donor only).

**Request Body:**

```json
{
  "title": "Books Collection",
  "description": "Classic novels and textbooks in good condition",
  "category": "books",
  "condition": "good",
  "location": "New York, NY"
}
```

**Response (201 Created):**

```json
{
  "success": true,
  "message": "Donation created successfully",
  "data": {
    "donation": {
      "id": 2,
      "title": "Books Collection",
      "description": "Classic novels and textbooks in good condition",
      "category": "books",
      "condition": "good",
      "location": "New York, NY",
      "status": "available",
      "donorId": 1,
      "createdAt": "2024-01-15T11:00:00.000Z",
      "updatedAt": "2024-01-15T11:00:00.000Z"
    }
  },
  "timestamp": "2024-01-15T11:00:00.000Z"
}
```

### PUT /donations/:id

Update donation (donor or admin only).

**Request Body:**

```json
{
  "title": "Updated Books Collection",
  "description": "Updated description",
  "status": "claimed"
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Donation updated successfully",
  "data": {
    "donation": {
      "id": 2,
      "title": "Updated Books Collection",
      "description": "Updated description",
      "category": "books",
      "condition": "good",
      "location": "New York, NY",
      "status": "claimed",
      "donorId": 1,
      "createdAt": "2024-01-15T11:00:00.000Z",
      "updatedAt": "2024-01-15T11:30:00.000Z"
    }
  },
  "timestamp": "2024-01-15T11:30:00.000Z"
}
```

---

## Request Endpoints

### GET /requests

Get all requests with filtering and pagination.

**Query Parameters:**

- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 10)
- `status` (optional): Filter by status
- `donorId` (optional): Filter by donor ID
- `receiverId` (optional): Filter by receiver ID

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Requests retrieved successfully",
  "data": {
    "requests": [
      {
        "id": 1,
        "donationId": 1,
        "donation": {
          "id": 1,
          "title": "Winter Clothes Collection",
          "category": "clothes"
        },
        "donorId": 1,
        "donorName": "John Doe",
        "receiverId": 2,
        "receiverName": "Jane Smith",
        "receiverEmail": "jane@example.com",
        "receiverPhone": "+1987654321",
        "message": "I would love to have these clothes for my family.",
        "status": "pending",
        "respondedAt": null,
        "createdAt": "2024-01-15T10:30:00.000Z",
        "updatedAt": "2024-01-15T10:30:00.000Z"
      }
    ],
    "pagination": {
      "currentPage": 1,
      "totalPages": 2,
      "totalItems": 15,
      "itemsPerPage": 10,
      "hasNext": true,
      "hasPrev": false
    }
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

### POST /requests

Create a new request (receiver only).

**Request Body:**

```json
{
  "donationId": 1,
  "message": "I would love to have these clothes for my family during winter.",
  "receiverName": "Jane Smith",
  "receiverEmail": "jane@example.com",
  "receiverPhone": "+1987654321"
}
```

**Response (201 Created):**

```json
{
  "success": true,
  "message": "Request created successfully",
  "data": {
    "request": {
      "id": 2,
      "donationId": 1,
      "donorId": 1,
      "donorName": "John Doe",
      "receiverId": 2,
      "receiverName": "Jane Smith",
      "receiverEmail": "jane@example.com",
      "receiverPhone": "+1987654321",
      "message": "I would love to have these clothes for my family during winter.",
      "status": "pending",
      "respondedAt": null,
      "createdAt": "2024-01-15T11:00:00.000Z",
      "updatedAt": "2024-01-15T11:00:00.000Z"
    }
  },
  "timestamp": "2024-01-15T11:00:00.000Z"
}
```

### PUT /requests/:id/status

Update request status (donor or admin only).

**Request Body:**

```json
{
  "status": "approved"
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Request status updated successfully",
  "data": {
    "request": {
      "id": 2,
      "donationId": 1,
      "donorId": 1,
      "donorName": "John Doe",
      "receiverId": 2,
      "receiverName": "Jane Smith",
      "receiverEmail": "jane@example.com",
      "receiverPhone": "+1987654321",
      "message": "I would love to have these clothes for my family during winter.",
      "status": "approved",
      "respondedAt": "2024-01-15T11:30:00.000Z",
      "createdAt": "2024-01-15T11:00:00.000Z",
      "updatedAt": "2024-01-15T11:30:00.000Z"
    }
  },
  "timestamp": "2024-01-15T11:30:00.000Z"
}
```

---

## Message Endpoints

### GET /messages/:conversationId

Get messages for a conversation.

**Query Parameters:**

- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 50)

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Messages retrieved successfully",
  "data": {
    "messages": [
      {
        "id": 1,
        "conversationId": "conv_123",
        "senderId": 1,
        "senderName": "John Doe",
        "content": "Hello, I'm interested in your donation.",
        "type": "text",
        "readAt": null,
        "createdAt": "2024-01-15T10:30:00.000Z",
        "updatedAt": "2024-01-15T10:30:00.000Z"
      }
    ],
    "pagination": {
      "currentPage": 1,
      "totalPages": 1,
      "totalItems": 5,
      "itemsPerPage": 50,
      "hasNext": false,
      "hasPrev": false
    }
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

### POST /messages

Send a new message.

**Request Body:**

```json
{
  "conversationId": "conv_123",
  "content": "Thank you for your interest!",
  "type": "text"
}
```

**Response (201 Created):**

```json
{
  "success": true,
  "message": "Message sent successfully",
  "data": {
    "message": {
      "id": 2,
      "conversationId": "conv_123",
      "senderId": 1,
      "senderName": "John Doe",
      "content": "Thank you for your interest!",
      "type": "text",
      "readAt": null,
      "createdAt": "2024-01-15T11:00:00.000Z",
      "updatedAt": "2024-01-15T11:00:00.000Z"
    }
  },
  "timestamp": "2024-01-15T11:00:00.000Z"
}
```

---

## Statistics Endpoints

### GET /stats/donations

Get donation statistics (admin only).

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Donation statistics retrieved successfully",
  "data": {
    "totalDonations": 150,
    "availableDonations": 45,
    "claimedDonations": 80,
    "completedDonations": 25,
    "donationsByCategory": {
      "clothes": 50,
      "books": 30,
      "electronics": 25,
      "furniture": 20,
      "other": 25
    },
    "donationsByLocation": {
      "New York, NY": 40,
      "Los Angeles, CA": 35,
      "Chicago, IL": 25,
      "Houston, TX": 20,
      "Phoenix, AZ": 15,
      "Other": 15
    }
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

### GET /stats/requests

Get request statistics (admin only).

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Request statistics retrieved successfully",
  "data": {
    "totalRequests": 200,
    "pendingRequests": 30,
    "approvedRequests": 120,
    "declinedRequests": 25,
    "completedRequests": 25,
    "requestsByStatus": {
      "pending": 30,
      "approved": 120,
      "declined": 25,
      "completed": 25
    },
    "averageResponseTime": "2.5 hours"
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

---

## Rate Limiting

The API implements rate limiting to prevent abuse:

- **General API**: 100 requests per 15 minutes
- **Login endpoint**: 5 attempts per 15 minutes
- **Registration endpoint**: 10 attempts per 15 minutes

When rate limited, you'll receive a 429 status code:

```json
{
  "success": false,
  "message": "Too many requests from this IP, please try again later.",
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "retryAfter": 900
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

---

## WebSocket Events

The API also supports real-time communication via WebSocket:

### Connection

Connect to: `ws://localhost:3000` (development) or `wss://api.givingbridge.com` (production)

### Events

#### `new_message`

Emitted when a new message is received.

```json
{
  "conversationId": "conv_123",
  "message": {
    "id": 1,
    "senderId": 1,
    "senderName": "John Doe",
    "content": "Hello!",
    "type": "text",
    "createdAt": "2024-01-15T10:30:00.000Z"
  }
}
```

#### `message_read`

Emitted when a message is read.

```json
{
  "messageId": 1,
  "readAt": "2024-01-15T10:35:00.000Z"
}
```

#### `user_typing`

Emitted when a user is typing.

```json
{
  "conversationId": "conv_123",
  "userId": 1,
  "isTyping": true
}
```

#### `user_online`

Emitted when a user comes online.

```json
{
  "userId": 1,
  "userName": "John Doe"
}
```

#### `user_offline`

Emitted when a user goes offline.

```json
{
  "userId": 1,
  "userName": "John Doe"
}
```
