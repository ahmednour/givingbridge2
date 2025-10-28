describe("Test Infrastructure", () => {
  it("should have test utilities available", () => {
    expect(global.testUtils).toBeDefined();
    expect(typeof global.testUtils.isConnected).toBe("function");
    expect(typeof global.testUtils.getSeeder).toBe("function");
    expect(typeof global.testUtils.getMigrationRunner).toBe("function");
    expect(typeof global.testUtils.getSequelize).toBe("function");
  });

  it("should handle database connection status", () => {
    const isConnected = global.testUtils.isConnected();
    expect(typeof isConnected).toBe("boolean");
    
    if (isConnected) {
      console.log("✅ Database connection available for tests");
    } else {
      console.log("🟡 Tests running without database connection");
    }
  });

  it("should have seeder available", () => {
    const seeder = global.testUtils.getSeeder();
    if (global.testUtils.isConnected()) {
      expect(seeder).toBeDefined();
      expect(typeof seeder.seedTestUsers).toBe("function");
      expect(typeof seeder.cleanupTestData).toBe("function");
    } else {
      // Seeder might be null if no database connection
      console.log("🟡 Seeder not available without database connection");
    }
  });

  it("should have migration runner available", () => {
    const migrationRunner = global.testUtils.getMigrationRunner();
    if (global.testUtils.isConnected()) {
      expect(migrationRunner).toBeDefined();
      expect(typeof migrationRunner.runMigrations).toBe("function");
    } else {
      console.log("🟡 Migration runner not available without database connection");
    }
  });

  it("should load all models correctly", () => {
    const models = require("../models");
    
    // Check that all expected models are loaded
    expect(models.User).toBeDefined();
    expect(models.Donation).toBeDefined();
    expect(models.Request).toBeDefined();
    expect(models.Message).toBeDefined();
    expect(models.UserVerificationDocument).toBeDefined();
    expect(models.RequestVerificationDocument).toBeDefined();
    expect(models.RequestUpdate).toBeDefined();
    expect(models.Comment).toBeDefined();
    expect(models.Share).toBeDefined();
  });

  it("should have proper model associations defined", () => {
    const models = require("../models");
    
    // Check that models have associate functions
    expect(typeof models.User.associate).toBe("function");
    expect(typeof models.Donation.associate).toBe("function");
    expect(typeof models.Request.associate).toBe("function");
    expect(typeof models.UserVerificationDocument.associate).toBe("function");
    expect(typeof models.RequestVerificationDocument.associate).toBe("function");
  });
});