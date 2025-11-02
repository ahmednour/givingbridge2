const express = require("express");
const { authenticateToken } = require("../middleware/auth");
const AdminController = require("../controllers/adminController");
const UserController = require("../controllers/userController");
const RequestController = require("../controllers/requestController");
const {
  generalRateLimit,
} = require("../middleware/rateLimiting");
const { asyncHandler } = require("../middleware");
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
router.get("/stats", authenticateToken, requireAdmin, generalRateLimit, asyncHandler(async (req, res) => {
  const stats = await AdminController.getDashboardStats();
  res.json(stats);
}));

// Get all users (admin only)
router.get("/users", authenticateToken, requireAdmin, generalRateLimit, asyncHandler(async (req, res) => {
  const { role, search, page, limit } = req.query;
  const result = await AdminController.getAllUsers({
    role,
    search,
    page,
    limit,
  });
  res.json(result);
}));

// Delete user (admin only)
router.delete("/users/:id", authenticateToken, requireAdmin, generalRateLimit, asyncHandler(async (req, res) => {
  const userId = parseInt(req.params.id);
  await AdminController.deleteUser(userId, req.user);
  res.json({
    message: "User deleted successfully",
  });
}));

// Get all requests (admin only)
router.get("/requests", authenticateToken, requireAdmin, generalRateLimit, asyncHandler(async (req, res) => {
  const { status, page, limit } = req.query;
  const result = await AdminController.getAllRequests({
    status,
    page,
    limit,
  });
  res.json(result);
}));

// Update request status (admin only)
router.put("/requests/:id/status", authenticateToken, requireAdmin, generalRateLimit, asyncHandler(async (req, res) => {
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
}));

// Get all donations (admin only) - includes pending, approved, and rejected
router.get("/donations", authenticateToken, requireAdmin, generalRateLimit, asyncHandler(async (req, res) => {
  const { approvalStatus, page, limit } = req.query;
  const DonationController = require("../controllers/donationController");
  
  const result = await DonationController.getAllDonations(
    { approvalStatus },
    { page, limit },
    "admin" // Pass admin role to see all donations
  );
  
  res.json(result);
}));

// Get pending donations count (for admin dashboard badge)
router.get("/donations/pending/count", authenticateToken, requireAdmin, generalRateLimit, asyncHandler(async (req, res) => {
  const Donation = require("../models/Donation");
  
  const count = await Donation.count({
    where: { approvalStatus: "pending" },
  });
  
  res.json({
    count,
    message: "Pending donations count retrieved successfully",
  });
}));

module.exports = router;