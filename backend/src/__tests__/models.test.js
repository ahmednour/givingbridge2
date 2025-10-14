const bcrypt = require("bcryptjs");
const User = require("../models/User");
const Donation = require("../models/Donation");
const Request = require("../models/Request");
const Message = require("../models/Message");
const { sequelize } = require("../config/db");

describe("Model Tests", () => {
  beforeEach(async () => {
    // Clear all tables
    await Message.destroy({ where: {}, force: true });
    await Request.destroy({ where: {}, force: true });
    await Donation.destroy({ where: {}, force: true });
    await User.destroy({ where: {}, force: true });
  });

  describe("User Model", () => {
    it("should create a user with valid data", async () => {
      const userData = {
        name: "Test User",
        email: "test@example.com",
        password: "password123",
        role: "donor",
        phone: "+1234567890",
        location: "Test City",
      };

      const user = await User.create(userData);

      expect(user.id).toBeDefined();
      expect(user.name).toBe(userData.name);
      expect(user.email).toBe(userData.email);
      expect(user.role).toBe(userData.role);
      expect(user.phone).toBe(userData.phone);
      expect(user.location).toBe(userData.location);
      expect(user.createdAt).toBeDefined();
      expect(user.updatedAt).toBeDefined();
    });

    it("should validate email uniqueness", async () => {
      const userData = {
        name: "Test User",
        email: "test@example.com",
        password: "password123",
        role: "donor",
      };

      await User.create(userData);

      await expect(User.create(userData)).rejects.toThrow();
    });

    it("should validate required fields", async () => {
      await expect(User.create({})).rejects.toThrow();
    });

    it("should validate email format", async () => {
      const userData = {
        name: "Test User",
        email: "invalid-email",
        password: "password123",
        role: "donor",
      };

      await expect(User.create(userData)).rejects.toThrow();
    });

    it("should validate role enum", async () => {
      const userData = {
        name: "Test User",
        email: "test@example.com",
        password: "password123",
        role: "invalid-role",
      };

      await expect(User.create(userData)).rejects.toThrow();
    });

    it("should validate password length", async () => {
      const userData = {
        name: "Test User",
        email: "test@example.com",
        password: "123",
        role: "donor",
      };

      await expect(User.create(userData)).rejects.toThrow();
    });

    it("should set default role to donor", async () => {
      const userData = {
        name: "Test User",
        email: "test@example.com",
        password: "password123",
      };

      const user = await User.create(userData);
      expect(user.role).toBe("donor");
    });

    it("should update user data", async () => {
      const user = await User.create({
        name: "Test User",
        email: "test@example.com",
        password: "password123",
        role: "donor",
      });

      await user.update({
        name: "Updated User",
        phone: "+9876543210",
      });

      expect(user.name).toBe("Updated User");
      expect(user.phone).toBe("+9876543210");
    });

    it("should delete user", async () => {
      const user = await User.create({
        name: "Test User",
        email: "test@example.com",
        password: "password123",
        role: "donor",
      });

      await user.destroy();

      const deletedUser = await User.findByPk(user.id);
      expect(deletedUser).toBeNull();
    });
  });

  describe("Donation Model", () => {
    let testUser;

    beforeEach(async () => {
      testUser = await User.create({
        name: "Test User",
        email: "test@example.com",
        password: "password123",
        role: "donor",
      });
    });

    it("should create a donation with valid data", async () => {
      const donationData = {
        title: "Test Donation",
        description: "Test description",
        category: "books",
        condition: "good",
        location: "Test City",
        donorId: testUser.id,
        isAvailable: true,
        status: "available",
      };

      const donation = await Donation.create(donationData);

      expect(donation.id).toBeDefined();
      expect(donation.title).toBe(donationData.title);
      expect(donation.description).toBe(donationData.description);
      expect(donation.category).toBe(donationData.category);
      expect(donation.condition).toBe(donationData.condition);
      expect(donation.location).toBe(donationData.location);
      expect(donation.donorId).toBe(donationData.donorId);
      expect(donation.isAvailable).toBe(donationData.isAvailable);
      expect(donation.status).toBe(donationData.status);
      expect(donation.createdAt).toBeDefined();
      expect(donation.updatedAt).toBeDefined();
    });

    it("should validate required fields", async () => {
      await expect(Donation.create({})).rejects.toThrow();
    });

    it("should validate category enum", async () => {
      const donationData = {
        title: "Test Donation",
        description: "Test description",
        category: "invalid-category",
        condition: "good",
        location: "Test City",
        donorId: testUser.id,
      };

      await expect(Donation.create(donationData)).rejects.toThrow();
    });

    it("should validate condition enum", async () => {
      const donationData = {
        title: "Test Donation",
        description: "Test description",
        category: "books",
        condition: "invalid-condition",
        location: "Test City",
        donorId: testUser.id,
      };

      await expect(Donation.create(donationData)).rejects.toThrow();
    });

    it("should validate status enum", async () => {
      const donationData = {
        title: "Test Donation",
        description: "Test description",
        category: "books",
        condition: "good",
        location: "Test City",
        donorId: testUser.id,
        status: "invalid-status",
      };

      await expect(Donation.create(donationData)).rejects.toThrow();
    });

    it("should set default values", async () => {
      const donationData = {
        title: "Test Donation",
        description: "Test description",
        category: "books",
        condition: "good",
        location: "Test City",
        donorId: testUser.id,
      };

      const donation = await Donation.create(donationData);
      expect(donation.isAvailable).toBe(true);
      expect(donation.status).toBe("available");
    });

    it("should maintain foreign key relationship with user", async () => {
      const donation = await Donation.create({
        title: "Test Donation",
        description: "Test description",
        category: "books",
        condition: "good",
        location: "Test City",
        donorId: testUser.id,
      });

      const donationWithUser = await Donation.findByPk(donation.id, {
        include: [{ model: User, as: "donor" }],
      });

      expect(donationWithUser.donor).toBeDefined();
      expect(donationWithUser.donor.id).toBe(testUser.id);
    });

    it("should cascade delete when user is deleted", async () => {
      const donation = await Donation.create({
        title: "Test Donation",
        description: "Test description",
        category: "books",
        condition: "good",
        location: "Test City",
        donorId: testUser.id,
      });

      await testUser.destroy();

      const deletedDonation = await Donation.findByPk(donation.id);
      expect(deletedDonation).toBeNull();
    });
  });

  describe("Request Model", () => {
    let donorUser;
    let receiverUser;
    let testDonation;

    beforeEach(async () => {
      donorUser = await User.create({
        name: "Donor User",
        email: "donor@example.com",
        password: "password123",
        role: "donor",
      });

      receiverUser = await User.create({
        name: "Receiver User",
        email: "receiver@example.com",
        password: "password123",
        role: "receiver",
      });

      testDonation = await Donation.create({
        title: "Test Donation",
        description: "Test description",
        category: "books",
        condition: "good",
        location: "Test City",
        donorId: donorUser.id,
      });
    });

    it("should create a request with valid data", async () => {
      const requestData = {
        donationId: testDonation.id,
        donorId: donorUser.id,
        donorName: donorUser.name,
        receiverId: receiverUser.id,
        receiverName: receiverUser.name,
        receiverEmail: receiverUser.email,
        receiverPhone: "+1234567890",
        message: "Test request message",
        status: "pending",
      };

      const request = await Request.create(requestData);

      expect(request.id).toBeDefined();
      expect(request.donationId).toBe(requestData.donationId);
      expect(request.donorId).toBe(requestData.donorId);
      expect(request.donorName).toBe(requestData.donorName);
      expect(request.receiverId).toBe(requestData.receiverId);
      expect(request.receiverName).toBe(requestData.receiverName);
      expect(request.receiverEmail).toBe(requestData.receiverEmail);
      expect(request.receiverPhone).toBe(requestData.receiverPhone);
      expect(request.message).toBe(requestData.message);
      expect(request.status).toBe(requestData.status);
      expect(request.createdAt).toBeDefined();
      expect(request.updatedAt).toBeDefined();
    });

    it("should validate required fields", async () => {
      await expect(Request.create({})).rejects.toThrow();
    });

    it("should validate status enum", async () => {
      const requestData = {
        donationId: testDonation.id,
        donorId: donorUser.id,
        donorName: donorUser.name,
        receiverId: receiverUser.id,
        receiverName: receiverUser.name,
        receiverEmail: receiverUser.email,
        message: "Test request message",
        status: "invalid-status",
      };

      await expect(Request.create(requestData)).rejects.toThrow();
    });

    it("should set default status to pending", async () => {
      const requestData = {
        donationId: testDonation.id,
        donorId: donorUser.id,
        donorName: donorUser.name,
        receiverId: receiverUser.id,
        receiverName: receiverUser.name,
        receiverEmail: receiverUser.email,
        message: "Test request message",
      };

      const request = await Request.create(requestData);
      expect(request.status).toBe("pending");
    });

    it("should set respondedAt when status changes from pending", async () => {
      const request = await Request.create({
        donationId: testDonation.id,
        donorId: donorUser.id,
        donorName: donorUser.name,
        receiverId: receiverUser.id,
        receiverName: receiverUser.name,
        receiverEmail: receiverUser.email,
        message: "Test request message",
        status: "pending",
      });

      expect(request.respondedAt).toBeNull();

      await request.update({ status: "approved" });

      expect(request.respondedAt).toBeDefined();
    });

    it("should maintain foreign key relationships", async () => {
      const request = await Request.create({
        donationId: testDonation.id,
        donorId: donorUser.id,
        donorName: donorUser.name,
        receiverId: receiverUser.id,
        receiverName: receiverUser.name,
        receiverEmail: receiverUser.email,
        message: "Test request message",
      });

      const requestWithRelations = await Request.findByPk(request.id, {
        include: [
          { model: Donation, as: "donation" },
          { model: User, as: "donor" },
          { model: User, as: "receiver" },
        ],
      });

      expect(requestWithRelations.donation).toBeDefined();
      expect(requestWithRelations.donation.id).toBe(testDonation.id);
      expect(requestWithRelations.donor).toBeDefined();
      expect(requestWithRelations.donor.id).toBe(donorUser.id);
      expect(requestWithRelations.receiver).toBeDefined();
      expect(requestWithRelations.receiver.id).toBe(receiverUser.id);
    });

    it("should cascade delete when donation is deleted", async () => {
      const request = await Request.create({
        donationId: testDonation.id,
        donorId: donorUser.id,
        donorName: donorUser.name,
        receiverId: receiverUser.id,
        receiverName: receiverUser.name,
        receiverEmail: receiverUser.email,
        message: "Test request message",
      });

      await testDonation.destroy();

      const deletedRequest = await Request.findByPk(request.id);
      expect(deletedRequest).toBeNull();
    });

    it("should cascade delete when donor is deleted", async () => {
      const request = await Request.create({
        donationId: testDonation.id,
        donorId: donorUser.id,
        donorName: donorUser.name,
        receiverId: receiverUser.id,
        receiverName: receiverUser.name,
        receiverEmail: receiverUser.email,
        message: "Test request message",
      });

      await donorUser.destroy();

      const deletedRequest = await Request.findByPk(request.id);
      expect(deletedRequest).toBeNull();
    });

    it("should cascade delete when receiver is deleted", async () => {
      const request = await Request.create({
        donationId: testDonation.id,
        donorId: donorUser.id,
        donorName: donorUser.name,
        receiverId: receiverUser.id,
        receiverName: receiverUser.name,
        receiverEmail: receiverUser.email,
        message: "Test request message",
      });

      await receiverUser.destroy();

      const deletedRequest = await Request.findByPk(request.id);
      expect(deletedRequest).toBeNull();
    });
  });

  describe("Message Model", () => {
    let senderUser;
    let receiverUser;
    let testDonation;
    let testRequest;

    beforeEach(async () => {
      senderUser = await User.create({
        name: "Sender User",
        email: "sender@example.com",
        password: "password123",
        role: "donor",
      });

      receiverUser = await User.create({
        name: "Receiver User",
        email: "receiver@example.com",
        password: "password123",
        role: "receiver",
      });

      testDonation = await Donation.create({
        title: "Test Donation",
        description: "Test description",
        category: "books",
        condition: "good",
        location: "Test City",
        donorId: senderUser.id,
      });

      testRequest = await Request.create({
        donationId: testDonation.id,
        donorId: senderUser.id,
        donorName: senderUser.name,
        receiverId: receiverUser.id,
        receiverName: receiverUser.name,
        receiverEmail: receiverUser.email,
        message: "Test request message",
      });
    });

    it("should create a message with valid data", async () => {
      const messageData = {
        senderId: senderUser.id,
        receiverId: receiverUser.id,
        donationId: testDonation.id,
        requestId: testRequest.id,
        content: "Test message content",
        messageType: "text",
        isRead: false,
      };

      const message = await Message.create(messageData);

      expect(message.id).toBeDefined();
      expect(message.senderId).toBe(messageData.senderId);
      expect(message.receiverId).toBe(messageData.receiverId);
      expect(message.donationId).toBe(messageData.donationId);
      expect(message.requestId).toBe(messageData.requestId);
      expect(message.content).toBe(messageData.content);
      expect(message.messageType).toBe(messageData.messageType);
      expect(message.isRead).toBe(messageData.isRead);
      expect(message.createdAt).toBeDefined();
      expect(message.updatedAt).toBeDefined();
    });

    it("should validate required fields", async () => {
      await expect(Message.create({})).rejects.toThrow();
    });

    it("should validate messageType enum", async () => {
      const messageData = {
        senderId: senderUser.id,
        receiverId: receiverUser.id,
        content: "Test message content",
        messageType: "invalid-type",
      };

      await expect(Message.create(messageData)).rejects.toThrow();
    });

    it("should set default values", async () => {
      const messageData = {
        senderId: senderUser.id,
        receiverId: receiverUser.id,
        content: "Test message content",
      };

      const message = await Message.create(messageData);
      expect(message.messageType).toBe("text");
      expect(message.isRead).toBe(false);
    });

    it("should maintain foreign key relationships", async () => {
      const message = await Message.create({
        senderId: senderUser.id,
        receiverId: receiverUser.id,
        donationId: testDonation.id,
        requestId: testRequest.id,
        content: "Test message content",
      });

      const messageWithRelations = await Message.findByPk(message.id, {
        include: [
          { model: User, as: "sender" },
          { model: User, as: "receiver" },
          { model: Donation, as: "donation" },
          { model: Request, as: "request" },
        ],
      });

      expect(messageWithRelations.sender).toBeDefined();
      expect(messageWithRelations.sender.id).toBe(senderUser.id);
      expect(messageWithRelations.receiver).toBeDefined();
      expect(messageWithRelations.receiver.id).toBe(receiverUser.id);
      expect(messageWithRelations.donation).toBeDefined();
      expect(messageWithRelations.donation.id).toBe(testDonation.id);
      expect(messageWithRelations.request).toBeDefined();
      expect(messageWithRelations.request.id).toBe(testRequest.id);
    });

    it("should cascade delete when sender is deleted", async () => {
      const message = await Message.create({
        senderId: senderUser.id,
        receiverId: receiverUser.id,
        content: "Test message content",
      });

      await senderUser.destroy();

      const deletedMessage = await Message.findByPk(message.id);
      expect(deletedMessage).toBeNull();
    });

    it("should cascade delete when receiver is deleted", async () => {
      const message = await Message.create({
        senderId: senderUser.id,
        receiverId: receiverUser.id,
        content: "Test message content",
      });

      await receiverUser.destroy();

      const deletedMessage = await Message.findByPk(message.id);
      expect(deletedMessage).toBeNull();
    });

    it("should set null when donation is deleted", async () => {
      const message = await Message.create({
        senderId: senderUser.id,
        receiverId: receiverUser.id,
        donationId: testDonation.id,
        content: "Test message content",
      });

      await testDonation.destroy();

      const updatedMessage = await Message.findByPk(message.id);
      expect(updatedMessage.donationId).toBeNull();
    });

    it("should set null when request is deleted", async () => {
      const message = await Message.create({
        senderId: senderUser.id,
        receiverId: receiverUser.id,
        requestId: testRequest.id,
        content: "Test message content",
      });

      await testRequest.destroy();

      const updatedMessage = await Message.findByPk(message.id);
      expect(updatedMessage.requestId).toBeNull();
    });
  });
});
