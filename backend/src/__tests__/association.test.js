describe("Model Associations", () => {
  let models;

  // Load models once before all tests
  beforeAll(() => {
    models = require("../models");

    // Call associate functions only once
    Object.values(models).forEach((model) => {
      if (model.associate) {
        model.associate(models);
      }
    });
  });

  it("should have proper associations between models", () => {
    // Check that all models have associate functions
    expect(models.Donation.associate).toBeDefined();
    expect(models.Request.associate).toBeDefined();
    expect(models.User.associate).toBeDefined();
  });

  it("should create proper associations between Donation and Request", () => {
    // Check that Donation has a requests association
    expect(models.Donation.associations.requests).toBeDefined();

    // Check that Request has a donation association
    expect(models.Request.associations.donation).toBeDefined();

    // Check that User has proper associations
    expect(models.User.associations.donations).toBeDefined();
    expect(models.User.associations.receivedRequests).toBeDefined();
    expect(models.User.associations.donatedRequests).toBeDefined();
  });
});
