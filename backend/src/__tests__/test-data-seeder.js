const bcrypt = require("bcryptjs");
const models = require("../models");

class TestDataSeeder {
  constructor() {
    this.createdData = {
      users: [],
      donations: [],
      requests: [],
      messages: [],
    };
  }

  async seedTestUsers(count = 3) {
    const users = [];
    const hashedPassword = await bcrypt.hash("testpassword123", 10);

    for (let i = 1; i <= count; i++) {
      const user = await models.User.create({
        name: `Test User ${i}`,
        email: `testuser${i}@example.com`,
        password: hashedPassword,
        role: i === 1 ? "admin" : i === 2 ? "donor" : "receiver",
        phone: `+1234567890${i}`,
        location: `Test City ${i}`,
        isEmailVerified: true,
        isVerified: i <= 2,
        verificationLevel: i === 1 ? "premium" : i === 2 ? "verified" : "basic",
      });
      users.push(user);
      this.createdData.users.push(user.id);
    }

    return users;
  }

  async seedTestDonations(users, count = 2) {
    const donations = [];
    const categories = ["food", "clothes", "books", "electronics"];
    const conditions = ["new", "like-new", "good", "fair"];

    for (let i = 1; i <= count; i++) {
      const donor = users[Math.min(i - 1, users.length - 1)];
      const donation = await models.Donation.create({
        title: `Test Donation ${i}`,
        description: `This is a test donation description for item ${i}. It contains enough text to meet validation requirements.`,
        category: categories[i % categories.length],
        condition: conditions[i % conditions.length],
        location: `Test Location ${i}`,
        donorId: donor.id,
        donorName: donor.name,
        imageUrl: `https://example.com/image${i}.jpg`,
        isAvailable: i <= Math.ceil(count / 2),
        status: i <= Math.ceil(count / 2) ? "available" : "completed",
      });
      donations.push(donation);
      this.createdData.donations.push(donation.id);
    }

    return donations;
  }

  async seedTestRequests(users, donations, count = 2) {
    const requests = [];

    for (let i = 1; i <= count && i <= donations.length; i++) {
      const receiver = users[users.length - 1]; // Use last user as receiver
      const donor = users[0]; // Use first user as donor
      const donation = donations[i - 1];

      const request = await models.Request.create({
        donationId: donation.id,
        donorId: donor.id,
        donorName: donor.name,
        receiverId: receiver.id,
        receiverName: receiver.name,
        receiverEmail: receiver.email,
        receiverPhone: receiver.phone,
        message: `Test request message ${i}`,
        status: i === 1 ? "pending" : "approved",
      });
      requests.push(request);
      this.createdData.requests.push(request.id);
    }

    return requests;
  }

  async seedTestVerificationDocuments(users, requests) {
    const userDocs = [];
    const requestDocs = [];

    // Create user verification documents
    for (let i = 0; i < Math.min(2, users.length); i++) {
      const user = users[i];
      const userDoc = await models.UserVerificationDocument.create({
        userId: user.id,
        documentType: i === 0 ? "id_card" : "passport",
        documentUrl: `https://example.com/user-doc-${i + 1}.pdf`,
        documentName: `user-verification-${i + 1}.pdf`,
        documentSize: 1024 * (i + 1),
        isVerified: i === 0,
        verifiedBy: i === 0 ? users[0].id : null,
        verifiedAt: i === 0 ? new Date() : null,
      });
      userDocs.push(userDoc);
      this.createdData.userVerificationDocuments.push(userDoc.id);
    }

    // Create request verification documents
    for (let i = 0; i < Math.min(2, requests.length); i++) {
      const request = requests[i];
      const requestDoc = await models.RequestVerificationDocument.create({
        requestId: request.id,
        documentType: i === 0 ? "proof_of_need" : "receipt",
        documentUrl: `https://example.com/request-doc-${i + 1}.pdf`,
        documentName: `request-verification-${i + 1}.pdf`,
        documentSize: 2048 * (i + 1),
        isVerified: i === 0,
        verifiedBy: i === 0 ? users[0].id : null,
        verifiedAt: i === 0 ? new Date() : null,
      });
      requestDocs.push(requestDoc);
      this.createdData.requestVerificationDocuments.push(requestDoc.id);
    }

    return { userDocs, requestDocs };
  }

  async seedTestMessages(users, count = 2) {
    const messages = [];

    for (let i = 1; i <= count && users.length >= 2; i++) {
      const sender = users[0];
      const receiver = users[1];

      const message = await models.Message.create({
        senderId: sender.id,
        receiverId: receiver.id,
        content: `Test message ${i} content`,
        isRead: i === 1,
      });
      messages.push(message);
      this.createdData.messages.push(message.id);
    }

    return messages;
  }

  // Notification seeding removed for MVP simplification

  async seedAllTestData() {
    try {
      console.log("🌱 Seeding test data...");

      const users = await this.seedTestUsers(3);
      const donations = await this.seedTestDonations(users, 2);
      const requests = await this.seedTestRequests(users, donations, 2);
      const messages = await this.seedTestMessages(users, 2);

      console.log("✅ Test data seeded successfully");
      return {
        users,
        donations,
        requests,
        userVerificationDocuments: userDocs,
        messages,
      };
    } catch (error) {
      console.error("❌ Failed to seed test data:", error);
      throw error;
    }
  }

  async cleanupTestData() {
    try {
      console.log("🧹 Cleaning up test data...");

      // Clean up in reverse order of dependencies
      const cleanupOrder = [
        "messages",
        "requests",
        "donations",
        "users",
      ];

      for (const tableName of cleanupOrder) {
        if (this.createdData[tableName] && this.createdData[tableName].length > 0) {
          const modelName = tableName.charAt(0).toUpperCase() + tableName.slice(1);
          const model = models[modelName] || models[this.getModelName(tableName)];
          
          if (model) {
            await model.destroy({
              where: {
                id: this.createdData[tableName],
              },
              force: true,
            });
          }
        }
      }

      // Reset created data tracking
      Object.keys(this.createdData).forEach(key => {
        this.createdData[key] = [];
      });

      console.log("✅ Test data cleaned up successfully");
    } catch (error) {
      console.error("❌ Failed to cleanup test data:", error);
      throw error;
    }
  }

  getModelName(tableName) {
    const modelMap = {
      users: "User",
      donations: "Donation",
      requests: "Request",
      messages: "Message",
    };
    return modelMap[tableName];
  }
}

module.exports = TestDataSeeder;