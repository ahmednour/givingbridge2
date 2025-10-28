const models = require("../models");
const TestDataSeeder = require("./test-data-seeder");

describe("Verification Document Models", () => {
  let seeder;
  let testUsers;
  let testRequests;

  beforeAll(() => {
    seeder = new TestDataSeeder();
  });

  beforeEach(async () => {
    if (!global.testUtils.isConnected()) {
      console.log("🟡 Skipping verification document tests - no database connection");
      return;
    }

    // Seed basic test data
    testUsers = await seeder.seedTestUsers(3);
    const donations = await seeder.seedTestDonations(testUsers, 2);
    testRequests = await seeder.seedTestRequests(testUsers, donations, 2);
  });

  afterEach(async () => {
    if (!global.testUtils.isConnected()) return;
    await seeder.cleanupTestData();
  });

  describe("UserVerificationDocument Model", () => {
    it("should create user verification document with valid data", async () => {
      if (!global.testUtils.isConnected()) return;

      const docData = {
        userId: testUsers[0].id,
        documentType: "id_card",
        documentUrl: "https://example.com/id-card.pdf",
        documentName: "id-card.pdf",
        documentSize: 1024,
        isVerified: false,
      };

      const doc = await models.UserVerificationDocument.create(docData);

      expect(doc.id).toBeDefined();
      expect(doc.userId).toBe(docData.userId);
      expect(doc.documentType).toBe(docData.documentType);
      expect(doc.documentUrl).toBe(docData.documentUrl);
      expect(doc.documentName).toBe(docData.documentName);
      expect(doc.documentSize).toBe(docData.documentSize);
      expect(doc.isVerified).toBe(docData.isVerified);
      expect(doc.createdAt).toBeDefined();
      expect(doc.updatedAt).toBeDefined();
    });

    it("should validate required fields", async () => {
      if (!global.testUtils.isConnected()) return;

      await expect(models.UserVerificationDocument.create({})).rejects.toThrow();
    });

    it("should validate documentType enum", async () => {
      if (!global.testUtils.isConnected()) return;

      const docData = {
        userId: testUsers[0].id,
        documentType: "invalid_type",
        documentUrl: "https://example.com/doc.pdf",
        documentName: "doc.pdf",
      };

      await expect(models.UserVerificationDocument.create(docData)).rejects.toThrow();
    });

    it("should set default values correctly", async () => {
      if (!global.testUtils.isConnected()) return;

      const docData = {
        userId: testUsers[0].id,
        documentType: "passport",
        documentUrl: "https://example.com/passport.pdf",
        documentName: "passport.pdf",
      };

      const doc = await models.UserVerificationDocument.create(docData);
      expect(doc.isVerified).toBe(false);
      expect(doc.verifiedBy).toBeNull();
      expect(doc.verifiedAt).toBeNull();
    });

    it("should maintain association with User", async () => {
      if (!global.testUtils.isConnected()) return;

      const docData = {
        userId: testUsers[0].id,
        documentType: "driver_license",
        documentUrl: "https://example.com/license.pdf",
        documentName: "license.pdf",
      };

      const doc = await models.UserVerificationDocument.create(docData);
      const docWithUser = await models.UserVerificationDocument.findByPk(doc.id, {
        include: [{ model: models.User, as: "user" }],
      });

      expect(docWithUser.user).toBeDefined();
      expect(docWithUser.user.id).toBe(testUsers[0].id);
    });

    it("should handle verification workflow", async () => {
      if (!global.testUtils.isConnected()) return;

      const doc = await models.UserVerificationDocument.create({
        userId: testUsers[1].id,
        documentType: "utility_bill",
        documentUrl: "https://example.com/bill.pdf",
        documentName: "utility-bill.pdf",
        isVerified: false,
      });

      // Verify the document
      const verificationDate = new Date();
      await doc.update({
        isVerified: true,
        verifiedBy: testUsers[0].id, // Admin user
        verifiedAt: verificationDate,
      });

      expect(doc.isVerified).toBe(true);
      expect(doc.verifiedBy).toBe(testUsers[0].id);
      expect(doc.verifiedAt).toEqual(verificationDate);
    });

    it("should handle rejection with reason", async () => {
      if (!global.testUtils.isConnected()) return;

      const doc = await models.UserVerificationDocument.create({
        userId: testUsers[1].id,
        documentType: "id_card",
        documentUrl: "https://example.com/id.pdf",
        documentName: "id-card.pdf",
      });

      await doc.update({
        isVerified: false,
        rejectionReason: "Document is not clear enough",
        verifiedBy: testUsers[0].id,
        verifiedAt: new Date(),
      });

      expect(doc.isVerified).toBe(false);
      expect(doc.rejectionReason).toBe("Document is not clear enough");
    });
  });

  describe("RequestVerificationDocument Model", () => {
    it("should create request verification document with valid data", async () => {
      if (!global.testUtils.isConnected()) return;

      const docData = {
        requestId: testRequests[0].id,
        documentType: "proof_of_need",
        documentUrl: "https://example.com/proof.pdf",
        documentName: "proof-of-need.pdf",
        documentSize: 2048,
        isVerified: false,
      };

      const doc = await models.RequestVerificationDocument.create(docData);

      expect(doc.id).toBeDefined();
      expect(doc.requestId).toBe(docData.requestId);
      expect(doc.documentType).toBe(docData.documentType);
      expect(doc.documentUrl).toBe(docData.documentUrl);
      expect(doc.documentName).toBe(docData.documentName);
      expect(doc.documentSize).toBe(docData.documentSize);
      expect(doc.isVerified).toBe(docData.isVerified);
      expect(doc.createdAt).toBeDefined();
      expect(doc.updatedAt).toBeDefined();
    });

    it("should validate required fields", async () => {
      if (!global.testUtils.isConnected()) return;

      await expect(models.RequestVerificationDocument.create({})).rejects.toThrow();
    });

    it("should validate documentType enum", async () => {
      if (!global.testUtils.isConnected()) return;

      const docData = {
        requestId: testRequests[0].id,
        documentType: "invalid_type",
        documentUrl: "https://example.com/doc.pdf",
        documentName: "doc.pdf",
      };

      await expect(models.RequestVerificationDocument.create(docData)).rejects.toThrow();
    });

    it("should maintain association with Request", async () => {
      if (!global.testUtils.isConnected()) return;

      const docData = {
        requestId: testRequests[0].id,
        documentType: "receipt",
        documentUrl: "https://example.com/receipt.pdf",
        documentName: "receipt.pdf",
      };

      const doc = await models.RequestVerificationDocument.create(docData);
      const docWithRequest = await models.RequestVerificationDocument.findByPk(doc.id, {
        include: [{ model: models.Request, as: "request" }],
      });

      expect(docWithRequest.request).toBeDefined();
      expect(docWithRequest.request.id).toBe(testRequests[0].id);
    });

    it("should handle verification by admin", async () => {
      if (!global.testUtils.isConnected()) return;

      const doc = await models.RequestVerificationDocument.create({
        requestId: testRequests[0].id,
        documentType: "photo",
        documentUrl: "https://example.com/photo.jpg",
        documentName: "evidence-photo.jpg",
      });

      await doc.update({
        isVerified: true,
        verifiedBy: testUsers[0].id, // Admin user
        verifiedAt: new Date(),
      });

      expect(doc.isVerified).toBe(true);
      expect(doc.verifiedBy).toBe(testUsers[0].id);
    });

    it("should cascade delete when request is deleted", async () => {
      if (!global.testUtils.isConnected()) return;

      const doc = await models.RequestVerificationDocument.create({
        requestId: testRequests[0].id,
        documentType: "other",
        documentUrl: "https://example.com/other.pdf",
        documentName: "other-doc.pdf",
      });

      await testRequests[0].destroy();

      const deletedDoc = await models.RequestVerificationDocument.findByPk(doc.id);
      expect(deletedDoc).toBeNull();
    });
  });

  describe("Verification Document Associations", () => {
    it("should load user verification documents through User association", async () => {
      if (!global.testUtils.isConnected()) return;

      // Create multiple documents for a user
      await models.UserVerificationDocument.create({
        userId: testUsers[0].id,
        documentType: "id_card",
        documentUrl: "https://example.com/id.pdf",
        documentName: "id-card.pdf",
      });

      await models.UserVerificationDocument.create({
        userId: testUsers[0].id,
        documentType: "passport",
        documentUrl: "https://example.com/passport.pdf",
        documentName: "passport.pdf",
      });

      const userWithDocs = await models.User.findByPk(testUsers[0].id, {
        include: [{ model: models.UserVerificationDocument, as: "verificationDocuments" }],
      });

      expect(userWithDocs.verificationDocuments).toBeDefined();
      expect(userWithDocs.verificationDocuments.length).toBe(2);
    });

    it("should load request verification documents through Request association", async () => {
      if (!global.testUtils.isConnected()) return;

      // Create multiple documents for a request
      await models.RequestVerificationDocument.create({
        requestId: testRequests[0].id,
        documentType: "proof_of_need",
        documentUrl: "https://example.com/proof.pdf",
        documentName: "proof.pdf",
      });

      await models.RequestVerificationDocument.create({
        requestId: testRequests[0].id,
        documentType: "receipt",
        documentUrl: "https://example.com/receipt.pdf",
        documentName: "receipt.pdf",
      });

      const requestWithDocs = await models.Request.findByPk(testRequests[0].id, {
        include: [{ model: models.RequestVerificationDocument, as: "verificationDocuments" }],
      });

      expect(requestWithDocs.verificationDocuments).toBeDefined();
      expect(requestWithDocs.verificationDocuments.length).toBe(2);
    });

    it("should load verifier information through User association", async () => {
      if (!global.testUtils.isConnected()) return;

      const doc = await models.UserVerificationDocument.create({
        userId: testUsers[1].id,
        documentType: "id_card",
        documentUrl: "https://example.com/id.pdf",
        documentName: "id-card.pdf",
        isVerified: true,
        verifiedBy: testUsers[0].id,
        verifiedAt: new Date(),
      });

      const docWithVerifier = await models.UserVerificationDocument.findByPk(doc.id, {
        include: [
          { model: models.User, as: "user" },
          { model: models.User, as: "verifier" },
        ],
      });

      expect(docWithVerifier.user).toBeDefined();
      expect(docWithVerifier.user.id).toBe(testUsers[1].id);
      expect(docWithVerifier.verifier).toBeDefined();
      expect(docWithVerifier.verifier.id).toBe(testUsers[0].id);
    });
  });
});