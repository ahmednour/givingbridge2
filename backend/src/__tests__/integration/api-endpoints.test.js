const request = require("supertest");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const models = require("../../models");
const TestDataSeeder = require("../test-data-seeder");

// Mock app for testing - we'll create a minimal express app
const express = require("express");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(express.json());

// Import routes
const authRoutes = require("../../routes/auth");
const donationRoutes = require("../../routes/donations");
const requestRoutes = require("../../routes/requests");
const userRoutes = require("../../routes/users");

app.use("/api/auth", authRoutes);
app.use("/api/donations", donationRoutes);
app.use("/api/requests", requestRoutes);
app.use("/api/users", userRoutes);

// Error handling middleware
app.use((error, req, res, next) => {
  res.status(error.status || 500).json({
    success: false,
    message: error.message || "Internal server error",
  });
});

describe("API Endpoints Integration Tests", () => {
  let seeder;
  let testUsers;
  let testDonations;
  let testRequests;
  let authTokens;

  beforeAll(() => {
    seeder = new TestDataSeeder();
  });

  beforeEach(async () => {
    if (!global.testUtils.isConnected()) {
      console.log("🟡 Skipping API integration tests - no database connection");
      return;
    }

    // Seed test data
    testUsers = await seeder.seedTestUsers(3);
    testDonations = await seeder.seedTestDonations(testUsers, 2);
    testRequests = await seeder.seedTestRequests(testUsers, testDonations, 2);

    // Generate auth tokens for test users
    authTokens = testUsers.map(user => 
      jwt.sign(
        { userId: user.id, email: user.email },
        process.env.JWT_SECRET,
        { expiresIn: "1h" }
      )
    );
  });

  afterEach(async () => {
    if (!global.testUtils.isConnected()) return;
    await seeder.cleanupTestData();
  });

  describe("Authentication Endpoints", () => {
    it("should register a new user", async () => {
      if (!global.testUtils.isConnected()) return;

      const userData = {
        name: "New User",
        email: "newuser@example.com",
        password: "password123",
        role: "donor",
        phone: "+1234567890",
        location: "New City",
      };

      const response = await request(app)
        .post("/api/auth/register")
        .send(userData)
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.data.user.email).toBe(userData.email);
      expect(response.body.data.token).toBeDefined();
    });

    it("should login with valid credentials", async () => {
      if (!global.testUtils.isConnected()) return;

      const loginData = {
        email: testUsers[0].email,
        password: "testpassword123", // This is the password used in seeder
      };

      const response = await request(app)
        .post("/api/auth/login")
        .send(loginData)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.user.email).toBe(loginData.email);
      expect(response.body.data.token).toBeDefined();
    });

    it("should get user profile with valid token", async () => {
      if (!global.testUtils.isConnected()) return;

      const response = await request(app)
        .get("/api/auth/me")
        .set("Authorization", `Bearer ${authTokens[0]}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.id).toBe(testUsers[0].id);
      expect(response.body.data.email).toBe(testUsers[0].email);
    });
  });

  describe("Donation Endpoints", () => {
    it("should get all donations", async () => {
      if (!global.testUtils.isConnected()) return;

      const response = await request(app)
        .get("/api/donations")
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(Array.isArray(response.body.data)).toBe(true);
      expect(response.body.data.length).toBeGreaterThan(0);
    });

    it("should get donation by ID", async () => {
      if (!global.testUtils.isConnected()) return;

      const response = await request(app)
        .get(`/api/donations/${testDonations[0].id}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.id).toBe(testDonations[0].id);
      expect(response.body.data.title).toBe(testDonations[0].title);
    });

    it("should create new donation with authentication", async () => {
      if (!global.testUtils.isConnected()) return;

      const donationData = {
        title: "New Test Donation",
        description: "This is a new test donation with enough description text to meet validation requirements.",
        category: "electronics",
        condition: "like-new",
        location: "New Test City",
      };

      const response = await request(app)
        .post("/api/donations")
        .set("Authorization", `Bearer ${authTokens[1]}`) // Use donor token
        .send(donationData)
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.data.title).toBe(donationData.title);
      expect(response.body.data.donorId).toBe(testUsers[1].id);
    });

    it("should update donation by owner", async () => {
      if (!global.testUtils.isConnected()) return;

      const updateData = {
        title: "Updated Donation Title",
        description: "Updated description with enough text to meet validation requirements for the donation.",
      };

      const response = await request(app)
        .put(`/api/donations/${testDonations[0].id}`)
        .set("Authorization", `Bearer ${authTokens[0]}`) // Owner token
        .send(updateData)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.title).toBe(updateData.title);
    });

    it("should delete donation by owner", async () => {
      if (!global.testUtils.isConnected()) return;

      const response = await request(app)
        .delete(`/api/donations/${testDonations[0].id}`)
        .set("Authorization", `Bearer ${authTokens[0]}`) // Owner token
        .expect(200);

      expect(response.body.success).toBe(true);

      // Verify deletion
      const deletedDonation = await models.Donation.findByPk(testDonations[0].id);
      expect(deletedDonation).toBeNull();
    });
  });

  describe("Request Endpoints", () => {
    it("should get all requests", async () => {
      if (!global.testUtils.isConnected()) return;

      const response = await request(app)
        .get("/api/requests")
        .set("Authorization", `Bearer ${authTokens[0]}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(Array.isArray(response.body.data)).toBe(true);
    });

    it("should create new request", async () => {
      if (!global.testUtils.isConnected()) return;

      const requestData = {
        donationId: testDonations[1].id,
        message: "I would like to request this donation for my family.",
      };

      const response = await request(app)
        .post("/api/requests")
        .set("Authorization", `Bearer ${authTokens[2]}`) // Receiver token
        .send(requestData)
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.data.donationId).toBe(requestData.donationId);
      expect(response.body.data.receiverId).toBe(testUsers[2].id);
    });

    it("should update request status by donor", async () => {
      if (!global.testUtils.isConnected()) return;

      const updateData = {
        status: "approved",
      };

      const response = await request(app)
        .put(`/api/requests/${testRequests[0].id}`)
        .set("Authorization", `Bearer ${authTokens[0]}`) // Donor token
        .send(updateData)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.status).toBe(updateData.status);
    });
  });

  describe("User Endpoints", () => {
    it("should get user profile", async () => {
      if (!global.testUtils.isConnected()) return;

      const response = await request(app)
        .get(`/api/users/${testUsers[0].id}`)
        .set("Authorization", `Bearer ${authTokens[0]}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.id).toBe(testUsers[0].id);
      expect(response.body.data.password).toBeUndefined();
    });

    it("should update user profile", async () => {
      if (!global.testUtils.isConnected()) return;

      const updateData = {
        name: "Updated User Name",
        phone: "+9876543210",
        location: "Updated City",
      };

      const response = await request(app)
        .put(`/api/users/${testUsers[0].id}`)
        .set("Authorization", `Bearer ${authTokens[0]}`)
        .send(updateData)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.name).toBe(updateData.name);
      expect(response.body.data.phone).toBe(updateData.phone);
    });
  });

  describe("Error Handling", () => {
    it("should return 401 for protected routes without token", async () => {
      if (!global.testUtils.isConnected()) return;

      await request(app)
        .post("/api/donations")
        .send({
          title: "Test Donation",
          description: "Test description",
          category: "books",
          condition: "good",
          location: "Test City",
        })
        .expect(401);
    });

    it("should return 404 for non-existent resources", async () => {
      if (!global.testUtils.isConnected()) return;

      await request(app)
        .get("/api/donations/99999")
        .expect(404);
    });

    it("should return 400 for invalid data", async () => {
      if (!global.testUtils.isConnected()) return;

      await request(app)
        .post("/api/auth/register")
        .send({
          name: "Test User",
          email: "invalid-email",
          password: "123", // Too short
        })
        .expect(400);
    });
  });

  describe("Pagination and Filtering", () => {
    it("should support pagination for donations", async () => {
      if (!global.testUtils.isConnected()) return;

      const response = await request(app)
        .get("/api/donations?page=1&limit=1")
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.pagination).toBeDefined();
      expect(response.body.pagination.page).toBe(1);
      expect(response.body.pagination.limit).toBe(1);
    });

    it("should support filtering donations by category", async () => {
      if (!global.testUtils.isConnected()) return;

      const response = await request(app)
        .get("/api/donations?category=books")
        .expect(200);

      expect(response.body.success).toBe(true);
      if (response.body.data.length > 0) {
        response.body.data.forEach(donation => {
          expect(donation.category).toBe("books");
        });
      }
    });

    it("should support searching donations by title", async () => {
      if (!global.testUtils.isConnected()) return;

      const response = await request(app)
        .get("/api/donations?search=Test")
        .expect(200);

      expect(response.body.success).toBe(true);
      if (response.body.data.length > 0) {
        response.body.data.forEach(donation => {
          expect(donation.title.toLowerCase()).toContain("test");
        });
      }
    });
  });
});