# GivingBridge - Donation Platform

A comprehensive donation platform connecting donors and receivers, built with Node.js/Express backend and Flutter web frontend. GivingBridge facilitates meaningful connections between those who want to give and those in need, creating a transparent and secure environment for charitable donations.

## ✨ Features

### 🎯 Core Functionality
- **Multi-role System**: Donors, Receivers, and Administrators with distinct capabilities
- **Real-time Messaging**: Socket.io powered communication between users
- **Secure Authentication**: JWT-based authentication with bcrypt password hashing
- **File Upload Support**: Image and document uploads with security scanning
- **Advanced Search**: Full-text search across donations and requests
- **Analytics Dashboard**: Comprehensive platform statistics and insights

### 🔒 Security & Performance
- **Rate Limiting**: Configurable rate limits for different endpoint types
- **Input Validation**: Express-validator for comprehensive request validation
- **XSS Protection**: Sanitization of user inputs to prevent cross-site scripting
- **CORS Configuration**: Secure cross-origin resource sharing
- **Redis Caching**: Performance optimization with Redis integration
- **Health Monitoring**: Built-in health checks and monitoring endpoints

### 🌐 Modern Architecture
- **RESTful API**: Well-documented API with Swagger/OpenAPI specification
- **Responsive Design**: Flutter web frontend optimized for all devices
- **Containerized Deployment**: Docker and Docker Compose for easy deployment
- **Database Migrations**: Sequelize ORM with version-controlled schema changes
- **Testing Suite**: Comprehensive unit and integration tests

## 🚀 Quick Start

### Prerequisites

- **Docker & Docker Compose** (recommended for quick setup)
- **Node.js 16+** (for development)
- **Flutter SDK 3.0+** (for frontend development)
- **MySQL 8.0+** (if running without Docker)

### Option 1: Docker Setup (Recommended)

```bash
# Clone the repository
git clone https://github.com/your-org/givingbridge.git
cd givingbridge

# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Access the application
# Frontend: http://localhost:8080
# Backend API: http://localhost:3000
# API Documentation: http://localhost:3000/api-docs

# Stop services
docker-compose down
```

### Option 2: Development Setup

1. **Database Setup**:
   ```bash
   # Start MySQL with Docker
   docker-compose up -d db
   
   # Or install MySQL locally and create database
   mysql -u root -p -e "CREATE DATABASE givingbridge CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
   ```

2. **Backend Setup**:
   ```bash
   cd backend
   npm install
   
   # Copy and configure environment variables
   cp .env.example .env
   # Edit .env with your database credentials
   
   # Run database migrations
   npm run migrate
   
   # Seed demo data (optional)
   npm run seed
   
   # Start development server
   npm run dev
   ```

3. **Frontend Setup**:
   ```bash
   cd frontend
   flutter pub get
   
   # Run on web
   flutter run -d chrome --web-port 8080
   ```

## 🏗️ Architecture

### Backend (Node.js/Express)
- **Location**: `./backend/`
- **Port**: 3000 (configurable)
- **Runtime**: Node.js 16+
- **Framework**: Express.js with comprehensive middleware stack
- **Database**: MySQL 8.0 with Sequelize ORM
- **Authentication**: JWT with 7-day expiration
- **Real-time**: Socket.io for live messaging
- **Caching**: Redis for performance optimization
- **Security**: Helmet, CORS, rate limiting, input validation
- **Documentation**: Swagger/OpenAPI 3.0 specification
- **Testing**: Jest with supertest for API testing
- **Code Quality**: ESLint, Prettier, Husky pre-commit hooks

### Frontend (Flutter Web)
- **Location**: `./frontend/`
- **Port**: 8080 (development)
- **Framework**: Flutter 3.0+ for web
- **State Management**: Provider pattern with ChangeNotifier
- **UI Framework**: Material Design 3 with custom theming
- **Routing**: GoRouter for declarative navigation
- **HTTP Client**: Built-in http package with interceptors
- **Internationalization**: Flutter's built-in i18n support
- **Notifications**: Firebase Cloud Messaging integration
- **Testing**: Widget tests and integration tests
- **Build**: Optimized web builds with code splitting

### Database (MySQL 8.0)
- **Development**: Port 3307 (external), 3306 (internal)
- **Production**: Secure internal networking
- **Container**: `givingbridge_db` with persistent volumes
- **Character Set**: utf8mb4 for full Unicode support
- **Authentication**: mysql_native_password plugin
- **Backup**: Automated daily backups (production)
- **Monitoring**: Health checks and performance metrics

## 📁 Project Structure

```
givingbridge/
├── backend/                    # Node.js/Express API Server
│   ├── src/
│   │   ├── config/            # Database & app configuration
│   │   ├── controllers/       # Route handlers & business logic
│   │   ├── middleware/        # Express middleware (auth, validation, etc.)
│   │   ├── models/            # Sequelize database models
│   │   ├── routes/            # API route definitions
│   │   ├── services/          # Business logic services
│   │   ├── utils/             # Utility functions & helpers
│   │   ├── seeders/           # Database seed files
│   │   └── server.js          # Main application entry point
│   ├── scripts/               # Utility scripts (testing, migration)
│   ├── sql/                   # Database initialization & migrations
│   ├── uploads/               # File upload storage
│   ├── .env.example           # Environment variables template
│   ├── package.json           # Dependencies & scripts
│   ├── jest.config.js         # Testing configuration
│   ├── Dockerfile             # Container configuration
│   └── API_DOCUMENTATION.md   # Comprehensive API docs
├── frontend/                   # Flutter Web Application
│   ├── lib/
│   │   ├── core/              # App configuration, themes, constants
│   │   ├── models/            # Data models & DTOs
│   │   ├── providers/         # State management (Provider pattern)
│   │   ├── services/          # API services & HTTP clients
│   │   ├── screens/           # UI screens & pages
│   │   ├── widgets/           # Reusable UI components
│   │   └── utils/             # Utility functions & helpers
│   ├── web/                   # Web-specific assets & configuration
│   ├── integration_test/      # End-to-end tests
│   ├── test/                  # Unit & widget tests
│   ├── pubspec.yaml           # Flutter dependencies
│   ├── l10n.yaml              # Internationalization config
│   └── Dockerfile             # Container configuration
├── database/                   # Database configuration
│   ├── conf/                  # MySQL configuration files
│   ├── init/                  # Database initialization scripts
│   └── migrations/            # Database migration files
├── nginx/                      # Reverse proxy configuration
├── .github/                    # GitHub Actions CI/CD workflows
├── .kiro/                      # Kiro IDE configuration
├── docker-compose.yml          # Development environment
├── docker-compose.prod.yml     # Production environment
├── CONTRIBUTING.md             # Contribution guidelines
└── README.md                   # This file
```

## 🔧 Configuration

### Backend Environment Variables (.env)

```env
# Server Configuration
NODE_ENV=development
PORT=3000
FRONTEND_URL=http://localhost:8080

# Database Configuration
DB_HOST=localhost
DB_PORT=3307
DB_NAME=givingbridge
DB_USER=givingbridge_user
DB_PASSWORD=secure_prod_password_2024

# JWT Configuration
JWT_SECRET=prod_jwt_secret_key_2024_secure_random_string_min_32_chars_long
JWT_EXPIRES_IN=7d

# Security Configuration
BCRYPT_ROUNDS=14
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=500
LOGIN_RATE_LIMIT_WINDOW_MS=900000
LOGIN_RATE_LIMIT_MAX_ATTEMPTS=50

# File Upload Configuration
MAX_FILE_SIZE=10
UPLOAD_PATH=./uploads

# Email Configuration (for notifications)
EMAIL_HOST=smtp.example.com
EMAIL_PORT=587
EMAIL_USER=your_email_user
EMAIL_PASS=your_email_password
EMAIL_FROM=noreply@givingbridge.com

# Redis Configuration (optional, for caching)
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# Firebase Configuration (for push notifications)
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_PRIVATE_KEY_ID=your_private_key_id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nyour_private_key\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=your_service_account_email

# Logging Configuration
LOG_LEVEL=info
SENTRY_DSN=your_sentry_dsn_for_error_tracking
```

### Frontend Environment Variables

```env
# API Configuration
BACKEND_API_URL=http://localhost:3000/api
SOCKET_URL=http://localhost:3000

# Firebase Configuration (for push notifications)
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_STORAGE_BUCKET=your_project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:web:abcdef123456
```

## 📚 Documentation

### API Documentation
- **[Interactive API Docs](http://localhost:3000/api-docs)** - Swagger UI with live testing
- **[API Documentation](backend/API_DOCUMENTATION.md)** - Comprehensive API reference
- **[Development Setup](backend/DEVELOPMENT_SETUP.md)** - Detailed development guide

### Project Documentation
- **[Contributing Guidelines](CONTRIBUTING.md)** - How to contribute to the project
- **[Architecture Overview](frontend/docs/ARCHITECTURE.md)** - System design and patterns
- **[Component Library](frontend/docs/COMPONENTS.md)** - Frontend component documentation

### Integration Guides
- **[Backend Integration](frontend/BACKEND_INTEGRATION_COMPLETE.md)** - API integration guide
- **[Provider Updates](frontend/PROVIDERS_UPDATE_COMPLETE.md)** - State management guide
- **[Screen Integration](frontend/SCREENS_INTEGRATION_COMPLETE.md)** - UI implementation guide

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
Donor:     demo@example.com / demo123
Receiver:  receiver@example.com / receive123
Admin:     admin@givingbridge.com / admin123
```

### Backend Testing

```bash
cd backend

# Run all tests
npm test

# Run tests with coverage
npm run test:coverage

# Run tests in watch mode
npm run test:watch

# Run specific test suite
npm test -- --testPathPattern=auth

# Run integration tests
npm run test:ci
```

### Frontend Testing

```bash
cd frontend

# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run tests with coverage
flutter test --coverage
```

### API Testing Examples

```bash
# Health check
curl http://localhost:3000/health

# Register new user
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "securePassword123",
    "role": "donor"
  }'

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "demo@example.com",
    "password": "demo123"
  }'

# Get user profile (requires token)
curl -X GET http://localhost:3000/api/auth/me \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Create donation request
curl -X POST http://localhost:3000/api/requests \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Winter Clothing Needed",
    "description": "Need warm clothes for winter season",
    "category": "clothing",
    "amount": 100.00
  }'
```

### Load Testing

```bash
# Install artillery for load testing
npm install -g artillery

# Run load tests
artillery run backend/tests/load/api-load-test.yml
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

### Production Deployment

#### Prerequisites
- Docker & Docker Compose
- SSL certificates (Let's Encrypt recommended)
- Domain name configured
- Production database (MySQL 8.0+)
- Redis instance (optional, for caching)

#### Quick Production Setup

```bash
# Clone repository
git clone https://github.com/your-org/givingbridge.git
cd givingbridge

# Configure production environment
cp backend/.env.example backend/.env
# Edit backend/.env with production values

# Build and start production services
docker-compose -f docker-compose.prod.yml up -d

# Check service health
docker-compose -f docker-compose.prod.yml ps
docker-compose -f docker-compose.prod.yml logs -f
```

#### Manual Production Setup

1. **Database Setup**:
   ```bash
   # Create production database
   mysql -u root -p -e "CREATE DATABASE givingbridge_prod CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
   
   # Create dedicated user
   mysql -u root -p -e "CREATE USER 'givingbridge_prod'@'%' IDENTIFIED BY 'secure_password';"
   mysql -u root -p -e "GRANT ALL PRIVILEGES ON givingbridge_prod.* TO 'givingbridge_prod'@'%';"
   ```

2. **Backend Deployment**:
   ```bash
   cd backend
   npm ci --production
   npm run migrate
   NODE_ENV=production npm start
   ```

3. **Frontend Deployment**:
   ```bash
   cd frontend
   flutter build web --release
   # Serve build/web/ with nginx or your preferred web server
   ```

4. **Nginx Configuration**:
   ```nginx
   server {
       listen 80;
       server_name yourdomain.com;
       return 301 https://$server_name$request_uri;
   }

   server {
       listen 443 ssl http2;
       server_name yourdomain.com;
       
       ssl_certificate /path/to/certificate.crt;
       ssl_certificate_key /path/to/private.key;
       
       location / {
           root /path/to/frontend/build/web;
           try_files $uri $uri/ /index.html;
       }
       
       location /api {
           proxy_pass http://localhost:3000;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }
   }
   ```

### Environment-Specific Configurations

#### Development
- Debug logging enabled
- Hot reload for frontend
- Test database with seed data
- Relaxed security settings

#### Staging
- Production-like environment
- Limited test data
- SSL certificates
- Performance monitoring

#### Production
- Optimized builds
- Secure configurations
- Database backups
- Error tracking (Sentry)
- Performance monitoring
- Load balancing (if needed)

## 🐛 Troubleshooting

### Common Issues

#### Backend Issues

1. **Database Connection Errors**:
   ```bash
   # Check if MySQL is running
   docker-compose ps db
   
   # Verify database credentials
   mysql -h localhost -P 3307 -u givingbridge_user -p givingbridge
   
   # Check environment variables
   cat backend/.env | grep DB_
   ```

2. **Port Already in Use**:
   ```bash
   # Find process using port 3000
   lsof -ti:3000
   
   # Kill the process
   kill -9 $(lsof -ti:3000)
   
   # Or use different port
   PORT=3001 npm run dev
   ```

3. **JWT Token Issues**:
   - Verify JWT_SECRET is set and consistent
   - Check token expiration (default 7 days)
   - Clear browser localStorage/cookies
   - Ensure Authorization header format: `Bearer <token>`

4. **Migration Errors**:
   ```bash
   # Check migration status
   npm run migrate:status
   
   # Reset database (WARNING: destroys data)
   npm run migrate:reset
   
   # Run specific migration
   npm run migrate:up -- --name migration_name
   ```

#### Frontend Issues

1. **Flutter Build Errors**:
   ```bash
   # Clean Flutter cache
   flutter clean
   flutter pub get
   
   # Check Flutter doctor
   flutter doctor
   
   # Update Flutter
   flutter upgrade
   ```

2. **API Connection Issues**:
   - Verify BACKEND_API_URL in environment
   - Check CORS configuration in backend
   - Ensure backend is running and accessible
   - Check browser network tab for failed requests

3. **State Management Issues**:
   - Verify Provider is properly wrapped around app
   - Check for proper context usage
   - Ensure ChangeNotifier.notifyListeners() is called

#### Docker Issues

1. **Container Won't Start**:
   ```bash
   # Check container logs
   docker-compose logs [service_name]
   
   # Rebuild containers
   docker-compose build --no-cache
   
   # Remove and recreate containers
   docker-compose down -v
   docker-compose up -d
   ```

2. **Database Persistence Issues**:
   ```bash
   # Check volumes
   docker volume ls
   
   # Inspect volume
   docker volume inspect givingbridge_db_data
   
   # Backup database
   docker exec givingbridge_db mysqldump -u root -p givingbridge > backup.sql
   ```

### Debugging Tools

#### Backend Debugging
```bash
# Enable debug logging
DEBUG=* npm run dev

# Run with Node.js inspector
node --inspect src/server.js

# Use VS Code debugger
# Add to .vscode/launch.json:
{
  "type": "node",
  "request": "launch",
  "name": "Debug Backend",
  "program": "${workspaceFolder}/backend/src/server.js",
  "env": { "NODE_ENV": "development" }
}
```

#### Frontend Debugging
```bash
# Run with verbose logging
flutter run -d chrome --verbose

# Enable Flutter inspector
flutter run --debug

# Use browser dev tools
# Open Chrome DevTools -> Flutter Inspector
```

### Performance Issues

1. **Slow Database Queries**:
   ```sql
   -- Enable slow query log
   SET GLOBAL slow_query_log = 'ON';
   SET GLOBAL long_query_time = 1;
   
   -- Check slow queries
   SELECT * FROM mysql.slow_log ORDER BY start_time DESC LIMIT 10;
   ```

2. **High Memory Usage**:
   ```bash
   # Monitor container resources
   docker stats
   
   # Check Node.js memory usage
   node --max-old-space-size=4096 src/server.js
   ```

3. **Frontend Performance**:
   ```bash
   # Build with performance profiling
   flutter build web --profile
   
   # Analyze bundle size
   flutter build web --analyze-size
   ```

### Getting Help

1. **Check Logs First**:
   ```bash
   # All services
   docker-compose logs -f
   
   # Specific service
   docker-compose logs backend
   
   # Backend application logs
   tail -f backend/logs/app.log
   ```

2. **Health Checks**:
   ```bash
   # Backend health
   curl http://localhost:3000/health
   
   # Database health
   curl http://localhost:3000/api/health/db
   
   # API status
   curl http://localhost:3000/api/status
   ```

3. **Community Support**:
   - Check [GitHub Issues](https://github.com/your-org/givingbridge/issues)
   - Review [API Documentation](http://localhost:3000/api-docs)
   - Consult [Development Setup Guide](backend/DEVELOPMENT_SETUP.md)
   - Join our developer Discord/Slack channel

## 🤝 Contributing

We welcome contributions from the community! Please read our [Contributing Guidelines](CONTRIBUTING.md) for detailed information.

### Quick Start for Contributors

1. **Fork & Clone**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/givingbridge.git
   cd givingbridge
   git remote add upstream https://github.com/ORIGINAL_OWNER/givingbridge.git
   ```

2. **Create Feature Branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make Changes**:
   - Follow coding standards (ESLint, Prettier)
   - Write tests for new functionality
   - Update documentation as needed

4. **Test Your Changes**:
   ```bash
   # Backend tests
   cd backend && npm test
   
   # Frontend tests
   cd frontend && flutter test
   
   # Integration tests
   npm run test:integration
   ```

5. **Commit & Push**:
   ```bash
   git commit -m "feat: add your feature description"
   git push origin feature/your-feature-name
   ```

6. **Create Pull Request**:
   - Use the PR template
   - Include screenshots for UI changes
   - Link related issues

### Development Standards

- **Code Style**: ESLint + Prettier for JavaScript, Dart formatter for Flutter
- **Commit Messages**: Follow [Conventional Commits](https://www.conventionalcommits.org/)
- **Testing**: Maintain 80%+ code coverage
- **Documentation**: Update docs for new features
- **Security**: Follow OWASP guidelines

### Areas for Contribution

- 🐛 **Bug Fixes**: Check issues labeled `bug`
- ✨ **New Features**: Issues labeled `enhancement`
- 📚 **Documentation**: Improve guides and API docs
- 🧪 **Testing**: Increase test coverage
- 🎨 **UI/UX**: Frontend improvements
- 🔒 **Security**: Security enhancements
- 🚀 **Performance**: Optimization opportunities

## �  Project Status

### Current Version: 1.0.0

- ✅ **Backend API**: Fully functional with comprehensive endpoints
- ✅ **Frontend Web App**: Complete Flutter web application
- ✅ **Authentication**: JWT-based secure authentication
- ✅ **Database**: MySQL with Sequelize ORM and migrations
- ✅ **Real-time Features**: Socket.io messaging system
- ✅ **File Uploads**: Secure file handling with validation
- ✅ **Testing**: Unit and integration test suites
- ✅ **Documentation**: Comprehensive API and development docs
- ✅ **Docker Support**: Full containerization for all services
- ✅ **Security**: Rate limiting, input validation, XSS protection

### Roadmap

#### v1.1.0 (Next Release)
- [ ] Mobile app (Flutter iOS/Android)
- [ ] Advanced analytics dashboard
- [ ] Email notification system
- [ ] Payment integration (Stripe/PayPal)
- [ ] Advanced search filters
- [ ] User verification system

#### v1.2.0 (Future)
- [ ] Multi-language support
- [ ] Social media integration
- [ ] Advanced reporting features
- [ ] API rate limiting per user
- [ ] Webhook system for integrations

## 🛡️ Security

### Security Features
- **Authentication**: JWT tokens with secure expiration
- **Password Security**: Bcrypt hashing with configurable rounds
- **Input Validation**: Comprehensive request validation
- **Rate Limiting**: Configurable limits to prevent abuse
- **XSS Protection**: Input sanitization and output encoding
- **CORS**: Properly configured cross-origin requests
- **SQL Injection**: Sequelize ORM prevents SQL injection
- **File Upload Security**: Type validation and size limits

### Reporting Security Issues
- **DO NOT** create public issues for security vulnerabilities
- Email: security@givingbridge.com
- Include detailed reproduction steps
- Allow reasonable time for fixes before disclosure

## 📝 License

This project is licensed under the **MIT License**.

```
MIT License

Copyright (c) 2024 GivingBridge

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 📞 Support & Community

### Getting Help
- 📖 **Documentation**: Start with our comprehensive docs
- 🐛 **Bug Reports**: [Create an issue](https://github.com/your-org/givingbridge/issues/new?template=bug_report.md)
- 💡 **Feature Requests**: [Request a feature](https://github.com/your-org/givingbridge/issues/new?template=feature_request.md)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/your-org/givingbridge/discussions)

### Community
- 🌟 **Star the repo** if you find it useful
- 🐦 **Follow us** on social media for updates
- 💬 **Join our Discord** for real-time chat
- 📧 **Newsletter**: Subscribe for project updates

### Professional Support
- 📧 **Email**: support@givingbridge.com
- 🕐 **Response Time**: 24-48 hours
- 🚨 **Emergency Support**: Available for critical production issues

---

## 🙏 Acknowledgments

- **Contributors**: Thanks to all our amazing contributors
- **Open Source**: Built with love using open source technologies
- **Community**: Special thanks to our community for feedback and support

---

**Made with ❤️ by the GivingBridge Team**

*Connecting hearts, changing lives, one donation at a time.*
