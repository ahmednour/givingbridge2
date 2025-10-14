const request = require("supertest");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const app = require("../server");
const User = require("../models/User");
const Donation = require("../models/Donation");
const Request = require("../models/Request");

describe("User Controller", () => {
  let authToken;
  let testUser;
  let adminToken;
  let adminUser;
  let otherUserToken;
  let otherUser;

  beforeEach(async () => {
    // Clear tables
    await Request.destroy({ where: {}, force: true });
    await Donation.destroy({ where: {}, force: true });
    await User.destroy({ where: {}, force: true });

    // Create test user
    const hashedPassword = await bcrypt.hash("password123", 12);
    testUser = await User.create({
      name: "Test User",
      email: "test@example.com",
      password: hashedPassword,
      role: "donor",
      phone: "+1234567890",
      location: "Test City",
    });

    // Create admin user
    const adminHashedPassword = await bcrypt.hash("password123", 12);
    adminUser = await User.create({
      name: "Admin User",
      email: "admin@example.com",
      password: adminHashedPassword,
      role: "admin",
    });

    // Create other user
    const otherHashedPassword = await bcrypt.hash("password123", 12);
    otherUser = await User.create({
      name: "Other User",
      email: "other@example.com",
      password: otherHashedPassword,
      role: "receiver",
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

    otherUserToken = jwt.sign(
      { userId: otherUser.id, email: otherUser.email },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );
  });

  describe("GET /api/users", () => {
    it("should get all users for admin", async () => {
      const response = await request(app)
        .get("/api/users")
        .set("Authorization", `Bearer ${adminToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.users).toHaveLength(3);
      expect(response.body.data.users[0]).toMatchObject({
        id: expect.any(Number),
        name: expect.any(String),
        email: expect.any(String),
        role: expect.any(String),
      });
      expect(response.body.data.users[0].password).toBeUndefined();
    });

    it("should reject request by non-admin", async () => {
      const response = await request(app)
        .get("/api/users")
        .set("Authorization", `Bearer ${authToken}`)
        .expect(403);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Access denied");
    });

    it("should filter users by role", async () => {
      const response = await request(app)
        .get("/api/users?role=donor")
        .set("Authorization", `Bearer ${adminToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.users).toHaveLength(1);
      expect(response.body.data.users[0].role).toBe("donor");
    });

    it("should search users by name", async () => {
      const response = await request(app)
        .get("/api/users?search=Test")
        .set("Authorization", `Bearer ${adminToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.users).toHaveLength(1);
      expect(response.body.data.users[0].name).toContain("Test");
    });

    it("should paginate users", async () => {
      const response = await request(app)
        .get("/api/users?page=1&limit=2")
        .set("Authorization", `Bearer ${adminToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.users).toHaveLength(2);
      expect(response.body.data.pagination).toBeDefined();
      expect(response.body.data.pagination.page).toBe(1);
      expect(response.body.data.pagination.limit).toBe(2);
    });
  });

  describe("GET /api/users/:id", () => {
    it("should get user by ID for admin", async () => {
      const response = await request(app)
        .get(`/api/users/${testUser.id}`)
        .set("Authorization", `Bearer ${adminToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toMatchObject({
        id: testUser.id,
        name: testUser.name,
        email: testUser.email,
        role: testUser.role,
        phone: testUser.phone,
        location: testUser.location,
      });
      expect(response.body.data.password).toBeUndefined();
    });

    it("should get own profile for user", async () => {
      const response = await request(app)
        .get(`/api/users/${testUser.id}`)
        .set("Authorization", `Bearer ${authToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.id).toBe(testUser.id);
    });

    it("should reject access to other user profile", async () => {
      const response = await request(app)
        .get(`/api/users/${otherUser.id}`)
        .set("Authorization", `Bearer ${authToken}`)
        .expect(403);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Access denied");
    });

    it("should return 404 for non-existent user", async () => {
      const response = await request(app)
        .get("/api/users/99999")
        .set("Authorization", `Bearer ${adminToken}`)
        .expect(404);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("User not found");
    });
  });

  describe("PUT /api/users/:id", () => {
    it("should update own profile", async () => {
      const updateData = {
        name: "Updated Test User",
        phone: "+9876543210",
        location: "Updated City",
      };

      const response = await request(app)
        .put(`/api/users/${testUser.id}`)
        .set("Authorization", `Bearer ${authToken}`)
        .send(updateData)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toMatchObject({
        id: testUser.id,
        name: updateData.name,
        phone: updateData.phone,
        location: updateData.location,
      });

      // Verify user was updated in database
      const updatedUser = await User.findByPk(testUser.id);
      expect(updatedUser.name).toBe(updateData.name);
      expect(updatedUser.phone).toBe(updateData.phone);
      expect(updatedUser.location).toBe(updateData.location);
    });

    it("should update user by admin", async () => {
      const updateData = {
        name: "Admin Updated User",
        role: "receiver",
      };

      const response = await request(app)
        .put(`/api/users/${testUser.id}`)
        .set("Authorization", `Bearer ${adminToken}`)
        .send(updateData)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.name).toBe(updateData.name);
      expect(response.body.data.role).toBe(updateData.role);
    });

    it("should reject role change by non-admin", async () => {
      const updateData = {
        role: "admin",
      };

      const response = await request(app)
        .put(`/api/users/${testUser.id}`)
        .set("Authorization", `Bearer ${authToken}`)
        .send(updateData)
        .expect(403);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("You cannot change your role");
    });

    it("should reject update of other user by non-admin", async () => {
      const updateData = {
        name: "Unauthorized Update",
      };

      const response = await request(app)
        .put(`/api/users/${otherUser.id}`)
        .set("Authorization", `Bearer ${authToken}`)
        .send(updateData)
        .expect(403);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Access denied");
    });

    it("should reject update with duplicate email", async () => {
      const updateData = {
        email: otherUser.email,
      };

      const response = await request(app)
        .put(`/api/users/${testUser.id}`)
        .set("Authorization", `Bearer ${authToken}`)
        .send(updateData)
        .expect(409);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Email already exists");
    });

    it("should hash password when updating", async () => {
      const updateData = {
        password: "newpassword123",
      };

      const response = await request(app)
        .put(`/api/users/${testUser.id}`)
        .set("Authorization", `Bearer ${authToken}`)
        .send(updateData)
        .expect(200);

      expect(response.body.success).toBe(true);

      // Verify password was hashed
      const updatedUser = await User.findByPk(testUser.id);
      expect(updatedUser.password).not.toBe(updateData.password);
      expect(
        bcrypt.compareSync(updateData.password, updatedUser.password)
      ).toBe(true);
    });

    it("should return 404 for non-existent user", async () => {
      const updateData = {
        name: "Updated Name",
      };

      const response = await request(app)
        .put("/api/users/99999")
        .set("Authorization", `Bearer ${adminToken}`)
        .send(updateData)
        .expect(404);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("User not found");
    });
  });

  describe("DELETE /api/users/:id", () => {
    it("should delete user by admin", async () => {
      const response = await request(app)
        .delete(`/api/users/${otherUser.id}`)
        .set("Authorization", `Bearer ${adminToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.message).toContain("deleted successfully");

      // Verify user was deleted from database
      const deletedUser = await User.findByPk(otherUser.id);
      expect(deletedUser).toBeNull();
    });

    it("should reject self-deletion", async () => {
      const response = await request(app)
        .delete(`/api/users/${adminUser.id}`)
        .set("Authorization", `Bearer ${adminToken}`)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain(
        "You cannot delete your own account"
      );
    });

    it("should reject deletion by non-admin", async () => {
      const response = await request(app)
        .delete(`/api/users/${otherUser.id}`)
        .set("Authorization", `Bearer ${authToken}`)
        .expect(403);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Access denied");
    });

    it("should reject deletion of user with active donations", async () => {
      // Create a donation for the user
      await Donation.create({
        title: "Test Donation",
        description: "Test description",
        category: "books",
        condition: "good",
        location: "Test City",
        donorId: otherUser.id,
        isAvailable: true,
        status: "available",
      });

      const response = await request(app)
        .delete(`/api/users/${otherUser.id}`)
        .set("Authorization", `Bearer ${adminToken}`)
        .expect(409);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain(
        "Cannot delete user with active donations"
      );
    });

    it("should reject deletion of user with active requests", async () => {
      // Create a donation first
      const donation = await Donation.create({
        title: "Test Donation",
        description: "Test description",
        category: "books",
        condition: "good",
        location: "Test City",
        donorId: testUser.id,
        isAvailable: true,
        status: "available",
      });

      // Create a request for the user
      await Request.create({
        donationId: donation.id,
        donorId: testUser.id,
        donorName: testUser.name,
        receiverId: otherUser.id,
        receiverName: otherUser.name,
        receiverEmail: otherUser.email,
        message: "Test request",
        status: "pending",
      });

      const response = await request(app)
        .delete(`/api/users/${otherUser.id}`)
        .set("Authorization", `Bearer ${adminToken}`)
        .expect(409);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain(
        "Cannot delete user with active donations or requests"
      );
    });

    it("should return 404 for non-existent user", async () => {
      const response = await request(app)
        .delete("/api/users/99999")
        .set("Authorization", `Bearer ${adminToken}`)
        .expect(404);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("User not found");
    });
  });

  describe("GET /api/users/:id/donations", () => {
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

    it("should get user donations for admin", async () => {
      const response = await request(app)
        .get(`/api/users/${testUser.id}/donations`)
        .set("Authorization", `Bearer ${adminToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveLength(2);
      expect(response.body.data[0].donorId).toBe(testUser.id);
    });

    it("should get own donations for user", async () => {
      const response = await request(app)
        .get(`/api/users/${testUser.id}/donations`)
        .set("Authorization", `Bearer ${authToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveLength(2);
    });

    it("should reject access to other user donations", async () => {
      const response = await request(app)
        .get(`/api/users/${otherUser.id}/donations`)
        .set("Authorization", `Bearer ${authToken}`)
        .expect(403);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Access denied");
    });
  });

  describe("GET /api/users/:id/stats", () => {
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
        status: "completed",
      });

      // Create test requests
      const donation = await Donation.create({
        title: "Test Donation 3",
        description: "Test description 3",
        category: "electronics",
        condition: "good",
        location: "Test City",
        donorId: testUser.id,
        isAvailable: true,
        status: "available",
      });

      await Request.create({
        donationId: donation.id,
        donorId: testUser.id,
        donorName: testUser.name,
        receiverId: otherUser.id,
        receiverName: otherUser.name,
        receiverEmail: otherUser.email,
        message: "Test request",
        status: "completed",
      });
    });

    it("should get user statistics for admin", async () => {
      const response = await request(app)
        .get(`/api/users/${testUser.id}/stats`)
        .set("Authorization", `Bearer ${adminToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toMatchObject({
        donations: {
          total: 3,
          completed: 1,
        },
        requests: {
          total: 0,
          completed: 0,
        },
        incomingRequests: {
          total: 1,
        },
      });
    });

    it("should get own statistics for user", async () => {
      const response = await request(app)
        .get(`/api/users/${testUser.id}/stats`)
        .set("Authorization", `Bearer ${authToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.donations.total).toBe(3);
    });

    it("should reject access to other user statistics", async () => {
      const response = await request(app)
        .get(`/api/users/${otherUser.id}/stats`)
        .set("Authorization", `Bearer ${authToken}`)
        .expect(403);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Access denied");
    });
  });
});
