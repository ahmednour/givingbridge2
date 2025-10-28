const express = require("express");
const router = express.Router();
const CommentController = require("../controllers/commentController");
const { authenticateToken } = require("../middleware/auth");
const { asyncHandler } = require("../middleware");

// All routes require authentication
router.use(authenticateToken);

// Create a new comment
router.post(
  "/:donationId/comments",
  asyncHandler(async (req, res) => {
    const { donationId } = req.params;
    const { content, parentId } = req.body;
    const userId = req.user.id;

    const commentData = {
      content,
      parentId,
    };

    const comment = await CommentController.createComment(
      commentData,
      donationId,
      userId
    );

    res.status(201).json({
      success: true,
      message: "Comment created successfully",
      data: comment,
    });
  })
);

// Get comments for a specific donation
router.get(
  "/:donationId/comments",
  asyncHandler(async (req, res) => {
    const { donationId } = req.params;
    const { page, limit } = req.query;

    const pagination = {
      page: page || 1,
      limit: limit || 20,
    };

    const comments = await CommentController.getComments(
      donationId,
      pagination
    );

    res.json({
      success: true,
      message: "Comments retrieved successfully",
      data: comments,
    });
  })
);

// Get a specific comment by ID
router.get(
  "/comments/:commentId",
  asyncHandler(async (req, res) => {
    const { commentId } = req.params;

    const comment = await CommentController.getCommentById(commentId);

    res.json({
      success: true,
      message: "Comment retrieved successfully",
      data: comment,
    });
  })
);

// Update a comment
router.put(
  "/comments/:commentId",
  asyncHandler(async (req, res) => {
    const { commentId } = req.params;
    const { content } = req.body;
    const userId = req.user.id;
    const userRole = req.user.role;

    const updateData = { content };

    const comment = await CommentController.updateComment(
      commentId,
      updateData,
      userId,
      userRole
    );

    res.json({
      success: true,
      message: "Comment updated successfully",
      data: comment,
    });
  })
);

// Delete a comment
router.delete(
  "/comments/:commentId",
  asyncHandler(async (req, res) => {
    const { commentId } = req.params;
    const userId = req.user.id;
    const userRole = req.user.role;

    await CommentController.deleteComment(commentId, userId, userRole);

    res.json({
      success: true,
      message: "Comment deleted successfully",
    });
  })
);

// Get all comments for the current user
router.get(
  "/my-comments",
  asyncHandler(async (req, res) => {
    const { page, limit } = req.query;
    const userId = req.user.id;

    const pagination = {
      page: page || 1,
      limit: limit || 20,
    };

    const comments = await CommentController.getUserComments(
      userId,
      pagination
    );

    res.json({
      success: true,
      message: "User comments retrieved successfully",
      data: comments,
    });
  })
);

module.exports = router;
