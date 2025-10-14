# GivingBridge - Quick Start Guide

## Prerequisites

- Docker Desktop installed and running
- Ports 3000, 3307, and 8080 available

## Start the Application

### 1. Start Docker Desktop

Make sure Docker Desktop is running on your system.

### 2. Navigate to Project Directory

```bash
cd "D:\project\git project\givingbridge"
```

### 3. Start All Services

```bash
docker-compose up -d
```

Wait for all containers to start (about 30-60 seconds).

### 4. Verify Services are Running

```bash
docker ps
```

You should see 3 containers:

- `givingbridge_db` - Database (port 3307)
- `givingbridge_backend` - API Server (port 3000)
- `givingbridge_frontend` - Web App (port 8080)

### 5. Access the Application

Open your browser and go to: **http://localhost:8080**

## Demo User Credentials

### Donor Account

- **Email:** demo@example.com
- **Password:** demo123
- **Can:** Create donations, view incoming requests, approve/decline requests

### Receiver Account

- **Email:** receiver@example.com
- **Password:** receive123
- **Can:** Browse donations, create requests, view request status

### Admin Account

- **Email:** admin@givingbridge.com
- **Password:** admin123
- **Can:** Manage all users, donations, and requests

## Testing the Complete Flow

### As Donor:

1. Login with demo@example.com / demo123
2. Click "Create Donation" button
3. Fill in donation details:
   - Title: "Winter Clothes"
   - Description: "Warm jackets and sweaters"
   - Category: Clothes
   - Condition: Good
   - Location: "New York, NY"
4. Submit the donation
5. View it in "My Donations"

### As Receiver:

1. Logout and login with receiver@example.com / receive123
2. Go to "Browse Donations"
3. Find the donation you just created
4. Click on it and create a request
5. View your request in "My Requests"

### Back as Donor:

1. Logout and login again as demo@example.com / demo123
2. Go to "Browse Requests" or check dashboard
3. See the incoming request
4. Approve or decline it
5. The receiver will see the status change

## Language Switching

Click the language switcher button in the top navigation to switch between English and Arabic (العربية).

## API Testing

### Health Check

```powershell
curl http://localhost:3000/health
```

### Login

```powershell
$body = @{email='demo@example.com';password='demo123'} | ConvertTo-Json
Invoke-WebRequest -Uri http://localhost:3000/api/auth/login -Method POST -Body $body -ContentType 'application/json'
```

## Troubleshooting

### Container won't start

```bash
docker-compose logs [container-name]
```

### Reset everything

```bash
docker-compose down -v
docker-compose up -d
```

### Database connection errors

Check that port 3307 is not in use by another application.

### Frontend not loading

```bash
docker-compose restart frontend
```

## Stop the Application

```bash
docker-compose down
```

To also remove volumes (database data):

```bash
docker-compose down -v
```

## For Your Instructor

This application demonstrates:

- ✅ Full-stack web application (Node.js backend + Flutter web frontend)
- ✅ RESTful API with authentication (JWT)
- ✅ MySQL database with proper schema
- ✅ Real-time features (Socket.IO for messaging)
- ✅ Bilingual support (English and Arabic)
- ✅ Role-based access control (Donor, Receiver, Admin)
- ✅ Docker containerization for easy deployment
- ✅ Complete donation management system

### Key Features Implemented:

1. **User Authentication**: Secure login/registration with password hashing
2. **Donation Management**: Create, browse, update, delete donations
3. **Request System**: Receivers can request donations, donors can approve/decline
4. **Messaging**: Real-time chat between donors and receivers
5. **Admin Panel**: User and donation management
6. **Responsive Design**: Works on desktop and tablet screens
7. **Bilingual**: Full English and Arabic support with RTL layout

### Technical Highlights:

- Clean MVC architecture in backend
- Provider pattern for state management in frontend
- Database migrations for schema management
- Comprehensive API documentation
- Error handling and validation throughout
- Security best practices (CORS, rate limiting, JWT, bcrypt)

---

**Project by:** [Your Name]
**Date:** October 2025
**Technology Stack:** Node.js, Express, MySQL, Flutter Web, Docker
