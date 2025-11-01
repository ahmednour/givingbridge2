const User = require("./User");
const Donation = require("./Donation");
const Request = require("./Request");
const Message = require("./Message");

// Initialize associations
const models = {
  User,
  Donation,
  Request,
  Message,
};

// Run association functions for all models that have them
Object.values(models).forEach((model) => {
  if (model.associate) {
    model.associate(models);
  }
});

module.exports = models;
