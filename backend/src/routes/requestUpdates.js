const express = require("express");
const router = express.Router();
const RequestUpdateController = require("../controllers/requestUpdateController");
const { authenticateToken } = require("../middleware/auth");
const { asyncHandler } = require("../middleware");

// All routes require authentication
router.use(authenticateToken);

// Create a new request update
router.post(
  "/:requestId/updates",
  asyncHandler(async (req, res) => {
    const { requestId } = req.params;
    const { title, description, imageUrl, isPublic } = req.body;
    const userId = req.user.id;
    const userRole = req.user.role;

    const updateData = {
      title,
      description,
      imageUrl,
      isPublic,
    };

    const requestUpdate = await RequestUpdateController.createRequestUpdate(
      updateData,
      requestId,
      userId,
      userRole
    );

    res.status(201).json({
      success: true,
      message: "Request update created successfully",
      data: requestUpdate,
    });
  })
);

// Get request updates for a specific request
router.get(
  "/:requestId/updates",
  asyncHandler(async (req, res) => {
    const { requestId } = req.params;
    const { page, limit } = req.query;
    const user = req.user;

    const pagination = {
      page: page || 1,
      limit: limit || 20,
    };

    const updates = await RequestUpdateController.getRequestUpdates(
      requestId,
      user,
      pagination
    );

    res.json({
      success: true,
      message: "Request updates retrieved successfully",
      data: updates,
    });
  })
);

// Get a specific request update by ID
router.get(
  "/updates/:updateId",
  asyncHandler(async (req, res) => {
    const { updateId } = req.params;
    const user = req.user;

    const requestUpdate = await RequestUpdateController.getRequestUpdateById(
      updateId,
      user
    );

    res.json({
      success: true,
      message: "Request update retrieved successfully",
      data: requestUpdate,
    });
  })
);

// Update a request update
router.put(
  "/updates/:updateId",
  asyncHandler(async (req, res) => {
    const { updateId } = req.params;
    const { title, description, imageUrl, isPublic } = req.body;
    const userId = req.user.id;
    const userRole = req.user.role;

    const updateData = {};
    if (title !== undefined) updateData.title = title;
    if (description !== undefined) updateData.description = description;
    if (imageUrl !== undefined) updateData.imageUrl = imageUrl;
    if (isPublic !== undefined) updateData.isPublic = isPublic;

    const requestUpdate = await RequestUpdateController.updateRequestUpdate(
      updateId,
      updateData,
      userId,
      userRole
    );

    res.json({
      success: true,
      message: "Request update updated successfully",
      data: requestUpdate,
    });
  })
);

// Delete a request update
router.delete(
  "/updates/:updateId",
  asyncHandler(async (req, res) => {
    const { updateId } = req.params;
    const userId = req.user.id;
    const userRole = req.user.role;

    await RequestUpdateController.deleteRequestUpdate(
      updateId,
      userId,
      userRole
    );

    res.json({
      success: true,
      message: "Request update deleted successfully",
    });
  })
);

// Get all updates for the current user (as receiver or donor)
router.get(
  "/my-updates",
  asyncHandler(async (req, res) => {
    const { page, limit } = req.query;
    const userId = req.user.id;
    const userType = req.user.role === "receiver" ? "receiver" : "donor";

    const pagination = {
      page: page || 1,
      limit: limit || 20,
    };

    const updates = await RequestUpdateController.getUserUpdates(
      userId,
      userType,
      pagination
    );

    res.json({
      success: true,
      message: "User updates retrieved successfully",
      data: updates,
    });
  })
);

module.exports = router;
