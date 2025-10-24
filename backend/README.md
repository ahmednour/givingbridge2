# GivingBridge Backend API

A production-ready Node.js/Express RESTful API for the GivingBridge donation platform with real-time messaging, notifications, and comprehensive analytics.

## 🚀 Quick Start

### Prerequisites

- Node.js 16+ and npm
- MySQL 8.0+
- Git

### Installation

```bash
# Clone the repository
cd backend

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
# Edit .env with your configuration
```

### Environment Configuration

Create a `.env` file in the backend directory:

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
JWT_SECRET=your_super_secret_key_change_in_production
JWT_EXPIRES_IN=7d

# File Upload
MAX_FILE_SIZE=10
```

### Database Setup

```bash
# Create database
mysql -u root -p
CREATE DATABASE givingbridge;
EXIT;

# Run migrations (automatic on server start)
npm run dev
```

### Running the Server

```bash
# Development mode with auto-reload
npm run dev

# Production mode
npm start

# Run tests
npm test
```

The server will start on `http://localhost:3000`

## 📚 Documentation

- **[Complete API Documentation](API_DOCUMENTATION.md)** - Detailed endpoint reference
- **[Phase 4 Plan](../docs/PHASE_4_PLAN.md)** - Feature roadmap and architecture

## 🧪 Testing the API

### Automated Test Script

```bash
# Ensure server is running first
npm run dev

# In another terminal, run tests
node test-api.js
```

### Manual Testing with cURL

```bash
# Health check
curl http://localhost:3000/health

# Register a user
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "role": "donor",
    "phone": "+1234567890",
    "location": "New York, NY"
  }'

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

## 🏗️ Project Structure

```
backend/
├── src/
│   ├── config/           # Database and app configuration
│   ├── controllers/      # Business logic layer
│   │   ├── authController.js
│   │   ├── userController.js
│   │   ├── donationController.js
│   │   ├── requestController.js
│   │   ├── messageController.js
│   │   ├── notificationController.js
│   │   ├── ratingController.js
│   │   └── analyticsController.js
│   ├── models/           # Sequelize ORM models
│   │   ├── User.js
│   │   ├── Donation.js
│   │   ├── Request.js
│   │   ├── Message.js
│   │   ├── Notification.js
│   │   └── Rating.js
│   ├── routes/           # API route definitions
│   │   ├── auth.js
│   │   ├── users.js
│   │   ├── donations.js
│   │   ├── requests.js
│   │   ├── messages.js
│   │   ├── notifications.js
│   │   ├── ratings.js
│   │   └── analytics.js
│   ├── middleware/       # Custom middleware
│   │   └── index.js      # Auth, validation, etc.
│   ├── migrations/       # Database migrations
│   │   ├── 001_create_users_table.js
│   │   ├── 002_create_donations_table.js
│   │   ├── 003_create_requests_table.js
│   │   ├── 004_create_messages_table.js
│   │   ├── 005_add_request_response_fields.js
│   │   ├── 006_create_notifications_table.js
│   │   └── 007_create_ratings_table.js
│   ├── utils/            # Utility functions
│   │   ├── errorHandler.js
│   │   └── migrationRunner.js
│   ├── constants/        # Application constants
│   │   └── index.js
│   ├── socket.js         # Socket.IO configuration
│   └── server.js         # Express app entry point
├── test-api.js           # API test script
├── .env.example          # Environment variables template
├── package.json
└── README.md
```

## 🔑 Key Features

### Authentication & Authorization

- JWT-based authentication
- Role-based access control (Admin, Donor, Receiver)
- Password hashing with bcrypt
- Token expiration and refresh

### Core Functionality

- **User Management**: Registration, login, profile management
- **Donations**: CRUD operations, filtering, search
- **Requests**: Request donations, approve/decline, track status
- **Messaging**: Real-time chat between users
- **Notifications**: System notifications with WebSocket support
- **Ratings**: 5-star rating system with feedback
- **Analytics**: Comprehensive admin dashboard statistics

### Real-time Features

- Socket.IO integration for live updates
- Real-time messaging
- Instant notification delivery
- Online/offline user status
- Typing indicators

### Security

- Helmet for HTTP headers security
- CORS configuration
- Rate limiting (100 requests/15min per IP)
- Input validation with express-validator
- SQL injection protection via Sequelize ORM

## 📊 API Endpoints Overview

### Authentication

- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - User login
- `GET /api/auth/me` - Get current user

### Users

- `GET /api/users` - Get all users (admin)
- `GET /api/users/:id` - Get user by ID
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user (admin)

### Donations

- `GET /api/donations` - Get all donations (paginated, filtered)
- `GET /api/donations/:id` - Get donation by ID
- `POST /api/donations` - Create donation (donor)
- `PUT /api/donations/:id` - Update donation
- `DELETE /api/donations/:id` - Delete donation

### Requests

- `GET /api/requests` - Get requests
- `POST /api/requests` - Create request (receiver)
- `PUT /api/requests/:id/status` - Update request status
- `GET /api/requests/receiver/my-requests` - My requests
- `GET /api/requests/donor/incoming-requests` - Incoming requests

### Messages

- `GET /api/messages/conversations` - Get all conversations
- `GET /api/messages/conversation/:userId` - Get messages with user
- `POST /api/messages` - Send message
- `GET /api/messages/unread-count` - Get unread count

### Notifications

- `GET /api/notifications` - Get notifications (paginated)
- `GET /api/notifications/unread-count` - Get unread count
- `PUT /api/notifications/:id/read` - Mark as read
- `PUT /api/notifications/read-all` - Mark all as read

### Ratings

- `POST /api/ratings` - Create rating
- `GET /api/ratings/donor/:donorId` - Get donor ratings
- `GET /api/ratings/receiver/:receiverId` - Get receiver ratings

### Analytics (Admin Only)

- `GET /api/analytics/overview` - Platform overview
- `GET /api/analytics/donations/trends` - Donation trends
- `GET /api/analytics/users/growth` - User growth
- `GET /api/analytics/donors/top` - Top donors

See [API_DOCUMENTATION.md](API_DOCUMENTATION.md) for complete details.

## 🔌 WebSocket Events

### Client → Server

- `send_message` - Send a message
- `typing` - Start typing indicator
- `stop_typing` - Stop typing indicator
- `mark_as_read` - Mark message as read
- `mark_notification_read` - Mark notification as read
- `get_unread_count` - Get unread message count

### Server → Client

- `new_message` - Receive new message
- `new_notification` - Receive new notification
- `user_online` - User came online
- `user_offline` - User went offline
- `unread_count` - Unread message count update

## 🛠️ Technology Stack

- **Runtime**: Node.js 16+
- **Framework**: Express.js 4.18
- **Database**: MySQL 8.0 with Sequelize ORM
- **Authentication**: JWT (jsonwebtoken)
- **Real-time**: Socket.IO
- **Validation**: express-validator
- **Security**: helmet, cors, bcryptjs
- **Rate Limiting**: express-rate-limit

## 📝 Database Schema

### Users Table

- User authentication and profile information
- Roles: donor, receiver, admin

### Donations Table

- Donation items with categories and conditions
- Status tracking (available, pending, completed)

### Requests Table

- Request lifecycle management
- Links donors and receivers
- Status: pending → approved → completed

### Messages Table

- Chat messages between users
- Read/unread status tracking

### Notifications Table

- System notifications
- 7 notification types
- Related entity tracking

### Ratings Table

- 5-star rating system
- Bi-directional (donor ↔ receiver)
- One rating per completed request

## 🚢 Deployment

### Production Checklist

1. **Environment Configuration**

   ```bash
   NODE_ENV=production
   # Set strong JWT_SECRET
   # Configure production database
   ```

2. **Security**

   - Enable HTTPS/SSL
   - Set up firewall rules
   - Configure reverse proxy (nginx)
   - Update CORS settings

3. **Database**

   - Run migrations
   - Create backup strategy
   - Optimize indexes

4. **Monitoring**

   - Set up error logging
   - Configure performance monitoring
   - Health check endpoints

5. **Start Server**
   ```bash
   npm start
   ```

### Using PM2 (Production)

```bash
# Install PM2
npm install -g pm2

# Start server
pm2 start src/server.js --name givingbridge-api

# Monitor
pm2 logs givingbridge-api
pm2 monit

# Auto-restart on reboot
pm2 startup
pm2 save
```

## 🧑‍💻 Development

### Adding a New Endpoint

1. Create controller method in `src/controllers/`
2. Add route in `src/routes/`
3. Add validation middleware
4. Test with `test-api.js`
5. Document in `API_DOCUMENTATION.md`

### Creating a Migration

```javascript
// src/migrations/008_your_migration.js
module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Migration logic
  },
  down: async (queryInterface, Sequelize) => {
    // Rollback logic
  },
};
```

### Code Style

- Use ES6+ features
- Follow async/await pattern
- Use try-catch for error handling
- Add JSDoc comments to controllers
- Keep controllers thin, models fat

## 🐛 Troubleshooting

### Database Connection Issues

```bash
# Check MySQL is running
mysql -u root -p

# Verify credentials in .env
# Check DB_HOST, DB_USER, DB_PASSWORD, DB_NAME
```

### Port Already in Use

```bash
# Find process using port 3000
# Windows
netstat -ano | findstr :3000

# Linux/Mac
lsof -i :3000

# Kill process or change PORT in .env
```

### Migration Errors

```bash
# Reset database
mysql -u root -p
DROP DATABASE givingbridge;
CREATE DATABASE givingbridge;

# Restart server (auto-runs migrations)
npm run dev
```

## 📞 Support

For issues or questions:

- Check [API_DOCUMENTATION.md](API_DOCUMENTATION.md)
- Review error logs in console
- Verify environment configuration
- Test with `node test-api.js`

## 📄 License

This project is part of the GivingBridge platform.

---

**Version**: 1.0.0  
**Last Updated**: October 20, 2025
