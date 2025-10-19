const request = require("supertest");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const { app } = require("../server");
const User = require("../models/User");
const Donation = require("../models/Donation");

describe("Middleware Tests", () => {
  let authToken;
  let testUser;
  let adminToken;
  let adminUser;
  let testDonation;

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

    // Create test donation
    testDonation = await Donation.create({
      title: "Test Donation",
      description: "Test description",
      category: "books",
      condition: "good",
      location: "Test City",
      donorId: testUser.id,
      donorName: testUser.name,
      isAvailable: true,
      status: "available",
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

  describe("Authentication Middleware", () => {
    it("should allow access with valid token", async () => {
      const response = await request(app)
        .get("/api/auth/me")
        .set("Authorization", `Bearer ${authToken}`)
        .expect(200);

      expect(response.body.user).toBeDefined();
      expect(response.body.user.id).toBe(testUser.id);
    });

    it("should reject access without token", async () => {
      const response = await request(app).get("/api/auth/me").expect(401);

      expect(response.body.message).toContain("Access denied");
    });

    it("should reject access with invalid token", async () => {
      const response = await request(app)
        .get("/api/auth/me")
        .set("Authorization", "Bearer invalid-token")
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Invalid token");
    });

    it("should reject access with expired token", async () => {
      const expiredToken = jwt.sign(
        { userId: testUser.id },
        process.env.JWT_SECRET,
        { expiresIn: "-1h" }
      );

      const response = await request(app)
        .get("/api/auth/me")
        .set("Authorization", `Bearer ${expiredToken}`)
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Token expired");
    });

    it("should reject access with malformed token", async () => {
      const response = await request(app)
        .get("/api/auth/me")
        .set("Authorization", "Bearer malformed.token")
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Invalid token");
    });
  });

  describe("Admin Middleware", () => {
    it("should allow access for admin user", async () => {
      const response = await request(app)
        .get("/api/donations/admin/stats")
        .set("Authorization", `Bearer ${adminToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
    });

    it("should reject access for non-admin user", async () => {
      const response = await request(app)
        .get("/api/donations/admin/stats")
        .set("Authorization", `Bearer ${authToken}`)
        .expect(403);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Access denied");
    });

    it("should reject access without authentication", async () => {
      const response = await request(app)
        .get("/api/donations/admin/stats")
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Access denied");
    });
  });

  describe("Role Middleware", () => {
    it("should allow access for user with correct role", async () => {
      // This would need a specific endpoint that uses requireRole middleware
      // For now, we'll test the concept with admin role
      const response = await request(app)
        .get("/api/donations/admin/stats")
        .set("Authorization", `Bearer ${adminToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
    });

    it("should reject access for user with incorrect role", async () => {
      const response = await request(app)
        .get("/api/donations/admin/stats")
        .set("Authorization", `Bearer ${authToken}`)
        .expect(403);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Access denied");
    });
  });

  describe("Ownership Middleware", () => {
    it("should allow access for resource owner", async () => {
      const response = await request(app)
        .put(`/api/donations/${testDonation.id}`)
        .set("Authorization", `Bearer ${authToken}`)
        .send({ title: "Updated Title" })
        .expect(200);

      expect(response.body.success).toBe(true);
    });

    it("should allow access for admin", async () => {
      const response = await request(app)
        .put(`/api/donations/${testDonation.id}`)
        .set("Authorization", `Bearer ${adminToken}`)
        .send({ title: "Admin Updated Title" })
        .expect(200);

      expect(response.body.success).toBe(true);
    });

    it("should reject access for non-owner non-admin", async () => {
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
        .put(`/api/donations/${testDonation.id}`)
        .set("Authorization", `Bearer ${otherToken}`)
        .send({ title: "Unauthorized Update" })
        .expect(403);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Access denied");
    });
  });

  describe("Validation Middleware", () => {
    it("should validate required fields", async () => {
      const response = await request(app)
        .post("/api/donations")
        .set("Authorization", `Bearer ${authToken}`)
        .send({})
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.errors).toBeDefined();
    });

    it("should validate email format", async () => {
      const response = await request(app)
        .post("/api/auth/register")
        .send({
          name: "Test User",
          email: "invalid-email",
          password: "password123",
          role: "donor",
        })
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.errors).toBeDefined();
    });

    it("should validate password length", async () => {
      const response = await request(app)
        .post("/api/auth/register")
        .send({
          name: "Test User",
          email: "test@example.com",
          password: "123",
          role: "donor",
        })
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.errors).toBeDefined();
    });

    it("should validate enum values", async () => {
      const response = await request(app)
        .post("/api/donations")
        .set("Authorization", `Bearer ${authToken}`)
        .send({
          title: "Test Donation",
          description: "Test description",
          category: "invalid-category",
          condition: "good",
          location: "Test City",
        })
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.errors).toBeDefined();
    });
  });

  describe("Pagination Middleware", () => {
    beforeEach(async () => {
      // Create multiple donations for pagination testing
      for (let i = 1; i <= 5; i++) {
        await Donation.create({
          title: `Test Donation ${i}`,
          description: `Test description ${i}`,
          category: "books",
          condition: "good",
          location: "Test City",
          donorId: testUser.id,
          donorName: testUser.name,
          isAvailable: true,
          status: "available",
        });
      }
    });

    it("should paginate results", async () => {
      const response = await request(app)
        .get("/api/donations?page=1&limit=2")
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveLength(2);
      expect(response.body.pagination).toBeDefined();
      expect(response.body.pagination.page).toBe(1);
      expect(response.body.pagination.limit).toBe(2);
      expect(response.body.pagination.total).toBe(6); // 5 new + 1 existing
    });

    it("should use default pagination values", async () => {
      const response = await request(app).get("/api/donations").expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveLength(6);
      expect(response.body.pagination).toBeDefined();
      expect(response.body.pagination.page).toBe(1);
      expect(response.body.pagination.limit).toBe(20); // default limit
    });

    it("should handle invalid pagination parameters", async () => {
      const response = await request(app)
        .get("/api/donations?page=0&limit=-1")
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.pagination.page).toBe(1); // default page
      expect(response.body.pagination.limit).toBe(20); // default limit
    });
  });

  describe("Sorting Middleware", () => {
    beforeEach(async () => {
      // Create donations with different creation times
      await Donation.create({
        title: "A Donation",
        description: "Test description",
        category: "books",
        condition: "good",
        location: "Test City",
        donorId: testUser.id,
        donorName: testUser.name,
        isAvailable: true,
        status: "available",
      });

      await new Promise((resolve) => setTimeout(resolve, 100)); // Small delay

      await Donation.create({
        title: "B Donation",
        description: "Test description",
        category: "clothes",
        condition: "excellent",
        location: "Test City",
        donorId: testUser.id,
        donorName: testUser.name,
        isAvailable: true,
        status: "available",
      });
    });

    it("should sort by title ascending", async () => {
      const response = await request(app)
        .get("/api/donations?sort=title&order=asc")
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data[0].title).toBe("A Donation");
      expect(response.body.data[1].title).toBe("B Donation");
    });

    it("should sort by title descending", async () => {
      const response = await request(app)
        .get("/api/donations?sort=title&order=desc")
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data[0].title).toBe("B Donation");
      expect(response.body.data[1].title).toBe("A Donation");
    });

    it("should use default sorting", async () => {
      const response = await request(app).get("/api/donations").expect(200);

      expect(response.body.success).toBe(true);
      // Should be sorted by createdAt desc by default
      expect(response.body.data[0].title).toBe("B Donation");
    });
  });

  describe("Error Handling Middleware", () => {
    it("should handle validation errors", async () => {
      const response = await request(app)
        .post("/api/auth/register")
        .send({
          name: "",
          email: "invalid-email",
          password: "123",
          role: "invalid-role",
        })
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.errors).toBeDefined();
      expect(response.body.message).toContain("Validation failed");
    });

    it("should handle not found errors", async () => {
      const response = await request(app)
        .get("/api/donations/99999")
        .expect(404);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Donation not found");
    });

    it("should handle conflict errors", async () => {
      // Create first user
      await request(app)
        .post("/api/auth/register")
        .send({
          name: "Test User",
          email: "conflict@example.com",
          password: "password123",
          role: "donor",
        })
        .expect(201);

      // Try to create second user with same email
      const response = await request(app)
        .post("/api/auth/register")
        .send({
          name: "Test User 2",
          email: "conflict@example.com",
          password: "password123",
          role: "donor",
        })
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("already exists");
    });

    it("should handle authentication errors", async () => {
      const response = await request(app).get("/api/auth/me").expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Access denied");
    });

    it("should handle authorization errors", async () => {
      const response = await request(app)
        .get("/api/donations/admin/stats")
        .set("Authorization", `Bearer ${authToken}`)
        .expect(403);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Access denied");
    });
  });
});
