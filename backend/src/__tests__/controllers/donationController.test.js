const request = require("supertest");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const app = require("../server");
const User = require("../models/User");
const Donation = require("../models/Donation");

describe("Donation Controller", () => {
  let authToken;
  let testUser;
  let adminToken;
  let adminUser;

  beforeEach(async () => {
    // Clear tables
    await Donation.destroy({ where: {}, force: true });
    await User.destroy({ where: {}, force: true });

    // Create test user
    const hashedPassword = await bcrypt.hash("password123", 12);
    testUser = await User.create({
      name: "Test User",
      email: "test@example.com",
      password: hashedPassword,
      role: "donor",
    });

    // Create admin user
    const adminHashedPassword = await bcrypt.hash("password123", 12);
    adminUser = await User.create({
      name: "Admin User",
      email: "admin@example.com",
      password: adminHashedPassword,
      role: "admin",
    });

    // Generate auth tokens
    authToken = jwt.sign(
      { userId: testUser.id, email: testUser.email },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    adminToken = jwt.sign(
      { userId: adminUser.id, email: adminUser.email },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );
  });

  describe("GET /api/donations", () => {
    beforeEach(async () => {
      // Create test donations
      await Donation.create({
        title: "Test Donation 1",
        description: "Test description 1",
        category: "books",
        condition: "good",
        location: "Test City",
        donorId: testUser.id,
        isAvailable: true,
        status: "available",
      });

      await Donation.create({
        title: "Test Donation 2",
        description: "Test description 2",
        category: "clothes",
        condition: "excellent",
        location: "Test City",
        donorId: testUser.id,
        isAvailable: false,
        status: "pending",
      });
    });

    it("should get all donations", async () => {
      const response = await request(app).get("/api/donations").expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveLength(2);
      expect(response.body.data[0]).toMatchObject({
        title: expect.any(String),
        description: expect.any(String),
        category: expect.any(String),
        condition: expect.any(String),
        location: expect.any(String),
        donorId: testUser.id,
        isAvailable: expect.any(Boolean),
        status: expect.any(String),
      });
    });

    it("should filter donations by category", async () => {
      const response = await request(app)
        .get("/api/donations?category=books")
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveLength(1);
      expect(response.body.data[0].category).toBe("books");
    });

    it("should filter donations by availability", async () => {
      const response = await request(app)
        .get("/api/donations?available=true")
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveLength(1);
      expect(response.body.data[0].isAvailable).toBe(true);
    });

    it("should filter donations by location", async () => {
      const response = await request(app)
        .get("/api/donations?location=Test City")
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveLength(2);
    });

    it("should paginate donations", async () => {
      const response = await request(app)
        .get("/api/donations?page=1&limit=1")
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveLength(1);
      expect(response.body.pagination).toBeDefined();
      expect(response.body.pagination.page).toBe(1);
      expect(response.body.pagination.limit).toBe(1);
    });
  });

  describe("GET /api/donations/:id", () => {
    let testDonation;

    beforeEach(async () => {
      testDonation = await Donation.create({
        title: "Test Donation",
        description: "Test description",
        category: "books",
        condition: "good",
        location: "Test City",
        donorId: testUser.id,
        isAvailable: true,
        status: "available",
      });
    });

    it("should get donation by ID", async () => {
      const response = await request(app)
        .get(`/api/donations/${testDonation.id}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toMatchObject({
        id: testDonation.id,
        title: testDonation.title,
        description: testDonation.description,
        category: testDonation.category,
        condition: testDonation.condition,
        location: testDonation.location,
        donorId: testDonation.donorId,
        isAvailable: testDonation.isAvailable,
        status: testDonation.status,
      });
    });

    it("should return 404 for non-existent donation", async () => {
      const response = await request(app)
        .get("/api/donations/99999")
        .expect(404);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Donation not found");
    });
  });

  describe("POST /api/donations", () => {
    it("should create a new donation", async () => {
      const donationData = {
        title: "New Test Donation",
        description: "New test description",
        category: "books",
        condition: "good",
        location: "Test City",
      };

      const response = await request(app)
        .post("/api/donations")
        .set("Authorization", `Bearer ${authToken}`)
        .send(donationData)
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toMatchObject({
        title: donationData.title,
        description: donationData.description,
        category: donationData.category,
        condition: donationData.condition,
        location: donationData.location,
        donorId: testUser.id,
        isAvailable: true,
        status: "available",
      });

      // Verify donation was created in database
      const donation = await Donation.findOne({
        where: { title: donationData.title },
      });
      expect(donation).toBeTruthy();
      expect(donation.donorId).toBe(testUser.id);
    });

    it("should reject creation without authentication", async () => {
      const donationData = {
        title: "New Test Donation",
        description: "New test description",
        category: "books",
        condition: "good",
        location: "Test City",
      };

      const response = await request(app)
        .post("/api/donations")
        .send(donationData)
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Access denied");
    });

    it("should validate required fields", async () => {
      const response = await request(app)
        .post("/api/donations")
        .set("Authorization", `Bearer ${authToken}`)
        .send({})
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.errors).toBeDefined();
    });

    it("should validate category enum", async () => {
      const donationData = {
        title: "New Test Donation",
        description: "New test description",
        category: "invalid-category",
        condition: "good",
        location: "Test City",
      };

      const response = await request(app)
        .post("/api/donations")
        .set("Authorization", `Bearer ${authToken}`)
        .send(donationData)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.errors).toBeDefined();
    });

    it("should validate condition enum", async () => {
      const donationData = {
        title: "New Test Donation",
        description: "New test description",
        category: "books",
        condition: "invalid-condition",
        location: "Test City",
      };

      const response = await request(app)
        .post("/api/donations")
        .set("Authorization", `Bearer ${authToken}`)
        .send(donationData)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.errors).toBeDefined();
    });
  });

  describe("PUT /api/donations/:id", () => {
    let testDonation;

    beforeEach(async () => {
      testDonation = await Donation.create({
        title: "Test Donation",
        description: "Test description",
        category: "books",
        condition: "good",
        location: "Test City",
        donorId: testUser.id,
        isAvailable: true,
        status: "available",
      });
    });

    it("should update donation by owner", async () => {
      const updateData = {
        title: "Updated Test Donation",
        description: "Updated test description",
        category: "clothes",
        condition: "excellent",
        location: "Updated City",
      };

      const response = await request(app)
        .put(`/api/donations/${testDonation.id}`)
        .set("Authorization", `Bearer ${authToken}`)
        .send(updateData)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toMatchObject({
        id: testDonation.id,
        title: updateData.title,
        description: updateData.description,
        category: updateData.category,
        condition: updateData.condition,
        location: updateData.location,
      });

      // Verify donation was updated in database
      const updatedDonation = await Donation.findByPk(testDonation.id);
      expect(updatedDonation.title).toBe(updateData.title);
      expect(updatedDonation.description).toBe(updateData.description);
    });

    it("should update donation by admin", async () => {
      const updateData = {
        title: "Admin Updated Donation",
        description: "Admin updated description",
      };

      const response = await request(app)
        .put(`/api/donations/${testDonation.id}`)
        .set("Authorization", `Bearer ${adminToken}`)
        .send(updateData)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.title).toBe(updateData.title);
    });

    it("should reject update by non-owner non-admin", async () => {
      // Create another user
      const hashedPassword = await bcrypt.hash("password123", 12);
      const otherUser = await User.create({
        name: "Other User",
        email: "other@example.com",
        password: hashedPassword,
        role: "donor",
      });

      const otherToken = jwt.sign(
        { userId: otherUser.id, email: otherUser.email },
        process.env.JWT_SECRET,
        { expiresIn: "7d" }
      );

      const updateData = {
        title: "Unauthorized Update",
      };

      const response = await request(app)
        .put(`/api/donations/${testDonation.id}`)
        .set("Authorization", `Bearer ${otherToken}`)
        .send(updateData)
        .expect(403);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Access denied");
    });

    it("should return 404 for non-existent donation", async () => {
      const updateData = {
        title: "Updated Title",
      };

      const response = await request(app)
        .put("/api/donations/99999")
        .set("Authorization", `Bearer ${authToken}`)
        .send(updateData)
        .expect(404);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Donation not found");
    });
  });

  describe("DELETE /api/donations/:id", () => {
    let testDonation;

    beforeEach(async () => {
      testDonation = await Donation.create({
        title: "Test Donation",
        description: "Test description",
        category: "books",
        condition: "good",
        location: "Test City",
        donorId: testUser.id,
        isAvailable: true,
        status: "available",
      });
    });

    it("should delete donation by owner", async () => {
      const response = await request(app)
        .delete(`/api/donations/${testDonation.id}`)
        .set("Authorization", `Bearer ${authToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.message).toContain("deleted successfully");

      // Verify donation was deleted from database
      const deletedDonation = await Donation.findByPk(testDonation.id);
      expect(deletedDonation).toBeNull();
    });

    it("should delete donation by admin", async () => {
      const response = await request(app)
        .delete(`/api/donations/${testDonation.id}`)
        .set("Authorization", `Bearer ${adminToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.message).toContain("deleted successfully");
    });

    it("should reject deletion by non-owner non-admin", async () => {
      // Create another user
      const hashedPassword = await bcrypt.hash("password123", 12);
      const otherUser = await User.create({
        name: "Other User",
        email: "other@example.com",
        password: hashedPassword,
        role: "donor",
      });

      const otherToken = jwt.sign(
        { userId: otherUser.id, email: otherUser.email },
        process.env.JWT_SECRET,
        { expiresIn: "7d" }
      );

      const response = await request(app)
        .delete(`/api/donations/${testDonation.id}`)
        .set("Authorization", `Bearer ${otherToken}`)
        .expect(403);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Access denied");
    });

    it("should return 404 for non-existent donation", async () => {
      const response = await request(app)
        .delete("/api/donations/99999")
        .set("Authorization", `Bearer ${authToken}`)
        .expect(404);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Donation not found");
    });
  });

  describe("GET /api/donations/admin/stats", () => {
    beforeEach(async () => {
      // Create test donations with different statuses
      await Donation.create({
        title: "Available Donation",
        description: "Test description",
        category: "books",
        condition: "good",
        location: "Test City",
        donorId: testUser.id,
        isAvailable: true,
        status: "available",
      });

      await Donation.create({
        title: "Pending Donation",
        description: "Test description",
        category: "clothes",
        condition: "excellent",
        location: "Test City",
        donorId: testUser.id,
        isAvailable: false,
        status: "pending",
      });

      await Donation.create({
        title: "Completed Donation",
        description: "Test description",
        category: "electronics",
        condition: "good",
        location: "Test City",
        donorId: testUser.id,
        isAvailable: false,
        status: "completed",
      });
    });

    it("should get donation statistics for admin", async () => {
      const response = await request(app)
        .get("/api/donations/admin/stats")
        .set("Authorization", `Bearer ${adminToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toMatchObject({
        total: 3,
        available: 1,
        pending: 1,
        completed: 1,
        cancelled: 0,
      });
    });

    it("should reject stats request by non-admin", async () => {
      const response = await request(app)
        .get("/api/donations/admin/stats")
        .set("Authorization", `Bearer ${authToken}`)
        .expect(403);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Access denied");
    });

    it("should reject stats request without authentication", async () => {
      const response = await request(app)
        .get("/api/donations/admin/stats")
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Access denied");
    });
  });
});
