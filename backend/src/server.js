const express = require("express");
const http = require("http");
const { Server } = require("socket.io");
const cors = require("cors");
const helmet = require("helmet");
const rateLimit = require("express-rate-limit");
const { sequelize, testConnection } = require("./config/db");
const MigrationRunner = require("./utils/migrationRunner");
const { errorHandler, notFound } = require("./utils/errorHandler");
const config = require("./config");
const User = require("./models/User");
const Donation = require("./models/Donation");
const Request = require("./models/Request");
const Message = require("./models/Message");
require("dotenv").config();

const app = express();
const server = http.createServer(app);
const io = new Server(server, config.socket);

const PORT = config.port;

// Security middleware
app.use(helmet(config.security.helmet));
app.use(cors(config.cors));

// Rate limiting
const limiter = rateLimit({
  windowMs: config.rateLimits.windowMs,
  max: config.rateLimits.maxRequests,
  message: {
    success: false,
    message: "Too many requests from this IP, please try again later.",
  },
});
app.use(limiter);

// Body parsing middleware
app.use(express.json({ limit: `${config.maxFileSize}mb` }));
app.use(express.urlencoded({ extended: true }));

// Database initialization using Migrations
async function initDatabase() {
  try {
    await testConnection();

    // Run database migrations
    const migrationRunner = new MigrationRunner(sequelize);
    await migrationRunner.runMigrations();
    console.log("✅ Database migrations completed successfully");

    // Auto-seed demo users if database is empty
    await seedDemoUsers();
  } catch (error) {
    console.error("❌ Database initialization failed:", error.message);
    console.log("🟡 Continuing without database...");
  }
}

// Auto-seed demo users if they don't exist
async function seedDemoUsers() {
  try {
    const User = require("./models/User");
    const bcrypt = require("bcryptjs");

    // Check if users exist
    const userCount = await User.count();

    if (userCount === 0) {
      console.log("🌱 No users found, seeding demo users...");

      const demoUsers = [
        {
          name: "Demo Donor",
          email: "demo@example.com",
          password: await bcrypt.hash("demo123", 10),
          role: "donor",
          phone: "+1234567890",
          location: "New York, NY",
        },
        {
          name: "Admin User",
          email: "admin@givingbridge.com",
          password: await bcrypt.hash("admin123", 10),
          role: "admin",
          phone: "+1234567891",
          location: "San Francisco, CA",
        },
        {
          name: "Demo Receiver",
          email: "receiver@example.com",
          password: await bcrypt.hash("receive123", 10),
          role: "receiver",
          phone: "+1234567892",
          location: "Los Angeles, CA",
        },
      ];

      await User.bulkCreate(demoUsers);
      console.log("✅ Demo users seeded successfully");
    } else {
      console.log(`✅ Found ${userCount} existing users, skipping seed`);
    }
  } catch (error) {
    console.error("⚠️ Failed to seed demo users:", error.message);
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

// Health check
app.get("/health", async (req, res) => {
  try {
    await sequelize.authenticate();
    res.json({
      status: "healthy",
      database: "connected",
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    res.json({
      status: "healthy",
      database: "disconnected",
      timestamp: new Date().toISOString(),
    });
  }
});

// API Routes
app.use("/api/auth", require("./routes/auth"));
app.use("/api/users", require("./routes/users"));
app.use("/api/donations", require("./routes/donations"));
app.use("/api/requests", require("./routes/requests"));
app.use("/api/messages", require("./routes/messages"));

// Socket.io configuration
require("./socket")(io);

// Error handling middleware (must be after routes)
app.use(notFound);
app.use(errorHandler);

// Start server
async function startServer() {
  await initDatabase();

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
    console.log(`🔌 Socket.IO ready for real-time connections`);
  });
}

// Handle graceful shutdown
process.on("SIGTERM", async () => {
  console.log("SIGTERM received, shutting down gracefully");
  await sequelize.close();
  process.exit(0);
});

process.on("SIGINT", async () => {
  console.log("SIGINT received, shutting down gracefully");
  await sequelize.close();
  process.exit(0);
});

startServer().catch((error) => {
  console.error("Failed to start server:", error);
  process.exit(1);
});

// Export for testing
module.exports = { app, server, io, sequelize };
