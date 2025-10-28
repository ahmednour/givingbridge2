const User = require("./User");
const Donation = require("./Donation");
const Request = require("./Request");
const Message = require("./Message");
const Notification = require("./Notification");
const Rating = require("./Rating");
const BlockedUser = require("./BlockedUser");
const UserReport = require("./UserReport");
const ActivityLog = require("./ActivityLog");
const NotificationPreference = require("./NotificationPreference");
const UserVerificationDocument = require("./UserVerificationDocument");
const RequestVerificationDocument = require("./RequestVerificationDocument");
const RequestUpdate = require("./RequestUpdate");
const Comment = require("./Comment");
const Share = require("./Share");

// Initialize associations
const models = {
  User,
  Donation,
  Request,
  Message,
  Notification,
  Rating,
  BlockedUser,
  UserReport,
  ActivityLog,
  NotificationPreference,
  UserVerificationDocument,
  RequestVerificationDocument,
  RequestUpdate,
  Comment,
  Share,
};

// Run association functions for all models that have them
Object.values(models).forEach((model) => {
  if (model.associate) {
    model.associate(models);
  }
});

module.exports = models;
