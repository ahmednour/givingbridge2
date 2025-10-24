const express = require("express");
const router = express.Router();
const { authenticateToken } = require("./auth");
const ActivityController = require("../controllers/activityController");

// Get activity logs with filtering and pagination
// Users see their own logs, admins see all
router.get("/", authenticateToken, ActivityController.getLogs);

// Get activity statistics (admin only)
router.get("/statistics", authenticateToken, ActivityController.getStatistics);

// Get single activity log by ID
router.get("/:id", authenticateToken, ActivityController.getLogById);

// Export activity logs as CSV
router.get("/export/csv", authenticateToken, ActivityController.exportLogs);

module.exports = router;
