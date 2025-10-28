const express = require("express");
const router = express.Router();
const DonationHistoryController = require("../controllers/donationHistoryController");
const { authenticateToken } = require("../middleware/auth");
const { asyncHandler } = require("../middleware");

// All routes require authentication
router.use(authenticateToken);

// Get user's donation history
router.get(
  "/",
  asyncHandler(async (req, res) => {
    const { status, category, startDate, endDate, search, page, limit } =
      req.query;
    const userId = req.user.id;
    const userType = req.user.role === "donor" ? "donor" : "receiver";

    const filters = {};
    if (status) filters.status = status;
    if (category) filters.category = category;
    if (startDate) filters.startDate = startDate;
    if (endDate) filters.endDate = endDate;
    if (search) filters.search = search;

    const pagination = {
      page: page || 1,
      limit: limit || 20,
    };

    const history = await DonationHistoryController.getDonationHistory(
      userId,
      userType,
      filters,
      pagination
    );

    res.json({
      success: true,
      message: "Donation history retrieved successfully",
      data: history,
    });
  })
);

// Get combined transaction history
router.get(
  "/transactions",
  asyncHandler(async (req, res) => {
    const { status, category, startDate, endDate, search, page, limit } =
      req.query;
    const userId = req.user.id;

    const filters = {};
    if (status) filters.status = status;
    if (category) filters.category = category;
    if (startDate) filters.startDate = startDate;
    if (endDate) filters.endDate = endDate;
    if (search) filters.search = search;

    const pagination = {
      page: page || 1,
      limit: limit || 20,
    };

    const history =
      await DonationHistoryController.getCombinedTransactionHistory(
        userId,
        filters,
        pagination
      );

    res.json({
      success: true,
      message: "Transaction history retrieved successfully",
      data: history,
    });
  })
);

// Generate donation receipt
router.post(
  "/receipts/:donationId",
  asyncHandler(async (req, res) => {
    const { donationId } = req.params;
    const userId = req.user.id;
    const userType = req.user.role;

    const receiptInfo = await DonationHistoryController.generateDonationReceipt(
      donationId,
      userId,
      userType
    );

    res.json({
      success: true,
      message: "Donation receipt generated successfully",
      data: receiptInfo,
    });
  })
);

// Generate transaction history report
router.post(
  "/reports",
  asyncHandler(async (req, res) => {
    const { format, filters } = req.body;
    const userId = req.user.id;

    const reportInfo =
      await DonationHistoryController.generateTransactionHistoryReport(
        userId,
        format || "pdf",
        filters || {}
      );

    res.json({
      success: true,
      message: "Transaction history report generated successfully",
      data: reportInfo,
    });
  })
);

// Get receipt file
router.get(
  "/receipts/file/:receiptId",
  asyncHandler(async (req, res) => {
    const { receiptId } = req.params;

    try {
      const receiptBuffer = await DonationHistoryController.getReceipt(
        receiptId
      );

      res.setHeader("Content-Type", "application/pdf");
      res.setHeader(
        "Content-Disposition",
        `attachment; filename="${receiptId}.pdf"`
      );
      res.send(receiptBuffer);
    } catch (error) {
      res.status(404).json({
        success: false,
        message: "Receipt not found",
      });
    }
  })
);

module.exports = router;
