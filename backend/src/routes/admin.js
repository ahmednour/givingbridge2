const express = require("express");
const { authenticateToken } = require("../middleware/auth");
const AdminController = require("../controllers/adminController");
const UserController = require("../controllers/userController");
const RequestController = require("../controllers/requestController");
const {
  generalRateLimit,
} = require("../middleware/rateLimiting");
const router = express.Router();

// Middleware to check admin role
const requireAdmin = (req, res, next) => {
  if (req.user.role !== "admin") {
    return res.status(403).json({
      message: "Access denied. Admin role required.",
    });
  }
  next();
};

// Get admin dashboard statistics
router.get("/stats", authenticateToken, requireAdmin, generalRateLimit, async (req, res) => {
  try {
    const stats = await AdminController.getDashboardStats();
    res.json(stats);
  } catch (error) {
    console.error("Get admin stats error:", error);
    res.status(500).json({
      message: "Failed to fetch admin statistics",
      error: error.message,
    });
  }
});

// Get all users (admin only)
router.get("/users", authenticateToken, requireAdmin, generalRateLimit, async (req, res) => {
  try {
    const { role, search, page, limit } = req.query;
    const result = await AdminController.getAllUsers({
      role,
      search,
      page,
      limit,
    });
    res.json(result);
  } catch (error) {
    console.error("Get all users error:", error);
    res.status(500).json({
      message: "Failed to fetch users",
      error: error.message,
    });
  }
});

// Delete user (admin only)
router.delete("/users/:id", authenticateToken, requireAdmin, generalRateLimit, async (req, res) => {
  try {
    const userId = parseInt(req.params.id);
    await AdminController.deleteUser(userId, req.user);
    res.json({
      message: "User deleted successfully",
    });
  } catch (error) {
    console.error("Delete user error:", error);
    const status = error.statusCode || 500;
    res.status(status).json({
      message: error.message || "Failed to delete user",
    });
  }
});

// Get all requests (admin only)
router.get("/requests", authenticateToken, requireAdmin, generalRateLimit, async (req, res) => {
  try {
    const { status, page, limit } = req.query;
    const result = await AdminController.getAllRequests({
      status,
      page,
      limit,
    });
    res.json(result);
  } catch (error) {
    console.error("Get all requests error:", error);
    res.status(500).json({
      message: "Failed to fetch requests",
      error: error.message,
    });
  }
});

// Update request status (admin only)
router.put("/requests/:id/status", authenticateToken, requireAdmin, generalRateLimit, async (req, res) => {
  try {
    const requestId = parseInt(req.params.id);
    const { status } = req.body;
    
    const updatedRequest = await AdminController.updateRequestStatus(
      requestId,
      status,
      req.user
    );
    
    res.json({
      message: "Request status updated successfully",
      request: updatedRequest,
    });
  } catch (error) {
    console.error("Update request status error:", error);
    const status = error.statusCode || 500;
    res.status(status).json({
      message: error.message || "Failed to update request status",
    });
  }
});

module.exports = router;