const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const { body, validationResult } = require("express-validator");
const router = express.Router();

// Mock user storage (replace with database queries)
let users = [];
let nextUserId = 1;

// JWT Secret (use environment variable in production)
const JWT_SECRET = process.env.JWT_SECRET || "your-super-secret-jwt-key";

// Register route
router.post(
  "/register",
  [
    body("name")
      .trim()
      .isLength({ min: 2 })
      .withMessage("Name must be at least 2 characters"),
    body("email")
      .isEmail()
      .normalizeEmail()
      .withMessage("Please provide a valid email"),
    body("password")
      .isLength({ min: 6 })
      .withMessage("Password must be at least 6 characters"),
    body("role")
      .isIn(["donor", "receiver", "admin"])
      .withMessage("Invalid role"),
  ],
  async (req, res) => {
    try {
      // Check for validation errors
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          message: "Validation failed",
          errors: errors.array(),
        });
      }

      const { name, email, password, role, phone, location } = req.body;

      // Check if user already exists
      const existingUser = users.find((user) => user.email === email);
      if (existingUser) {
        return res.status(400).json({
          message: "User with this email already exists",
        });
      }

      // Hash password
      const saltRounds = 12;
      const hashedPassword = await bcrypt.hash(password, saltRounds);

      // Create new user
      const newUser = {
        id: nextUserId++,
        name,
        email,
        password: hashedPassword,
        role: role || "donor",
        phone: phone || null,
        location: location || null,
        avatarUrl: null,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };

      users.push(newUser);

      // Generate JWT token
      const token = jwt.sign(
        {
          userId: newUser.id,
          email: newUser.email,
          role: newUser.role,
        },
        JWT_SECRET,
        { expiresIn: "7d" }
      );

      // Remove password from response
      const { password: _, ...userResponse } = newUser;

      res.status(201).json({
        message: "User registered successfully",
        user: userResponse,
        token,
      });
    } catch (error) {
      console.error("Registration error:", error);
      res.status(500).json({
        message: "Registration failed",
        error: error.message,
      });
    }
  }
);

// Login route
router.post(
  "/login",
  [
    body("email")
      .isEmail()
      .normalizeEmail()
      .withMessage("Please provide a valid email"),
    body("password").notEmpty().withMessage("Password is required"),
  ],
  async (req, res) => {
    try {
      // Check for validation errors
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          message: "Validation failed",
          errors: errors.array(),
        });
      }

      const { email, password } = req.body;

      // Find user by email
      const user = users.find((user) => user.email === email);
      if (!user) {
        return res.status(401).json({
          message: "Invalid email or password",
        });
      }

      // Check password
      const isPasswordValid = await bcrypt.compare(password, user.password);
      if (!isPasswordValid) {
        return res.status(401).json({
          message: "Invalid email or password",
        });
      }

      // Generate JWT token
      const token = jwt.sign(
        {
          userId: user.id,
          email: user.email,
          role: user.role,
        },
        JWT_SECRET,
        { expiresIn: "7d" }
      );

      // Remove password from response
      const { password: _, ...userResponse } = user;

      res.json({
        message: "Login successful",
        user: userResponse,
        token,
      });
    } catch (error) {
      console.error("Login error:", error);
      res.status(500).json({
        message: "Login failed",
        error: error.message,
      });
    }
  }
);

// Logout route (client-side token removal)
router.post("/logout", (req, res) => {
  res.json({
    message: "Logged out successfully",
  });
});

// Middleware to verify JWT token
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1]; // Bearer TOKEN

  if (!token) {
    return res.status(401).json({
      message: "Access token required",
    });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({
        message: "Invalid or expired token",
      });
    }
    req.user = user;
    next();
  });
};

// Get current user profile
router.get("/me", authenticateToken, (req, res) => {
  const user = users.find((u) => u.id === req.user.userId);
  if (!user) {
    return res.status(404).json({
      message: "User not found",
    });
  }

  const { password: _, ...userResponse } = user;
  res.json({
    user: userResponse,
  });
});

// Export the router and middleware
module.exports = router;
module.exports.authenticateToken = authenticateToken;
module.exports.users = users;
