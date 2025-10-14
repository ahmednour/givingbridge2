const request = require("supertest");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const app = require("../server");
const User = require("../models/User");
const { sequelize } = require("../config/db");

describe("Authentication Controller", () => {
  beforeEach(async () => {
    // Clear users table
    await User.destroy({ where: {}, force: true });
  });

  describe("POST /api/auth/register", () => {
    it("should register a new user successfully", async () => {
      const userData = {
        name: "Test User",
        email: "test@example.com",
        password: "password123",
        role: "donor",
        phone: "+1234567890",
        location: "Test City",
      };

      const response = await request(app)
        .post("/api/auth/register")
        .send(userData)
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.data.user).toMatchObject({
        name: userData.name,
        email: userData.email,
        role: userData.role,
        phone: userData.phone,
        location: userData.location,
      });
      expect(response.body.data.user.password).toBeUndefined();
      expect(response.body.data.token).toBeDefined();

      // Verify user was created in database
      const user = await User.findOne({ where: { email: userData.email } });
      expect(user).toBeTruthy();
      expect(user.name).toBe(userData.name);
      expect(user.role).toBe(userData.role);
    });

    it("should hash password before storing", async () => {
      const userData = {
        name: "Test User",
        email: "test@example.com",
        password: "password123",
        role: "donor",
      };

      await request(app).post("/api/auth/register").send(userData).expect(201);

      const user = await User.findOne({ where: { email: userData.email } });
      expect(user.password).not.toBe(userData.password);
      expect(bcrypt.compareSync(userData.password, user.password)).toBe(true);
    });

    it("should reject registration with duplicate email", async () => {
      const userData = {
        name: "Test User",
        email: "test@example.com",
        password: "password123",
        role: "donor",
      };

      // Create first user
      await request(app).post("/api/auth/register").send(userData).expect(201);

      // Try to create second user with same email
      const response = await request(app)
        .post("/api/auth/register")
        .send(userData)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("already exists");
    });

    it("should validate required fields", async () => {
      const response = await request(app)
        .post("/api/auth/register")
        .send({})
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.errors).toBeDefined();
    });

    it("should validate email format", async () => {
      const userData = {
        name: "Test User",
        email: "invalid-email",
        password: "password123",
        role: "donor",
      };

      const response = await request(app)
        .post("/api/auth/register")
        .send(userData)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.errors).toBeDefined();
    });

    it("should validate password length", async () => {
      const userData = {
        name: "Test User",
        email: "test@example.com",
        password: "123",
        role: "donor",
      };

      const response = await request(app)
        .post("/api/auth/register")
        .send(userData)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.errors).toBeDefined();
    });

    it("should validate role enum", async () => {
      const userData = {
        name: "Test User",
        email: "test@example.com",
        password: "password123",
        role: "invalid-role",
      };

      const response = await request(app)
        .post("/api/auth/register")
        .send(userData)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.errors).toBeDefined();
    });
  });

  describe("POST /api/auth/login", () => {
    beforeEach(async () => {
      // Create a test user
      const hashedPassword = await bcrypt.hash("password123", 12);
      await User.create({
        name: "Test User",
        email: "test@example.com",
        password: hashedPassword,
        role: "donor",
      });
    });

    it("should login with valid credentials", async () => {
      const loginData = {
        email: "test@example.com",
        password: "password123",
      };

      const response = await request(app)
        .post("/api/auth/login")
        .send(loginData)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.user).toMatchObject({
        name: "Test User",
        email: "test@example.com",
        role: "donor",
      });
      expect(response.body.data.user.password).toBeUndefined();
      expect(response.body.data.token).toBeDefined();

      // Verify token is valid
      const decoded = jwt.verify(
        response.body.data.token,
        process.env.JWT_SECRET
      );
      expect(decoded.userId).toBeDefined();
    });

    it("should reject login with invalid email", async () => {
      const loginData = {
        email: "nonexistent@example.com",
        password: "password123",
      };

      const response = await request(app)
        .post("/api/auth/login")
        .send(loginData)
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Invalid credentials");
    });

    it("should reject login with invalid password", async () => {
      const loginData = {
        email: "test@example.com",
        password: "wrongpassword",
      };

      const response = await request(app)
        .post("/api/auth/login")
        .send(loginData)
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Invalid credentials");
    });

    it("should validate required fields", async () => {
      const response = await request(app)
        .post("/api/auth/login")
        .send({})
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.errors).toBeDefined();
    });
  });

  describe("GET /api/auth/me", () => {
    let authToken;
    let testUser;

    beforeEach(async () => {
      // Create a test user
      const hashedPassword = await bcrypt.hash("password123", 12);
      testUser = await User.create({
        name: "Test User",
        email: "test@example.com",
        password: hashedPassword,
        role: "donor",
      });

      // Generate auth token
      authToken = jwt.sign(
        { userId: testUser.id, email: testUser.email },
        process.env.JWT_SECRET,
        { expiresIn: "7d" }
      );
    });

    it("should get user profile with valid token", async () => {
      const response = await request(app)
        .get("/api/auth/me")
        .set("Authorization", `Bearer ${authToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toMatchObject({
        id: testUser.id,
        name: testUser.name,
        email: testUser.email,
        role: testUser.role,
      });
      expect(response.body.data.password).toBeUndefined();
    });

    it("should reject request without token", async () => {
      const response = await request(app).get("/api/auth/me").expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Access denied");
    });

    it("should reject request with invalid token", async () => {
      const response = await request(app)
        .get("/api/auth/me")
        .set("Authorization", "Bearer invalid-token")
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Invalid token");
    });

    it("should reject request with expired token", async () => {
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
  });

  describe("POST /api/auth/logout", () => {
    let authToken;

    beforeEach(async () => {
      // Create a test user
      const hashedPassword = await bcrypt.hash("password123", 12);
      const testUser = await User.create({
        name: "Test User",
        email: "test@example.com",
        password: hashedPassword,
        role: "donor",
      });

      // Generate auth token
      authToken = jwt.sign(
        { userId: testUser.id, email: testUser.email },
        process.env.JWT_SECRET,
        { expiresIn: "7d" }
      );
    });

    it("should logout successfully", async () => {
      const response = await request(app)
        .post("/api/auth/logout")
        .set("Authorization", `Bearer ${authToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.message).toContain("Logged out successfully");
    });

    it("should reject logout without token", async () => {
      const response = await request(app).post("/api/auth/logout").expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("Access denied");
    });
  });
});
