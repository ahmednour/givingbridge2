const express = require("express");
const { body, validationResult } = require("express-validator");
const router = express.Router();
const RatingController = require("../controllers/ratingController");
const { authenticateToken } = require("./auth");
const { asyncHandler } = require("../middleware");

// Create a new rating
router.post(
  "/",
  [
    authenticateToken,
    body("requestId").isInt().withMessage("Request ID must be an integer"),
    body("rating")
      .isInt({ min: 1, max: 5 })
      .withMessage("Rating must be between 1 and 5"),
    body("feedback")
      .optional()
      .isLength({ max: 1000 })
      .withMessage("Feedback must not exceed 1000 characters"),
  ],
  asyncHandler(async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: "Validation failed",
        errors: errors.array(),
      });
    }

    const rating = await RatingController.createRating(
      req.body,
      req.user.userId
    );

    res.status(201).json({
      success: true,
      message: "Rating created successfully",
      rating,
    });
  })
);

// Get rating by request ID
router.get(
  "/request/:requestId",
  asyncHandler(async (req, res) => {
    const rating = await RatingController.getRatingByRequest(
      req.params.requestId
    );

    if (!rating) {
      return res.status(404).json({
        success: false,
        message: "Rating not found",
      });
    }

    res.json({
      success: true,
      rating,
    });
  })
);

// Get ratings for a donor
router.get(
  "/donor/:donorId",
  asyncHandler(async (req, res) => {
    const ratings = await RatingController.getDonorRatings(req.params.donorId);
    const avgRating = await RatingController.getDonorAverageRating(
      req.params.donorId
    );

    res.json({
      success: true,
      ratings,
      average: avgRating.average,
      count: avgRating.count,
    });
  })
);

// Get ratings for a receiver
router.get(
  "/receiver/:receiverId",
  asyncHandler(async (req, res) => {
    const ratings = await RatingController.getReceiverRatings(
      req.params.receiverId
    );
    const avgRating = await RatingController.getReceiverAverageRating(
      req.params.receiverId
    );

    res.json({
      success: true,
      ratings,
      average: avgRating.average,
      count: avgRating.count,
    });
  })
);

// Update a rating
router.put(
  "/request/:requestId",
  [
    authenticateToken,
    body("rating")
      .isInt({ min: 1, max: 5 })
      .withMessage("Rating must be between 1 and 5"),
    body("feedback")
      .optional()
      .isLength({ max: 1000 })
      .withMessage("Feedback must not exceed 1000 characters"),
  ],
  asyncHandler(async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: "Validation failed",
        errors: errors.array(),
      });
    }

    const rating = await RatingController.updateRating(
      req.params.requestId,
      req.user.userId,
      req.body
    );

    res.json({
      success: true,
      message: "Rating updated successfully",
      rating,
    });
  })
);

// Delete a rating
router.delete(
  "/request/:requestId",
  authenticateToken,
  asyncHandler(async (req, res) => {
    await RatingController.deleteRating(req.params.requestId, req.user.userId);

    res.json({
      success: true,
      message: "Rating deleted successfully",
    });
  })
);

module.exports = router;
