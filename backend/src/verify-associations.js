// Simple script to verify that model associations work correctly

console.log("Loading models...");
const models = require("./models");

console.log("Checking if models have associate functions...");
console.log("User.associate:", typeof models.User.associate);
console.log("Donation.associate:", typeof models.Donation.associate);
console.log("Request.associate:", typeof models.Request.associate);

console.log("Done!");
