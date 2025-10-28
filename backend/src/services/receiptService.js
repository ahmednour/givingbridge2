const PDFDocument = require("pdfkit");
const fs = require("fs").promises;
const path = require("path");

/**
 * Receipt Service
 * Handles generation of donation receipts for tax purposes
 */
class ReceiptService {
  constructor() {
    // Ensure receipts directory exists
    this.receiptsDir = path.join(__dirname, "../../receipts");
    this.ensureDirectoryExists();
  }

  /**
   * Ensure receipts directory exists
   */
  async ensureDirectoryExists() {
    try {
      await fs.access(this.receiptsDir);
    } catch (error) {
      // Directory doesn't exist, create it
      await fs.mkdir(this.receiptsDir, { recursive: true });
    }
  }

  /**
   * Generate donation receipt PDF
   * @param {Object} donation - Donation object
   * @param {Object} request - Request object (if applicable)
   * @param {Object} donor - Donor user object
   * @param {Object} receiver - Receiver user object (if applicable)
   * @returns {Promise<string>} Path to generated receipt PDF
   */
  async generateDonationReceipt(donation, request, donor, receiver) {
    const receiptId = `receipt-${donation.id}-${Date.now()}`;
    const filename = `${receiptId}.pdf`;
    const filePath = path.join(this.receiptsDir, filename);

    // Create a document
    const doc = new PDFDocument({
      size: "A4",
      margin: 50,
    });

    // Pipe its output somewhere, like to a file or HTTP response
    const stream = doc.pipe(fs.createWriteStream(filePath));

    // Add the header
    doc.fontSize(20).text("DONATION RECEIPT", { align: "center" });

    doc.moveDown();
    doc
      .fontSize(12)
      .text("GivingBridge - Community Donation Platform", { align: "center" });

    doc.moveDown(2);

    // Add receipt details
    doc
      .fontSize(10)
      .text(`Receipt ID: ${receiptId}`, { align: "right" })
      .text(`Date: ${new Date().toLocaleDateString()}`, { align: "right" });

    doc.moveDown(2);

    // Donor information
    doc
      .fontSize(14)
      .text("Donor Information:")
      .fontSize(10)
      .text(`Name: ${donor.name}`)
      .text(`Email: ${donor.email}`)
      .text(`Address: ${donor.location || "Not provided"}`);

    doc.moveDown();

    // Receiver information (if applicable)
    if (receiver) {
      doc
        .fontSize(14)
        .text("Recipient Information:")
        .fontSize(10)
        .text(`Name: ${receiver.name}`)
        .text(`Email: ${receiver.email}`)
        .text(`Address: ${receiver.location || "Not provided"}`);

      doc.moveDown();
    }

    // Donation details
    doc
      .fontSize(14)
      .text("Donation Details:")
      .fontSize(10)
      .text(`Title: ${donation.title}`)
      .text(`Description: ${donation.description}`)
      .text(`Category: ${donation.category}`)
      .text(`Condition: ${donation.condition}`)
      .text(`Location: ${donation.location}`)
      .text(`Date: ${new Date(donation.createdAt).toLocaleDateString()}`)
      .text(`Status: ${donation.status}`);

    doc.moveDown();

    // Request details (if applicable)
    if (request) {
      doc
        .fontSize(14)
        .text("Request Details:")
        .fontSize(10)
        .text(`Message: ${request.message || "No message"}`)
        .text(
          `Request Date: ${new Date(request.createdAt).toLocaleDateString()}`
        )
        .text(`Request Status: ${request.status}`);

      doc.moveDown();
    }

    // Tax information
    doc
      .fontSize(14)
      .text("Tax Information:")
      .fontSize(10)
      .text("This receipt can be used for tax deduction purposes.")
      .text(
        "The fair market value of donated items is determined by the donor."
      )
      .text("GivingBridge is a registered non-profit organization.")
      .text("Federal Tax ID: XX-XXXXXXX");

    doc.moveDown(2);

    // Signature section
    doc
      .fontSize(12)
      .text("Signature:", { continued: true })
      .text(" ____________________________", { continued: true })
      .text("        Date: ____________", {});

    doc.moveDown(3);

    // Footer
    doc
      .fontSize(8)
      .text("Thank you for your generous donation!", { align: "center" })
      .text(
        "For questions about this receipt, contact support@givingbridge.org",
        { align: "center" }
      );

    // Finalize PDF file
    doc.end();

    // Wait for the file to be written
    await new Promise((resolve, reject) => {
      stream.on("finish", resolve);
      stream.on("error", reject);
    });

    return {
      path: filePath,
      url: `/receipts/${filename}`,
      id: receiptId,
    };
  }

  /**
   * Generate transaction history report
   * @param {Array} transactions - Array of transactions (donations/requests)
   * @param {Object} user - User object
   * @param {string} format - Export format (pdf, csv)
   * @returns {Promise<Object>} Generated report information
   */
  async generateTransactionHistory(transactions, user, format = "pdf") {
    const reportId = `history-${user.id}-${Date.now()}`;

    if (format === "pdf") {
      return await this.generateTransactionHistoryPDF(
        transactions,
        user,
        reportId
      );
    } else if (format === "csv") {
      return await this.generateTransactionHistoryCSV(
        transactions,
        user,
        reportId
      );
    } else {
      throw new Error("Unsupported export format");
    }
  }

  /**
   * Generate transaction history PDF report
   * @param {Array} transactions - Array of transactions
   * @param {Object} user - User object
   * @param {string} reportId - Report ID
   * @returns {Promise<Object>} Generated PDF report information
   */
  async generateTransactionHistoryPDF(transactions, user, reportId) {
    const filename = `${reportId}.pdf`;
    const filePath = path.join(this.receiptsDir, filename);

    // Create a document
    const doc = new PDFDocument({
      size: "A4",
      margin: 50,
    });

    // Pipe its output somewhere, like to a file or HTTP response
    const stream = doc.pipe(fs.createWriteStream(filePath));

    // Add the header
    doc.fontSize(20).text("TRANSACTION HISTORY REPORT", { align: "center" });

    doc.moveDown();
    doc
      .fontSize(12)
      .text("GivingBridge - Community Donation Platform", { align: "center" });

    doc.moveDown(2);

    // Add report details
    doc
      .fontSize(10)
      .text(`Report ID: ${reportId}`, { align: "right" })
      .text(`Generated: ${new Date().toLocaleDateString()}`, { align: "right" })
      .text(`User: ${user.name} (${user.email})`, { align: "right" });

    doc.moveDown(2);

    // Summary
    const totalDonations = transactions.filter(
      (t) => t.type === "donation"
    ).length;
    const totalRequests = transactions.filter(
      (t) => t.type === "request"
    ).length;
    const completedTransactions = transactions.filter(
      (t) =>
        (t.type === "donation" && t.status === "completed") ||
        (t.type === "request" && t.status === "completed")
    ).length;

    doc
      .fontSize(14)
      .text("Summary:")
      .fontSize(10)
      .text(`Total Transactions: ${transactions.length}`)
      .text(`Donations: ${totalDonations}`)
      .text(`Requests: ${totalRequests}`)
      .text(`Completed: ${completedTransactions}`);

    doc.moveDown(2);

    // Transaction details
    doc.fontSize(14).text("Transaction Details:");

    doc.moveDown();

    // Table headers
    const startX = doc.x;
    const startY = doc.y;

    doc
      .fontSize(10)
      .text("Date", startX, startY)
      .text("Type", startX + 100, startY)
      .text("Title/Item", startX + 180, startY)
      .text("Status", startX + 350, startY)
      .text("Value", startX + 420, startY);

    doc.moveDown();

    // Draw line under headers
    doc
      .moveTo(startX, doc.y - 5)
      .lineTo(startX + 500, doc.y - 5)
      .stroke();

    doc.moveDown(0.5);

    // Transaction rows
    transactions.forEach((transaction) => {
      const date = new Date(transaction.createdAt).toLocaleDateString();
      const type =
        transaction.type.charAt(0).toUpperCase() + transaction.type.slice(1);
      const title = transaction.title || transaction.donation?.title || "N/A";
      const status = transaction.status;
      // Note: In a real implementation, you might have a way to estimate value
      const value = "$0.00"; // Placeholder - in reality this would be calculated

      doc
        .fontSize(9)
        .text(date, startX, doc.y)
        .text(type, startX + 100, doc.y)
        .text(title, startX + 180, doc.y)
        .text(status, startX + 350, doc.y)
        .text(value, startX + 420, doc.y);

      doc.moveDown();
    });

    doc.moveDown(2);

    // Footer
    doc
      .fontSize(8)
      .text("This report includes all transactions for the selected period.", {
        align: "center",
      })
      .text(
        "For questions about this report, contact support@givingbridge.org",
        { align: "center" }
      );

    // Finalize PDF file
    doc.end();

    // Wait for the file to be written
    await new Promise((resolve, reject) => {
      stream.on("finish", resolve);
      stream.on("error", reject);
    });

    return {
      path: filePath,
      url: `/receipts/${filename}`,
      id: reportId,
    };
  }

  /**
   * Generate transaction history CSV report
   * @param {Array} transactions - Array of transactions
   * @param {Object} user - User object
   * @param {string} reportId - Report ID
   * @returns {Promise<Object>} Generated CSV report information
   */
  async generateTransactionHistoryCSV(transactions, user, reportId) {
    const filename = `${reportId}.csv`;
    const filePath = path.join(this.receiptsDir, filename);

    // Create CSV content
    let csvContent = "Date,Type,Title/Item,Status,Value\n";

    transactions.forEach((transaction) => {
      const date = new Date(transaction.createdAt).toLocaleDateString();
      const type = transaction.type;
      const title = transaction.title || transaction.donation?.title || "N/A";
      const status = transaction.status;
      // Note: In a real implementation, you might have a way to estimate value
      const value = "$0.00"; // Placeholder - in reality this would be calculated

      // Escape commas and quotes in values
      const escapeValue = (value) => {
        if (
          typeof value === "string" &&
          (value.includes(",") || value.includes('"'))
        ) {
          return `"${value.replace(/"/g, '""')}"`;
        }
        return value;
      };

      csvContent += `${escapeValue(date)},${escapeValue(type)},${escapeValue(
        title
      )},${escapeValue(status)},${escapeValue(value)}\n`;
    });

    // Write CSV file
    await fs.writeFile(filePath, csvContent);

    return {
      path: filePath,
      url: `/receipts/${filename}`,
      id: reportId,
    };
  }

  /**
   * Get receipt by ID
   * @param {string} receiptId - Receipt ID
   * @returns {Promise<Buffer>} Receipt file buffer
   */
  async getReceipt(receiptId) {
    const filename = `${receiptId}.pdf`;
    const filePath = path.join(this.receiptsDir, filename);

    try {
      await fs.access(filePath);
      return await fs.readFile(filePath);
    } catch (error) {
      throw new Error("Receipt not found");
    }
  }
}

// Export singleton instance
module.exports = new ReceiptService();
