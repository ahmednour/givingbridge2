describe("Model Loading", () => {
  it("should be able to load all models without errors", () => {
    expect(() => {
      const models = require("../models");
    }).not.toThrow();
  });
});
