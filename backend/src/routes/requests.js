const express = require("express");
const { body, validationResult } = require("express-validator");
const { Op } = require("sequelize");
const router = express.Router();
const Request = require("../models/Request");
const Donation = require("../models/Donation");
const User = require("../models/User");
const { sequelize } = require("../config/db");

// Import authentication middleware from auth routes
const { authenticateToken } = require("./auth");

// Get all requests with optional filters
router.get("/", authenticateToken, async (req, res) => {
  try {
    const { donationId, status } = req.query;
    const user = await User.findByPk(req.user.userId);

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    const where = {};
    if (donationId) where.donationId = donationId;
    if (status) where.status = status;

    // Filter based on user role
    if (user.role === "donor") {
      where.donorId = user.id;
    } else if (user.role === "receiver") {
      where.receiverId = user.id;
    }
    // Admin can see all requests (no additional filter)

    const requestsData = await Request.findAll({
      where,
      order: [["createdAt", "DESC"]],
    });

    res.json({
      message: "Requests retrieved successfully",
      requests: requestsData,
      total: requestsData.length,
    });
  } catch (error) {
    console.error("Get requests error:", error);
    res.status(500).json({
      message: "Failed to retrieve requests",
      error: error.message,
    });
  }
});

// Get request by ID
router.get("/:id", authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const request = await Request.findByPk(id);

    if (!request) {
      return res.status(404).json({
        message: "Request not found",
      });
    }

    // Check access permissions
    const user = await User.findByPk(req.user.userId);

    if (
      user.role !== "admin" &&
      request.donorId !== req.user.userId &&
      request.receiverId !== req.user.userId
    ) {
      return res.status(403).json({
        message: "Access denied",
      });
    }

    res.json({
      message: "Request retrieved successfully",
      request,
    });
  } catch (error) {
    console.error("Get request error:", error);
    res.status(500).json({
      message: "Failed to retrieve request",
      error: error.message,
    });
  }
});

// Get my requests as receiver
router.get("/receiver/my-requests", authenticateToken, async (req, res) => {
  try {
    const requests = await Request.findAll({
      where: { receiverId: req.user.userId },
      order: [["createdAt", "DESC"]],
    });

    res.json({
      message: "Your requests retrieved successfully",
      requests,
      total: requests.length,
    });
  } catch (error) {
    console.error("Get my requests error:", error);
    res.status(500).json({
      message: "Failed to retrieve your requests",
      error: error.message,
    });
  }
});

// Get requests for my donations (as donor)
router.get("/donor/incoming-requests", authenticateToken, async (req, res) => {
  try {
    const requests = await Request.findAll({
      where: { donorId: req.user.userId },
      order: [["createdAt", "DESC"]],
    });

    res.json({
      message: "Incoming requests retrieved successfully",
      requests,
      total: requests.length,
    });
  } catch (error) {
    console.error("Get incoming requests error:", error);
    res.status(500).json({
      message: "Failed to retrieve incoming requests",
      error: error.message,
    });
  }
});

// Create new request (receiver requests a donation)
router.post(
  "/",
  [
    authenticateToken,
    body("donationId")
      .isInt({ min: 1 })
      .withMessage("Valid donation ID is required"),
    body("message")
      .optional()
      .trim()
      .isLength({ max: 500 })
      .withMessage("Message must be less than 500 characters"),
  ],
  async (req, res) => {
    const transaction = await sequelize.transaction();

    try {
      // Check for validation errors
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        await transaction.rollback();
        return res.status(400).json({
          message: "Validation failed",
          errors: errors.array(),
        });
      }

      const { donationId, message } = req.body;
      const receiver = await User.findByPk(req.user.userId, { transaction });

      if (!receiver) {
        await transaction.rollback();
        return res.status(404).json({
          message: "User not found",
        });
      }

      // Only receivers can make requests
      if (receiver.role !== "receiver") {
        await transaction.rollback();
        return res.status(403).json({
          message: "Only receivers can request donations",
        });
      }

      // Check if donation exists and is available
      const donation = await Donation.findByPk(donationId, { transaction });
      if (!donation) {
        await transaction.rollback();
        return res.status(404).json({
          message: "Donation not found",
        });
      }

      if (!donation.isAvailable) {
        await transaction.rollback();
        return res.status(400).json({
          message: "This donation is no longer available",
        });
      }

      // Prevent requesting own donations (if user has both roles)
      if (donation.donorId === receiver.id) {
        await transaction.rollback();
        return res.status(400).json({
          message: "You cannot request your own donation",
        });
      }

      // Check if user has already requested this donation
      const existingRequest = await Request.findOne({
        where: {
          receiverId: receiver.id,
          donationId: parseInt(donationId),
          status: {
            [Op.notIn]: ["cancelled", "declined"],
          },
        },
        transaction,
      });

      if (existingRequest) {
        await transaction.rollback();
        return res.status(400).json({
          message: "You have already requested this donation",
        });
      }

      // Get donor information
      const donor = await User.findByPk(donation.donorId, { transaction });
      if (!donor) {
        await transaction.rollback();
        return res.status(404).json({
          message: "Donor not found",
        });
      }

      const request = await Request.create(
        {
          donationId: parseInt(donationId),
          donorId: donor.id,
          donorName: donor.name,
          receiverId: receiver.id,
          receiverName: receiver.name,
          receiverEmail: receiver.email,
          receiverPhone: receiver.phone || null,
          message: message || null,
          status: "pending",
        },
        { transaction }
      );

      await transaction.commit();

      res.status(201).json({
        message: "Request sent successfully",
        request,
      });
    } catch (error) {
      await transaction.rollback();
      console.error("Create request error:", error);
      res.status(500).json({
        message: "Failed to create request",
        error: error.message,
      });
    }
  }
);

// Update request status (approve/decline by donor)
router.put(
  "/:id/status",
  [
    authenticateToken,
    body("status")
      .isIn(["approved", "declined", "completed", "cancelled"])
      .withMessage("Invalid status"),
    body("responseMessage")
      .optional()
      .trim()
      .isLength({ max: 500 })
      .withMessage("Response message must be less than 500 characters"),
  ],
  async (req, res) => {
    const transaction = await sequelize.transaction();

    try {
      // Check for validation errors
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        await transaction.rollback();
        return res.status(400).json({
          message: "Validation failed",
          errors: errors.array(),
        });
      }

      const { id } = req.params;
      const { status, responseMessage } = req.body;
      const request = await Request.findByPk(id, { transaction });

      if (!request) {
        await transaction.rollback();
        return res.status(404).json({
          message: "Request not found",
        });
      }

      const user = await User.findByPk(req.user.userId, { transaction });

      // Check permissions
      if (user.role === "admin") {
        // Admin can update any request
      } else if (status === "approved" || status === "declined") {
        // Only donor can approve/decline
        if (request.donorId !== req.user.userId) {
          await transaction.rollback();
          return res.status(403).json({
            message: "Only the donor can approve or decline this request",
          });
        }
      } else if (status === "completed") {
        // Both donor and receiver can mark as completed
        if (
          request.donorId !== req.user.userId &&
          request.receiverId !== req.user.userId
        ) {
          await transaction.rollback();
          return res.status(403).json({
            message: "Access denied",
          });
        }
      } else if (status === "cancelled") {
        // Only receiver can cancel their own request
        if (request.receiverId !== req.user.userId) {
          await transaction.rollback();
          return res.status(403).json({
            message: "Only the receiver can cancel this request",
          });
        }
      }

      // Validate status transitions
      if (request.status === "completed" || request.status === "cancelled") {
        await transaction.rollback();
        return res.status(400).json({
          message: "Cannot update a completed or cancelled request",
        });
      }

      if (request.status === "declined" && status !== "cancelled") {
        await transaction.rollback();
        return res.status(400).json({
          message: "Cannot update a declined request",
        });
      }

      // Update request
      await request.update(
        {
          status,
          responseMessage: responseMessage || null,
          respondedAt: new Date(),
        },
        { transaction }
      );

      // Update donation availability
      const donation = await Donation.findByPk(request.donationId, {
        transaction,
      });
      if (donation) {
        if (status === "approved") {
          await donation.update(
            { isAvailable: false, status: "pending" },
            { transaction }
          );
        } else if (status === "declined" || status === "cancelled") {
          await donation.update(
            { isAvailable: true, status: "available" },
            { transaction }
          );
        } else if (status === "completed") {
          await donation.update({ status: "completed" }, { transaction });
        }
      }

      await transaction.commit();

      res.json({
        message: "Request status updated successfully",
        request,
      });
    } catch (error) {
      await transaction.rollback();
      console.error("Update request status error:", error);
      res.status(500).json({
        message: "Failed to update request status",
        error: error.message,
      });
    }
  }
);

// Delete request (only by receiver or admin)
router.delete("/:id", authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const request = await Request.findByPk(id);

    if (!request) {
      return res.status(404).json({
        message: "Request not found",
      });
    }

    // Check permissions
    const user = await User.findByPk(req.user.userId);

    if (user.role !== "admin" && request.receiverId !== req.user.userId) {
      return res.status(403).json({
        message: "Access denied",
      });
    }

    // Cannot delete approved or completed requests
    if (request.status === "approved" || request.status === "completed") {
      return res.status(400).json({
        message: "Cannot delete approved or completed requests",
      });
    }

    await request.destroy();

    res.json({
      message: "Request deleted successfully",
    });
  } catch (error) {
    console.error("Delete request error:", error);
    res.status(500).json({
      message: "Failed to delete request",
      error: error.message,
    });
  }
});

// Get request statistics (for admin dashboard)
router.get("/admin/stats", authenticateToken, async (req, res) => {
  try {
    // Check if user is admin
    const user = await User.findByPk(req.user.userId);

    if (user.role !== "admin") {
      return res.status(403).json({
        message: "Admin access required",
      });
    }

    const total = await Request.count();
    const pending = await Request.count({ where: { status: "pending" } });
    const approved = await Request.count({ where: { status: "approved" } });
    const declined = await Request.count({ where: { status: "declined" } });
    const completed = await Request.count({ where: { status: "completed" } });
    const cancelled = await Request.count({ where: { status: "cancelled" } });

    const stats = {
      total,
      pending,
      approved,
      declined,
      completed,
      cancelled,
    };

    res.json({
      message: "Request statistics retrieved successfully",
      stats,
    });
  } catch (error) {
    console.error("Get request stats error:", error);
    res.status(500).json({
      message: "Failed to retrieve request statistics",
      error: error.message,
    });
  }
});

module.exports = router;
