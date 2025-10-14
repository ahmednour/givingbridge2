# Backend Test Suite

This directory contains comprehensive tests for the GivingBridge backend API.

## Test Structure

### Controllers

- `authController.test.js` - Authentication endpoints (register, login, logout, profile)
- `donationController.test.js` - Donation CRUD operations and filtering
- `requestController.test.js` - Request management and status updates
- `userController.test.js` - User management and profile operations

### Models

- `models.test.js` - Database model validation and relationships

### Middleware

- `middleware.test.js` - Authentication, authorization, validation, and error handling

## Running Tests

### Prerequisites

1. Install test dependencies:

   ```bash
   npm install
   ```

2. Ensure MySQL is running and accessible
3. Create a test database:
   ```sql
   CREATE DATABASE givingbridge_test;
   ```

### Commands

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage

# Run tests for CI
npm run test:ci
```

## Test Configuration

- **Database**: Uses `givingbridge_test` database
- **Environment**: Automatically set to `test`
- **JWT Secret**: Uses test-specific secret
- **Port**: Uses port 3001 to avoid conflicts

## Test Coverage

The test suite covers:

### Authentication

- User registration with validation
- Login with credentials
- JWT token generation and validation
- Profile retrieval
- Logout functionality

### Donations

- CRUD operations
- Filtering by category, location, availability
- Pagination
- Role-based access control
- Statistics for admin

### Requests

- Request creation and validation
- Status updates (approve, decline, complete, cancel)
- Role-based permissions
- Donation availability updates
- Statistics for admin

### Users

- User management (admin only)
- Profile updates
- Role validation
- User statistics
- Access control

### Models

- Data validation
- Foreign key relationships
- Cascade deletes
- Default values
- Enum validations

### Middleware

- Authentication middleware
- Authorization middleware
- Input validation
- Error handling
- Pagination
- Sorting

## Test Data

Tests use isolated test data that is:

- Created fresh for each test
- Cleaned up after each test
- Not dependent on external data

## Database Setup

Tests automatically:

1. Sync the database schema
2. Clear data between tests
3. Close connections after completion

## Best Practices

1. **Isolation**: Each test is independent
2. **Cleanup**: Data is cleared between tests
3. **Validation**: All inputs and outputs are validated
4. **Error Cases**: Both success and failure scenarios are tested
5. **Security**: Authentication and authorization are thoroughly tested
