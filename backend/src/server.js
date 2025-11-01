const express = require("express");
const http = require("http");
const { Server } = require("socket.io");
const cors = require("cors");
const helmet = require("helmet");
const rateLimit = require("express-rate-limit");
const compressionMiddleware = require("./middleware/compression");
require("dotenv").config();

// Import configuration and utilities
let config, sequelize, testConnection, MigrationRunner, errorHandler, notFound, models;
let notificationService;

try {
  // Load configuration with proper error handling
  config = require("./config");
  
  // Load database configuration
  const dbConfig = require("./config/db");
  sequelize = dbConfig.sequelize;
  testConnection = dbConfig.testConnection;
  
  // Load utilities
  MigrationRunner = require("./utils/migrationRunner");
  const errorHandlers = require("./utils/errorHandler");
  errorHandler = errorHandlers.errorHandler;
  notFound = errorHandlers.notFound;
  
  // Load models with error handling
  models = require("./models");
  
  // Load services with error handling
  notificationService = require("./services/notificationService");
  
  console.log("✅ All modules loaded successfully");
} catch (error) {
  console.error("❌ Failed to load required modules:", error.message);
  
  // Provide helpful error messages for common issues
  if (error.message.includes("Missing required environment variables")) {
    console.error("💡 Please check your .env file and ensure all required variables are set");
    console.error("Required variables: JWT_SECRET, DB_HOST, DB_NAME, DB_USER, DB_PASSWORD");
  }
  
  if (error.message.includes("Cannot find module")) {
    console.error("💡 Missing dependencies. Please run: npm install");
  }
  
  process.exit(1);
}

// GivingBridge Backend API Server
const app = express();
const server = http.createServer(app);

// Initialize Socket.IO with error handling
let io;
try {
  io = new Server(server, config.socket);
  console.log("✅ Socket.IO initialized successfully");
} catch (error) {
  console.error("❌ Failed to initialize Socket.IO:", error.message);
  console.log("🟡 Continuing without Socket.IO...");
}

const PORT = config.port;

// Import middleware
const logger = require("./utils/logger");
const { generalRateLimit, addRateLimitHeaders } = require("./middleware/rateLimiting");

// Import security middleware
const cookieParser = require('cookie-parser');
const { sanitizeInput } = require('./middleware/sanitization');

// Import Swagger configuration
const { specs, swaggerUi, swaggerOptions } = require("./config/swagger");

// Import response formatting
const { responseFormatter, addResponseHeaders, requestTiming } = require("./middleware/responseFormatter");

// Request timing middleware
app.use(requestTiming);

// Request logging middleware
app.use(logger.requestLogger());

// Compression middleware (before other middleware for best results)
app.use(compressionMiddleware);

// Security middleware
app.use(helmet(config.security.helmet));
app.use(cors(config.cors));

// API middleware

// Response formatting middleware
app.use(responseFormatter);
app.use(addResponseHeaders);

// Rate limiting middleware
app.use(addRateLimitHeaders());
app.use(generalRateLimit);

// Body parsing middleware with error handling
app.use(express.json({ 
  limit: `${config.maxFileSize}mb`,
  verify: (req, res, buf, encoding) => {
    try {
      JSON.parse(buf);
    } catch (error) {
      logger.warn("Invalid JSON in request body", { req, error: error.message });
      throw new Error("Invalid JSON format");
    }
  }
}));
app.use(express.urlencoded({ extended: true }));

// Security middleware - MUST be after body parsing
app.use(cookieParser());
app.use(sanitizeInput);

// Serve static files (avatars)
app.use("/uploads", express.static("uploads"));

// Swagger API Documentation
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(specs, swaggerOptions));

// Database initialization using Migrations
async function initDatabase() {
  try {
    console.log("🔄 Initializing database connection...");
    
    if (!sequelize) {
      console.error("❌ Database configuration not loaded");
      return false;
    }

    const isConnected = await testConnection();

    if (!isConnected) {
      console.log("🟡 Database connection failed, continuing without database...");
      return false;
    }

    console.log("🔄 Loading database models...");
    
    // Verify models are loaded properly
    if (!models || Object.keys(models).length === 0) {
      console.error("❌ No database models loaded");
      return false;
    }
    
    console.log(`✅ Loaded ${Object.keys(models).length} database models`);

    // Run database migrations with error handling
    console.log("🔄 Running database migrations...");
    const migrationRunner = new MigrationRunner(sequelize);
    await migrationRunner.runMigrations();
    console.log("✅ Database migrations completed successfully");

    // Auto-seed demo users if database is empty
    await seedDemoUsers();

    return true;
  } catch (error) {
    console.error("❌ Database initialization failed:", error.message);
    
    // Provide specific error guidance
    if (error.name === "SequelizeConnectionRefusedError") {
      console.error("💡 Database server is not running or connection refused");
      console.error("💡 Please check your database server and connection settings");
    } else if (error.name === "SequelizeAccessDeniedError") {
      console.error("💡 Database access denied - check username and password");
    } else if (error.name === "SequelizeDatabaseError") {
      console.error("💡 Database error - check if database exists and is accessible");
    }
    
    console.log("🟡 Continuing without database...");
    return false;
  }
}

// Auto-seed demo users if they don't exist
async function seedDemoUsers() {
  try {
    // Verify User model is available
    if (!models || !models.User) {
      console.log("⚠️ User model not available, skipping demo user seeding");
      return;
    }

    const bcrypt = require("bcryptjs");

    // Check if users exist
    const userCount = await models.User.count();

    if (userCount === 0) {
      console.log("🌱 No users found, seeding demo users...");

      const demoUsers = [
        {
          name: "Demo Donor",
          email: "demo@example.com",
          password: await bcrypt.hash("demo123", config.bcryptRounds),
          role: "donor",
          phone: "+1234567890",
          location: "New York, NY",
        },
        {
          name: "Admin User",
          email: "admin@givingbridge.com",
          password: await bcrypt.hash("admin123", config.bcryptRounds),
          role: "admin",
          phone: "+1234567891",
          location: "San Francisco, CA",
        },
        {
          name: "Demo Receiver",
          email: "receiver@example.com",
          password: await bcrypt.hash("receive123", config.bcryptRounds),
          role: "receiver",
          phone: "+1234567892",
          location: "Los Angeles, CA",
        },
      ];

      await models.User.bulkCreate(demoUsers);
      console.log("✅ Demo users seeded successfully");
    } else {
      console.log(`✅ Found ${userCount} existing users, skipping seed`);
    }
  } catch (error) {
    console.error("⚠️ Failed to seed demo users:", error.message);
    
    // Provide specific guidance for seeding errors
    if (error.name === "SequelizeValidationError") {
      console.error("💡 Validation error in demo user data");
    } else if (error.name === "SequelizeUniqueConstraintError") {
      console.error("💡 Demo users may already exist with conflicting data");
    }
  }
}

// Routes
app.get("/", (req, res) => {
  res.json({
    message: "Giving Bridge API Server",
    status: "running",
    timestamp: new Date().toISOString(),
  });
});

// API info endpoint
app.get("/api/version", (req, res) => {
  res.json({
    version: "1.0.0",
    name: "GivingBridge API",
    timestamp: new Date().toISOString()
  });
});

// Health check
app.get("/health", async (req, res) => {
  const healthStatus = {
    status: "healthy",
    timestamp: new Date().toISOString(),
    services: {
      database: "unknown",
      models: "unknown",
      notifications: "unknown"
    }
  };

  // Check database connection
  try {
    if (sequelize) {
      await sequelize.authenticate();
      healthStatus.services.database = "connected";
    } else {
      healthStatus.services.database = "not_configured";
    }
  } catch (error) {
    healthStatus.services.database = "disconnected";
  }

  // Check models
  try {
    if (models && Object.keys(models).length > 0) {
      healthStatus.services.models = "loaded";
    } else {
      healthStatus.services.models = "not_loaded";
    }
  } catch (error) {
    healthStatus.services.models = "error";
  }

  // Check notification services
  try {
    if (notificationService) {
      healthStatus.services.notifications = "available";
    } else {
      healthStatus.services.notifications = "unavailable";
    }
  } catch (error) {
    healthStatus.services.notifications = "unavailable";
  }

  res.json(healthStatus);
});

// API Routes
app.use("/api/auth", require("./routes/auth"));
app.use("/api/users", require("./routes/users"));
app.use("/api/donations", require("./routes/donations"));
app.use("/api/requests", require("./routes/requests"));
app.use("/api/request-updates", require("./routes/requestUpdates"));
app.use("/api/messages", require("./routes/messages"));
app.use("/api/notifications", require("./routes/notifications"));
app.use("/api/search", require("./routes/search"));
app.use("/api/donation-history", require("./routes/donationHistory"));

// Serve static files for receipts
app.use("/receipts", express.static("receipts"));

// Socket.io configuration
if (io) {
  try {
    require("./socket")(io);
    console.log("✅ Socket.IO configuration loaded successfully");
  } catch (error) {
    console.error("❌ Failed to configure Socket.IO:", error.message);
    console.log("🟡 Continuing without Socket.IO configuration...");
  }
}

// Error handling middleware (must be after routes)
app.use(logger.errorLogger()); // Log errors before handling them
app.use(notFound);
app.use(errorHandler);

// Start server
async function startServer() {
  console.log("🚀 Starting GivingBridge server...");
  
  // Initialize database
  const dbInitialized = await initDatabase();
  
  // Initialize services with error handling
  let servicesInitialized = 0;
  
  // Push notification service removed as part of MVP simplification

  // Initialize notification service (email + push + in-app) - remove duplicate
  try {
    if (notificationService) {
      notificationService.initialize();
      console.log("✅ Notification service initialized");
      servicesInitialized++;
    }
  } catch (error) {
    console.error("⚠️ Failed to initialize notification service:", error.message);
  }

  // Start HTTP server
  server.listen(PORT, "0.0.0.0", () => {
    console.log(`🚀 Server running on port ${PORT}`);
    console.log(
      `📱 Environment: ${
        config.isDevelopment
          ? "development"
          : config.isProduction
          ? "production"
          : "test"
      }`
    );
    
    if (io) {
      console.log(`🔌 Socket.IO ready for real-time connections`);
    }
    
    console.log(`💾 Database: ${dbInitialized ? "connected" : "disconnected"}`);
    console.log(`🔔 Services initialized: ${servicesInitialized}/2`);
    console.log(`🌐 Health check available at: http://localhost:${PORT}/health`);
  });
}

// Handle graceful shutdown
process.on("SIGTERM", async () => {
  console.log("SIGTERM received, shutting down gracefully");
  try {
    if (sequelize) {
      await sequelize.close();
      console.log("✅ Database connection closed");
    }
    if (server) {
      server.close(() => {
        console.log("✅ HTTP server closed");
      });
    }
  } catch (error) {
    console.error("❌ Error during shutdown:", error.message);
  }
  process.exit(0);
});

process.on("SIGINT", async () => {
  console.log("SIGINT received, shutting down gracefully");
  try {
    if (sequelize) {
      await sequelize.close();
      console.log("✅ Database connection closed");
    }
    if (server) {
      server.close(() => {
        console.log("✅ HTTP server closed");
      });
    }
  } catch (error) {
    console.error("❌ Error during shutdown:", error.message);
  }
  process.exit(0);
});

// Handle uncaught exceptions
process.on("uncaughtException", (error) => {
  console.error("❌ Uncaught Exception:", error.message);
  console.error(error.stack);
  process.exit(1);
});

// Handle unhandled promise rejections
process.on("unhandledRejection", (reason, promise) => {
  console.error("❌ Unhandled Rejection at:", promise, "reason:", reason);
  process.exit(1);
});

startServer().catch((error) => {
  console.error("❌ Failed to start server:", error.message);
  console.error(error.stack);
  
  // Provide helpful error messages
  if (error.message.includes("EADDRINUSE")) {
    console.error(`💡 Port ${PORT} is already in use. Please use a different port or stop the existing process.`);
  } else if (error.message.includes("EACCES")) {
    console.error(`💡 Permission denied to bind to port ${PORT}. Try using a port > 1024 or run with elevated privileges.`);
  }
  
  process.exit(1);
});

// Export for testing
module.exports = { app, server, io, sequelize };
