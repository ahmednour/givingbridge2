// Test configuration for Jest
process.env.NODE_ENV = "test";
process.env.DB_HOST = "localhost";
process.env.DB_PORT = "3307";
process.env.DB_NAME = "givingbridge_test";
process.env.DB_USER = "root";
process.env.DB_PASSWORD = "secure_root_password_2024";
process.env.JWT_SECRET =
  "test-super-secret-jwt-key-that-is-at-least-32-characters-long-for-testing";
process.env.JWT_EXPIRES_IN = "1h";
process.env.PORT = "3001";
