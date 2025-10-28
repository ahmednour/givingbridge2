module.exports = {
  testEnvironment: "node",
  testMatch: ["**/__tests__/**/*.js", "**/?(*.)+(spec|test).js"],
  collectCoverageFrom: [
    "src/**/*.js",
    "!src/server.js",
    "!src/socket.js",
    "!src/migrations/**",
    "!src/seeders/**",
    "!src/data-source.ts",
    "!src/config/test-db.js",
  ],
  coverageDirectory: "coverage",
  coverageReporters: ["text", "lcov", "html"],
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70,
    },
  },
  setupFilesAfterEnv: ["<rootDir>/src/__tests__/setup.js"],
  setupFiles: ["<rootDir>/src/__tests__/test-config.js"],
  testTimeout: 30000,
  verbose: true,
  forceExit: true,
  clearMocks: true,
  resetMocks: true,
  restoreMocks: true,
  // Use test database configuration
  globalSetup: "<rootDir>/src/__tests__/global-setup.js",
  globalTeardown: "<rootDir>/src/__tests__/global-teardown.js",
};
