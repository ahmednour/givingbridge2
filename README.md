# GivingBridge - Donation Platform

A comprehensive donation platform connecting donors and receivers, built with Node.js/Express backend and Flutter web frontend.

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose
- Node.js 18+ (for development)
- Flutter SDK (for frontend development)

### Running with Docker (Recommended)

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Running for Development

1. **Start Database**:

   ```bash
   docker-compose up -d db
   ```

2. **Start Backend**:

   ```bash
   cd backend
   npm install
   node src/server.js
   ```

3. **Start Frontend**:
   ```bash
   cd frontend
   flutter run -d chrome --web-port 8080
   ```

## 🏗️ Architecture

### Backend (Node.js/Express)

- **Location**: `./backend/`
- **Port**: 3000
- **Database**: MySQL 8.0
- **ORM**: Sequelize
- **Authentication**: JWT

### Frontend (Flutter Web)

- **Location**: `./frontend/`
- **Port**: 8080
- **State Management**: Provider pattern
- **UI Framework**: Flutter Material Design

### Database (MySQL)

- **Port**: 3307 (external), 3306 (internal)
- **Container**: `givingbridge_db`

## 📁 Project Structure

```
givingbridge/
├── backend/
│   ├── src/
│   │   ├── config/          # Database configuration
│   │   ├── models/          # Sequelize models
│   │   ├── routes/          # API routes
│   │   ├── middleware/      # Express middleware
│   │   └── server.js        # Main server file
│   ├── sql/                 # Database initialization
│   ├── .env                 # Environment variables
│   ├── package.json
│   └── Dockerfile
├── frontend/
│   ├── lib/
│   │   ├── core/           # App configuration & themes
│   │   ├── models/         # Data models
│   │   ├── providers/      # State management
│   │   ├── services/       # API services
│   │   ├── screens/        # UI screens
│   │   └── widgets/        # Reusable components
│   ├── web/                # Web-specific files
│   ├── pubspec.yaml
│   └── Dockerfile
├── docker-compose.yml
└── README.md
```

## 🔧 Configuration

### Environment Variables (.env)

```env
# Database Configuration
DB_HOST=localhost
DB_PORT=3307
DB_NAME=givingbridge
DB_USER=root
DB_PASSWORD=root

# Server Configuration
PORT=3000
NODE_ENV=development

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-change-in-production

# Frontend Configuration
FRONTEND_URL=http://localhost:8080
```

## 📚 Documentation

- [API Documentation](API_DOCUMENTATION.md) - Complete API reference with examples
- [Production Deployment Guide](PRODUCTION_DEPLOYMENT.md) - Security-focused deployment instructions
- [Architecture Overview](frontend/docs/ARCHITECTURE.md) - System architecture and design patterns
- [Component Documentation](frontend/docs/COMPONENTS.md) - Frontend component library

## 👥 User Roles

### Donor

- Browse donation requests
- Make donations
- View donation history
- Manage profile

### Receiver

- Create donation requests
- Manage requests
- View received donations
- Update request status

### Admin

- Manage all users
- Moderate requests
- View system analytics
- Administrative functions

## 🧪 Testing

### Demo User Credentials

```
Donor:    demo@example.com / demo123
Receiver: receiver@example.com / receive123
Admin:    admin@givingbridge.com / admin123
```

### API Testing

```bash
# Test registration
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"test123","role":"donor"}'

# Test login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@example.com","password":"demo123"}'
```

## 🗄️ Database Schema

### Users Table

```sql
CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role ENUM('donor', 'receiver', 'admin') DEFAULT 'donor',
  phone VARCHAR(255),
  location VARCHAR(255),
  avatarUrl VARCHAR(255),
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL
);
```

### Requests Table

```sql
CREATE TABLE requests (
  id INT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  amount DECIMAL(10,2),
  category VARCHAR(100),
  status ENUM('pending', 'approved', 'completed', 'cancelled') DEFAULT 'pending',
  user_id INT,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);
```

## 🔒 Security Features

- **JWT Authentication**: Secure token-based authentication
- **Password Hashing**: Bcrypt for password encryption
- **Input Validation**: Express-validator for request validation
- **CORS Protection**: Configured for cross-origin requests
- **SQL Injection Protection**: Sequelize ORM prevents SQL injection

## 🚀 Deployment

### Production Environment

1. Update environment variables for production
2. Build frontend: `flutter build web`
3. Use production Docker images
4. Configure reverse proxy (nginx)
5. Set up SSL certificates

### Docker Production

```bash
# Build and run in production mode
docker-compose -f docker-compose.prod.yml up -d
```

## 🐛 Troubleshooting

### Common Issues

1. **Backend connection refused**:

   - Ensure Docker database is running
   - Check database configuration in `.env`
   - Verify port 3307 is accessible

2. **Flutter icon errors**:

   - Icons are located in `frontend/web/icons/`
   - Ensure Icon-192.png exists and is valid

3. **Database connection errors**:
   - For Docker: Use `DB_HOST=db`
   - For local development: Use `DB_HOST=localhost` and `DB_PORT=3307`

### Logs

```bash
# Backend logs
docker-compose logs backend

# Database logs
docker-compose logs db

# All services
docker-compose logs -f
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/new-feature`
3. Commit changes: `git commit -am 'Add new feature'`
4. Push to branch: `git push origin feature/new-feature`
5. Submit pull request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For support and questions:

- Create an issue in the repository
- Contact the development team

---

**Note**: This is a development version. For production deployment, ensure proper security configurations and environment setup.
