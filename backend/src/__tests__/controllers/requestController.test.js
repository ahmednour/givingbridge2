const request = require("supertest");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const app = require("../server");
const User = require("../models/User");
const Donation = require("../models/Donation");
const Request = require("../models/Request");

describe("Request Controller", () => {
  let donorToken;
  let donorUser;
  let receiverToken;
  let receiverUser;
  let adminToken;
  let adminUser;
  let testDonation;

  beforeEach(async () => {
    // Clear tables
    await Request.destroy({ where: {}, force: true });
    await Donation.destroy({ where: {}, force: true });
    await User.destroy({ where: {}, force: true });

    // Create donor user
    const donorHashedPassword = await bcrypt.hash("password123", 12);
    donorUser = await User.create({
      name: "Donor User",
      email: "donor@example.com",
      password: donorHashedPassword,
      role: "donor",
    });

    // Create receiver user
    const receiverHashedPassword = await bcrypt.hash("password123", 12);
    receiverUser = await User.create({
      name: "Receiver User",
      email: "receiver@example.com",
      password: receiverHashedPassword,
      role: "receiver",
    });

    // Create admin user
    const adminHashedPassword = await bcrypt.hash("password123", 12);
    adminUser = await User.create({
      name: "Admin User",
      email: "admin@example.com",
      password: adminHashedPassword,
      role: "admin",
    });

    // Create test donation
    testDonation = await Donation.create({
      title: "Test Donation",
      description: "Test description",
      category: "books",
      condition: "good",
      location: "Test City",
      donorId: donorUser.id,
      isAvailable: true,
      status: "available",
    });

    // Generate auth tokens
    donorToken = jwt.sign(
      { userId: donorUser.id, email: donorUser.email },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    receiverToken = jwt.sign(
      { userId: receiverUser.id, email: receiverUser.email },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    adminToken = jwt.sign(
      { userId: adminUser.id, email: adminUser.email },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );
  });

  describe("GET /api/requests", () => {
    beforeEach(async () => {
      // Create test requests
      await Request.create({
        donationId: testDonation.id,
        donorId: donorUser.id,
        donorName: donorUser.name,
        receiverId: receiverUser.id,
        receiverName: receiverUser.name,
        receiverEmail: receiverUser.email,
        receiverPhone: "+1234567890",
        message: "Test request message",
        status: "pending",
      });
    });

    it("should get all requests for admin", async () => {
      const response = await request(app)
        .get("/api/requests")
        .set("Authorization", `Bearer ${adminToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveLength(1);
      expect(response.body.data[0]).toMatchObject({
        donationId: testDonation.id,
        donorId: donorUser.id,
        receiverId: receiverUser.id,
        status: "pending",
      });
    });

    it("should get requests for donor", async () => {
      const response = await request(app)
        .get("/api/requests")
        .set("Authorization", `Bearer ${donorToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveLength(1);
      expect(response.body.data[0].donorId).toBe(donorUser.id);
    });

    it("should get requests for receiver", async () => {
      const response = await request(app)
        .get("/api/requests")
        .set("Authorization", `Bearer ${receiverToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveLength(1);
      expect(response.body.data[0].receiverId).toBe(receiverUser.id);
    });

    it("should filter requests by status", async () => {
      const response = await request(app)
        .get("/api/requests?status=pending")
        .set("Authorization", `Bearer ${adminToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveLength(1);
      expect(response.body.data[0].status).toBe("pending");
    });

    it("should filter requests by donation ID", async () => {
      const response = await request(app)
        .get(`/api/requests?donationId=${testDonation.id}`)
        .set("Authorization", `Bearer ${adminToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveLength(1);
      expect(response.body.data[0].donationId).toBe(testDonation.id);
    });
  });

  describe("POST /api/requests", () => {
    it("should create a new request", async () => {
      const requestData = {
        donationId: testDonation.id,
        message: "I would like to request this donation",
      };

      const response = await request(app)
        .post("/api/requests")
        .set("Authorization", `Bearer ${receiverToken}`)
        .send(requestData)
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toMatchObject({
        donationId: testDonation.id,
        donorId: donorUser.id,
        receiverId: receiverUser.id,
        message: requestData.message,
        status: "pending",
      });

      // Verify request was created in database
      const createdRequest = await Request.findOne({
        where: { donationId: testDonation.id, receiverId: receiverUser.id },
      });
      expect(createdRequest).toBeTruthy();
      expect(createdRequest.message).toBe(requestData.message);
    });

    it("should reject request from donor", async () => {
      const requestData = {
        donationId: testDonation.id,
        message: "I would like to request this donation",
      };

      const response = await request(app)
        .post("/api/requests")
        .set("Authorization", `Bearer ${donorToken}`)
        .send(requestData)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain(
        "Only receivers can request donations"
      );
    });

    it("should reject request for non-existent donation", async () => {
      const requestData = {
        donationId: 99999,
        message: "I would like to request this donation",
      };

      const response = await request(app)
        .post("/api/requests")
        .set("Authorization", `Bearer ${receiverToken}`)
        .send(requestData)
        .expect(404);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Donation not found");
    });

    it("should reject request for unavailable donation", async () => {
      // Make donation unavailable
      await testDonation.update({ isAvailable: false });

      const requestData = {
        donationId: testDonation.id,
        message: "I would like to request this donation",
      };

      const response = await request(app)
        .post("/api/requests")
        .set("Authorization", `Bearer ${receiverToken}`)
        .send(requestData)
        .expect(409);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("no longer available");
    });

    it("should reject duplicate request", async () => {
      const requestData = {
        donationId: testDonation.id,
        message: "I would like to request this donation",
      };

      // Create first request
      await request(app)
        .post("/api/requests")
        .set("Authorization", `Bearer ${receiverToken}`)
        .send(requestData)
        .expect(201);

      // Try to create duplicate request
      const response = await request(app)
        .post("/api/requests")
        .set("Authorization", `Bearer ${receiverToken}`)
        .send(requestData)
        .expect(409);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("already requested");
    });

    it("should validate required fields", async () => {
      const response = await request(app)
        .post("/api/requests")
        .set("Authorization", `Bearer ${receiverToken}`)
        .send({})
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.errors).toBeDefined();
    });
  });

  describe("PUT /api/requests/:id/status", () => {
    let testRequest;

    beforeEach(async () => {
      testRequest = await Request.create({
        donationId: testDonation.id,
        donorId: donorUser.id,
        donorName: donorUser.name,
        receiverId: receiverUser.id,
        receiverName: receiverUser.name,
        receiverEmail: receiverUser.email,
        receiverPhone: "+1234567890",
        message: "Test request message",
        status: "pending",
      });
    });

    it("should approve request by donor", async () => {
      const updateData = {
        status: "approved",
        responseMessage: "Request approved",
      };

      const response = await request(app)
        .put(`/api/requests/${testRequest.id}/status`)
        .set("Authorization", `Bearer ${donorToken}`)
        .send(updateData)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.status).toBe("approved");
      expect(response.body.data.responseMessage).toBe(
        updateData.responseMessage
      );
      expect(response.body.data.respondedAt).toBeDefined();

      // Verify donation was updated
      const updatedDonation = await Donation.findByPk(testDonation.id);
      expect(updatedDonation.isAvailable).toBe(false);
      expect(updatedDonation.status).toBe("pending");
    });

    it("should decline request by donor", async () => {
      const updateData = {
        status: "declined",
        responseMessage: "Request declined",
      };

      const response = await request(app)
        .put(`/api/requests/${testRequest.id}/status`)
        .set("Authorization", `Bearer ${donorToken}`)
        .send(updateData)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.status).toBe("declined");

      // Verify donation was updated
      const updatedDonation = await Donation.findByPk(testDonation.id);
      expect(updatedDonation.isAvailable).toBe(true);
      expect(updatedDonation.status).toBe("available");
    });

    it("should complete request by donor", async () => {
      // First approve the request
      await testRequest.update({ status: "approved" });
      await testDonation.update({ isAvailable: false, status: "pending" });

      const updateData = {
        status: "completed",
      };

      const response = await request(app)
        .put(`/api/requests/${testRequest.id}/status`)
        .set("Authorization", `Bearer ${donorToken}`)
        .send(updateData)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.status).toBe("completed");

      // Verify donation was updated
      const updatedDonation = await Donation.findByPk(testDonation.id);
      expect(updatedDonation.status).toBe("completed");
    });

    it("should cancel request by receiver", async () => {
      const updateData = {
        status: "cancelled",
      };

      const response = await request(app)
        .put(`/api/requests/${testRequest.id}/status`)
        .set("Authorization", `Bearer ${receiverToken}`)
        .send(updateData)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.status).toBe("cancelled");

      // Verify donation was updated
      const updatedDonation = await Donation.findByPk(testDonation.id);
      expect(updatedDonation.isAvailable).toBe(true);
      expect(updatedDonation.status).toBe("available");
    });

    it("should reject status update by unauthorized user", async () => {
      // Create another user
      const hashedPassword = await bcrypt.hash("password123", 12);
      const otherUser = await User.create({
        name: "Other User",
        email: "other@example.com",
        password: hashedPassword,
        role: "receiver",
      });

      const otherToken = jwt.sign(
        { userId: otherUser.id, email: otherUser.email },
        process.env.JWT_SECRET,
        { expiresIn: "7d" }
      );

      const updateData = {
        status: "approved",
      };

      const response = await request(app)
        .put(`/api/requests/${testRequest.id}/status`)
        .set("Authorization", `Bearer ${otherToken}`)
        .send(updateData)
        .expect(403);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Access denied");
    });

    it("should reject invalid status transition", async () => {
      // Set request to completed
      await testRequest.update({ status: "completed" });

      const updateData = {
        status: "approved",
      };

      const response = await request(app)
        .put(`/api/requests/${testRequest.id}/status`)
        .set("Authorization", `Bearer ${donorToken}`)
        .send(updateData)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Cannot update a completed");
    });

    it("should return 404 for non-existent request", async () => {
      const updateData = {
        status: "approved",
      };

      const response = await request(app)
        .put("/api/requests/99999/status")
        .set("Authorization", `Bearer ${donorToken}`)
        .send(updateData)
        .expect(404);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Request not found");
    });

    it("should validate status enum", async () => {
      const updateData = {
        status: "invalid-status",
      };

      const response = await request(app)
        .put(`/api/requests/${testRequest.id}/status`)
        .set("Authorization", `Bearer ${donorToken}`)
        .send(updateData)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.errors).toBeDefined();
    });
  });

  describe("GET /api/requests/admin/stats", () => {
    beforeEach(async () => {
      // Create test requests with different statuses
      await Request.create({
        donationId: testDonation.id,
        donorId: donorUser.id,
        donorName: donorUser.name,
        receiverId: receiverUser.id,
        receiverName: receiverUser.name,
        receiverEmail: receiverUser.email,
        message: "Test request 1",
        status: "pending",
      });

      await Request.create({
        donationId: testDonation.id,
        donorId: donorUser.id,
        donorName: donorUser.name,
        receiverId: receiverUser.id,
        receiverName: receiverUser.name,
        receiverEmail: receiverUser.email,
        message: "Test request 2",
        status: "approved",
      });

      await Request.create({
        donationId: testDonation.id,
        donorId: donorUser.id,
        donorName: donorUser.name,
        receiverId: receiverUser.id,
        receiverName: receiverUser.name,
        receiverEmail: receiverUser.email,
        message: "Test request 3",
        status: "completed",
      });
    });

    it("should get request statistics for admin", async () => {
      const response = await request(app)
        .get("/api/requests/admin/stats")
        .set("Authorization", `Bearer ${adminToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toMatchObject({
        total: 3,
        pending: 1,
        approved: 1,
        declined: 0,
        completed: 1,
        cancelled: 0,
      });
    });

    it("should reject stats request by non-admin", async () => {
      const response = await request(app)
        .get("/api/requests/admin/stats")
        .set("Authorization", `Bearer ${donorToken}`)
        .expect(403);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Access denied");
    });
  });
});
