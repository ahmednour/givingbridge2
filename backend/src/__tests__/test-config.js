// Test configuration for Jest
process.env.NODE_ENV = "test";

// Test database configuration
process.env.TEST_DB_HOST = "localhost";
process.env.TEST_DB_PORT = "3306";
process.env.TEST_DB_NAME = "givingbridge_test";
process.env.TEST_DB_USER = "root";
process.env.TEST_DB_PASSWORD = "root";

// Fallback to regular DB config if test config not available
process.env.DB_HOST = process.env.TEST_DB_HOST || "localhost";
process.env.DB_PORT = process.env.TEST_DB_PORT || "3306";
process.env.DB_NAME = process.env.TEST_DB_NAME || "givingbridge_test";
process.env.DB_USER = process.env.TEST_DB_USER || "root";
process.env.DB_PASSWORD = process.env.TEST_DB_PASSWORD || "root";

// JWT configuration for testing
process.env.JWT_SECRET =
  "test-super-secret-jwt-key-that-is-at-least-32-characters-long-for-testing";
process.env.JWT_EXPIRES_IN = "1h";
process.env.PORT = "3001";

// Email configuration for testing
process.env.EMAIL_HOST = "smtp.example.com";
process.env.EMAIL_PORT = "587";
process.env.EMAIL_USER = "test@example.com";
process.env.EMAIL_PASS = "testpassword";
process.env.EMAIL_FROM = "noreply@test.com";
process.env.APP_NAME = "GivingBridge Test";

// Disable logging in tests
process.env.LOG_LEVEL = "error";
