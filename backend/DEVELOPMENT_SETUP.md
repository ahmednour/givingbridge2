# GivingBridge Development Setup Guide

## Table of Contents
- [Prerequisites](#prerequisites)
- [Environment Setup](#environment-setup)
- [Database Setup](#database-setup)
- [Backend Setup](#backend-setup)
- [Frontend Setup](#frontend-setup)
- [Development Workflow](#development-workflow)
- [Testing](#testing)
- [Debugging](#debugging)
- [Common Issues](#common-issues)

## Prerequisites

### Required Software
- **Node.js** (v16.0.0 or higher)
- **npm** (v8.0.0 or higher) or **yarn** (v1.22.0 or higher)
- **MySQL** (v8.0 or higher)
- **Git** (v2.30.0 or higher)
- **Flutter** (v3.0.0 or higher) - for frontend development

### Recommended Tools
- **Visual Studio Code** with extensions:
  - ESLint
  - Prettier
  - REST Client
  - MySQL
  - Flutter
- **Postman** or **Insomnia** for API testing
- **MySQL Workbench** for database management
- **Docker** (optional, for containerized development)

## Environment Setup

### 1. Clone the Repository
```bash
git clone https://github.com/your-org/givingbridge.git
cd givingbridge
```

### 2. Environment Variables
Create environment files for different environments:

#### Backend Environment (.env)
```bash
# Copy the example file
cp backend/.env.example backend/.env
```

Edit `backend/.env` with your configuration:
```env
# Server Configuration
NODE_ENV=development
PORT=3000
FRONTEND_URL=http://localhost:3001

# Database Configuration
DB_HOST=localhost
DB_PORT=3306
DB_NAME=givingbridge_dev
DB_USER=your_username
DB_PASSWORD=your_password

# Test Database
TEST_DB_NAME=givingbridge_test

# JWT Configuration
JWT_SECRET=your_super_secret_jwt_key_here
JWT_EXPIRES_IN=7d

# Email Configuration (for development, use Mailtrap or similar)
EMAIL_HOST=smtp.mailtrap.io
EMAIL_PORT=2525
EMAIL_USER=your_mailtrap_user
EMAIL_PASS=your_mailtrap_pass
EMAIL_FROM=noreply@givingbridge.com

# Firebase Configuration (optional for push notifications)
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_PRIVATE_KEY_ID=your_private_key_id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nyour_private_key\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=your_service_account_email
FIREBASE_CLIENT_ID=your_client_id

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
LOGIN_RATE_LIMIT_WINDOW_MS=900000
LOGIN_RATE_LIMIT_MAX_ATTEMPTS=5

# File Upload
MAX_FILE_SIZE=10
UPLOAD_PATH=./uploads

# Security
BCRYPT_ROUNDS=12
```

#### Frontend Environment
Create `frontend/.env`:
```env
# API Configuration
REACT_APP_API_URL=http://localhost:3000/api
REACT_APP_SOCKET_URL=http://localhost:3000

# Firebase Configuration (if using)
REACT_APP_FIREBASE_API_KEY=your_api_key
REACT_APP_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
REACT_APP_FIREBASE_PROJECT_ID=your_project_id
REACT_APP_FIREBASE_STORAGE_BUCKET=your_project.appspot.com
REACT_APP_FIREBASE_MESSAGING_SENDER_ID=123456789
REACT_APP_FIREBASE_APP_ID=1:123456789:web:abcdef123456
```

## Database Setup

### 1. Install MySQL
#### On macOS (using Homebrew):
```bash
brew install mysql
brew services start mysql
```

#### On Ubuntu/Debian:
```bash
sudo apt update
sudo apt install mysql-server
sudo systemctl start mysql
sudo systemctl enable mysql
```

#### On Windows:
Download and install MySQL from the official website.

### 2. Create Databases
```sql
-- Connect to MySQL as root
mysql -u root -p

-- Create development database
CREATE DATABASE givingbridge_dev CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create test database
CREATE DATABASE givingbridge_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create user (optional, for security)
CREATE USER 'givingbridge_user'@'localhost' IDENTIFIED BY 'your_secure_password';
GRANT ALL PRIVILEGES ON givingbridge_dev.* TO 'givingbridge_user'@'localhost';
GRANT ALL PRIVILEGES ON givingbridge_test.* TO 'givingbridge_user'@'localhost';
FLUSH PRIVILEGES;

-- Exit MySQL
EXIT;
```

### 3. Verify Database Connection
```bash
cd backend
npm run test:setup
```

## Backend Setup

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Run Database Migrations
```bash
# Run all migrations
npm run migrate

# Or run migrations manually
node src/run-all-migrations.js
```

### 3. Seed Demo Data (Optional)
```bash
npm run seed
```

### 4. Start Development Server
```bash
# Start with nodemon (auto-restart on changes)
npm run dev

# Or start normally
npm start
```

The backend server will start on `http://localhost:3000`

### 5. Verify Setup
- Visit `http://localhost:3000` - should show API status
- Visit `http://localhost:3000/health` - should show health check
- Visit `http://localhost:3000/api-docs` - should show Swagger documentation

## Frontend Setup

### 1. Install Flutter
Follow the official Flutter installation guide: https://flutter.dev/docs/get-started/install

### 2. Install Dependencies
```bash
cd frontend
flutter pub get
```

### 3. Run the Application
```bash
# For web development
flutter run -d chrome

# For mobile development (with emulator/device connected)
flutter run
```

The frontend will be available at `http://localhost:3001` (or the port Flutter assigns)

## Development Workflow

### 1. Branch Strategy
```bash
# Create feature branch
git checkout -b feature/your-feature-name

# Make changes and commit
git add .
git commit -m "feat: add your feature description"

# Push and create pull request
git push origin feature/your-feature-name
```

### 2. Code Style
We use ESLint and Prettier for JavaScript/Node.js code:

```bash
# Install globally (optional)
npm install -g eslint prettier

# Run linting
npm run lint

# Fix linting issues
npm run lint:fix

# Format code
npm run format
```

### 3. Pre-commit Hooks
Install husky for pre-commit hooks:
```bash
cd backend
npx husky install
npx husky add .husky/pre-commit "npm run lint && npm run test"
```

## Testing

### Backend Testing
```bash
cd backend

# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage

# Run specific test file
npm test -- --testPathPattern=auth

# Run tests for specific environment
NODE_ENV=test npm test
```

### Frontend Testing
```bash
cd frontend

# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

### API Testing with Postman
1. Import the Postman collection from `docs/postman/`
2. Set up environment variables in Postman
3. Run the collection to test all endpoints

## Debugging

### Backend Debugging
#### Using VS Code:
1. Create `.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Backend",
      "program": "${workspaceFolder}/backend/src/server.js",
      "env": {
        "NODE_ENV": "development"
      },
      "console": "integratedTerminal",
      "restart": true,
      "runtimeExecutable": "nodemon",
      "skipFiles": ["<node_internals>/**"]
    }
  ]
}
```

2. Set breakpoints and press F5 to start debugging

#### Using Node.js Inspector:
```bash
cd backend
node --inspect src/server.js
```
Then open Chrome and go to `chrome://inspect`

### Frontend Debugging
#### Flutter DevTools:
```bash
flutter run --debug
# In another terminal
flutter pub global activate devtools
flutter pub global run devtools
```

### Database Debugging
```bash
# Enable query logging in MySQL
SET GLOBAL general_log = 'ON';
SET GLOBAL log_output = 'table';

# View query log
SELECT * FROM mysql.general_log ORDER BY event_time DESC LIMIT 10;
```

## Common Issues

### 1. Database Connection Issues
**Problem**: `ER_ACCESS_DENIED_ERROR` or connection refused

**Solutions**:
- Check MySQL is running: `brew services list | grep mysql`
- Verify credentials in `.env` file
- Check database exists: `SHOW DATABASES;`
- Ensure user has proper permissions

### 2. Port Already in Use
**Problem**: `EADDRINUSE: address already in use :::3000`

**Solutions**:
```bash
# Find process using port
lsof -ti:3000

# Kill process
kill -9 $(lsof -ti:3000)

# Or use different port
PORT=3001 npm run dev
```

### 3. Module Not Found Errors
**Problem**: `Cannot find module 'xyz'`

**Solutions**:
```bash
# Clear npm cache
npm cache clean --force

# Delete node_modules and reinstall
rm -rf node_modules package-lock.json
npm install

# Check Node.js version
node --version
```

### 4. Migration Errors
**Problem**: Migration fails or database schema issues

**Solutions**:
```bash
# Reset database (WARNING: This will delete all data)
mysql -u root -p -e "DROP DATABASE givingbridge_dev; CREATE DATABASE givingbridge_dev;"

# Run migrations again
npm run migrate

# Check migration status
node src/utils/migrationRunner.js --status
```

### 5. JWT Token Issues
**Problem**: Invalid token or authentication errors

**Solutions**:
- Check JWT_SECRET in `.env` file
- Verify token format in requests
- Check token expiration
- Clear browser localStorage/cookies

### 6. File Upload Issues
**Problem**: File uploads fail or files not found

**Solutions**:
- Check `uploads/` directory exists and is writable
- Verify MAX_FILE_SIZE setting
- Check file type restrictions
- Ensure proper multipart/form-data headers

### 7. Flutter Build Issues
**Problem**: Flutter build fails or dependency conflicts

**Solutions**:
```bash
# Clean Flutter cache
flutter clean
flutter pub get

# Update Flutter
flutter upgrade

# Check Flutter doctor
flutter doctor
```

## Performance Tips

### 1. Database Optimization
- Use database indexes for frequently queried fields
- Implement connection pooling
- Use prepared statements
- Monitor slow queries

### 2. API Optimization
- Implement caching with Redis
- Use compression middleware
- Optimize database queries
- Implement pagination

### 3. Frontend Optimization
- Use Flutter's build optimization
- Implement lazy loading
- Optimize images and assets
- Use efficient state management

## Additional Resources

- [API Documentation](http://localhost:3000/api-docs)
- [Contributing Guidelines](CONTRIBUTING.md)
- [Code Style Guide](CODE_STYLE.md)
- [Deployment Guide](DEPLOYMENT.md)
- [Security Guidelines](SECURITY.md)

## Getting Help

1. Check this documentation first
2. Search existing GitHub issues
3. Create a new issue with:
   - Clear description of the problem
   - Steps to reproduce
   - Environment details
   - Error messages/logs
4. Join our developer Discord/Slack channel

## Quick Start Checklist

- [ ] Prerequisites installed
- [ ] Repository cloned
- [ ] Environment variables configured
- [ ] Database created and connected
- [ ] Backend dependencies installed
- [ ] Database migrations run
- [ ] Backend server running
- [ ] Frontend dependencies installed
- [ ] Frontend application running
- [ ] API documentation accessible
- [ ] Tests passing

Happy coding! 🚀