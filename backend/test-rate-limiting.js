const fs = require("fs");
const path = require("path");

// Test that our rate limiting implementation files exist and are correctly structured
console.log("Testing Rate Limiting Implementation...");

// Check if rate limiting middleware file exists
const rateLimitingMiddlewarePath = path.join(
  __dirname,
  "src/middleware/rateLimiting.js"
);
if (fs.existsSync(rateLimitingMiddlewarePath)) {
  console.log("✅ Rate limiting middleware file exists");

  // Try to import it
  try {
    const rateLimiting = require("./src/middleware/rateLimiting.js");
    console.log("✅ Rate limiting middleware imported successfully");

    // Check if all expected rate limiters are present
    const expectedLimiters = [
      "generalLimiter",
      "authLimiter",
      "registrationLimiter",
      "loginLimiter",
      "passwordResetLimiter",
      "emailVerificationLimiter",
      "uploadLimiter",
      "heavyOperationLimiter",
    ];
    let allPresent = true;

    for (const limiter of expectedLimiters) {
      if (rateLimiting[limiter]) {
        console.log(`✅ ${limiter} is present`);
      } else {
        console.log(`❌ ${limiter} is missing`);
        allPresent = false;
      }
    }

    if (allPresent) {
      console.log("✅ All rate limiters are present");
    } else {
      console.log("❌ Some rate limiters are missing");
    }
  } catch (error) {
    console.log("❌ Error importing rate limiting middleware:", error.message);
  }
} else {
  console.log("❌ Rate limiting middleware file does not exist");
}

// Check if auth routes have rate limiting applied
const authRoutesPath = path.join(__dirname, "src/routes/auth.js");
if (fs.existsSync(authRoutesPath)) {
  console.log("✅ Auth routes file exists");

  // Read the file content
  const authRoutesContent = fs.readFileSync(authRoutesPath, "utf8");

  // Check for rate limiting middleware usage
  if (authRoutesContent.includes("registrationLimiter")) {
    console.log("✅ Registration rate limiting applied to auth routes");
  } else {
    console.log("❌ Registration rate limiting not applied to auth routes");
  }

  if (authRoutesContent.includes("loginLimiter")) {
    console.log("✅ Login rate limiting applied to auth routes");
  } else {
    console.log("❌ Login rate limiting not applied to auth routes");
  }

  if (authRoutesContent.includes("passwordResetLimiter")) {
    console.log("✅ Password reset rate limiting applied to auth routes");
  } else {
    console.log("❌ Password reset rate limiting not applied to auth routes");
  }

  if (authRoutesContent.includes("emailVerificationLimiter")) {
    console.log("✅ Email verification rate limiting applied to auth routes");
  } else {
    console.log(
      "❌ Email verification rate limiting not applied to auth routes"
    );
  }
} else {
  console.log("❌ Auth routes file does not exist");
}

// Check if donations routes have rate limiting applied
const donationsRoutesPath = path.join(__dirname, "src/routes/donations.js");
if (fs.existsSync(donationsRoutesPath)) {
  console.log("✅ Donations routes file exists");

  // Read the file content
  const donationsRoutesContent = fs.readFileSync(donationsRoutesPath, "utf8");

  // Check for rate limiting middleware usage
  if (donationsRoutesContent.includes("generalLimiter")) {
    console.log("✅ General rate limiting applied to donations routes");
  } else {
    console.log("❌ General rate limiting not applied to donations routes");
  }

  if (donationsRoutesContent.includes("heavyOperationLimiter")) {
    console.log("✅ Heavy operation rate limiting applied to donations routes");
  } else {
    console.log(
      "❌ Heavy operation rate limiting not applied to donations routes"
    );
  }
} else {
  console.log("❌ Donations routes file does not exist");
}

// Check if requests routes have rate limiting applied
const requestsRoutesPath = path.join(__dirname, "src/routes/requests.js");
if (fs.existsSync(requestsRoutesPath)) {
  console.log("✅ Requests routes file exists");

  // Read the file content
  const requestsRoutesContent = fs.readFileSync(requestsRoutesPath, "utf8");

  // Check for rate limiting middleware usage
  if (requestsRoutesContent.includes("generalLimiter")) {
    console.log("✅ General rate limiting applied to requests routes");
  } else {
    console.log("❌ General rate limiting not applied to requests routes");
  }
} else {
  console.log("❌ Requests routes file does not exist");
}

// Check if users routes have rate limiting applied
const usersRoutesPath = path.join(__dirname, "src/routes/users.js");
if (fs.existsSync(usersRoutesPath)) {
  console.log("✅ Users routes file exists");

  // Read the file content
  const usersRoutesContent = fs.readFileSync(usersRoutesPath, "utf8");

  // Check for rate limiting middleware usage
  if (usersRoutesContent.includes("generalLimiter")) {
    console.log("✅ General rate limiting applied to users routes");
  } else {
    console.log("❌ General rate limiting not applied to users routes");
  }

  if (usersRoutesContent.includes("heavyOperationLimiter")) {
    console.log("✅ Heavy operation rate limiting applied to users routes");
  } else {
    console.log("❌ Heavy operation rate limiting not applied to users routes");
  }
} else {
  console.log("❌ Users routes file does not exist");
}

// Check if verification routes have rate limiting applied
const verificationRoutesPath = path.join(
  __dirname,
  "src/routes/verification.js"
);
if (fs.existsSync(verificationRoutesPath)) {
  console.log("✅ Verification routes file exists");

  // Read the file content
  const verificationRoutesContent = fs.readFileSync(
    verificationRoutesPath,
    "utf8"
  );

  // Check for rate limiting middleware usage
  if (verificationRoutesContent.includes("generalLimiter")) {
    console.log("✅ General rate limiting applied to verification routes");
  } else {
    console.log("❌ General rate limiting not applied to verification routes");
  }

  if (verificationRoutesContent.includes("heavyOperationLimiter")) {
    console.log(
      "✅ Heavy operation rate limiting applied to verification routes"
    );
  } else {
    console.log(
      "❌ Heavy operation rate limiting not applied to verification routes"
    );
  }
} else {
  console.log("❌ Verification routes file does not exist");
}

// Check if messages routes have rate limiting applied
const messagesRoutesPath = path.join(__dirname, "src/routes/messages.js");
if (fs.existsSync(messagesRoutesPath)) {
  console.log("✅ Messages routes file exists");

  // Read the file content
  const messagesRoutesContent = fs.readFileSync(messagesRoutesPath, "utf8");

  // Check for rate limiting middleware usage
  if (messagesRoutesContent.includes("generalLimiter")) {
    console.log("✅ General rate limiting applied to messages routes");
  } else {
    console.log("❌ General rate limiting not applied to messages routes");
  }

  if (messagesRoutesContent.includes("heavyOperationLimiter")) {
    console.log("✅ Heavy operation rate limiting applied to messages routes");
  } else {
    console.log(
      "❌ Heavy operation rate limiting not applied to messages routes"
    );
  }
} else {
  console.log("❌ Messages routes file does not exist");
}

// Check if notifications routes have rate limiting applied
const notificationsRoutesPath = path.join(
  __dirname,
  "src/routes/notifications.js"
);
if (fs.existsSync(notificationsRoutesPath)) {
  console.log("✅ Notifications routes file exists");

  // Read the file content
  const notificationsRoutesContent = fs.readFileSync(
    notificationsRoutesPath,
    "utf8"
  );

  // Check for rate limiting middleware usage
  if (notificationsRoutesContent.includes("generalLimiter")) {
    console.log("✅ General rate limiting applied to notifications routes");
  } else {
    console.log("❌ General rate limiting not applied to notifications routes");
  }
} else {
  console.log("❌ Notifications routes file does not exist");
}

// Check if search routes have rate limiting applied
const searchRoutesPath = path.join(__dirname, "src/routes/search.js");
if (fs.existsSync(searchRoutesPath)) {
  console.log("✅ Search routes file exists");

  // Read the file content
  const searchRoutesContent = fs.readFileSync(searchRoutesPath, "utf8");

  // Check for rate limiting middleware usage
  if (searchRoutesContent.includes("generalLimiter")) {
    console.log("✅ General rate limiting applied to search routes");
  } else {
    console.log("❌ General rate limiting not applied to search routes");
  }
} else {
  console.log("❌ Search routes file does not exist");
}

// Check if analytics routes have rate limiting applied
const analyticsRoutesPath = path.join(__dirname, "src/routes/analytics.js");
if (fs.existsSync(analyticsRoutesPath)) {
  console.log("✅ Analytics routes file exists");

  // Read the file content
  const analyticsRoutesContent = fs.readFileSync(analyticsRoutesPath, "utf8");

  // Check for rate limiting middleware usage
  if (analyticsRoutesContent.includes("heavyOperationLimiter")) {
    console.log("✅ Heavy operation rate limiting applied to analytics routes");
  } else {
    console.log(
      "❌ Heavy operation rate limiting not applied to analytics routes"
    );
  }
} else {
  console.log("❌ Analytics routes file does not exist");
}

// Check if documentation files exist
const rateLimitingDocumentationPath = path.join(
  __dirname,
  "RATE_LIMITING_IMPLEMENTATION.md"
);
if (fs.existsSync(rateLimitingDocumentationPath)) {
  console.log("✅ Rate limiting documentation file exists");
} else {
  console.log("❌ Rate limiting documentation file does not exist");
}

const readmePath = path.join(__dirname, "README.md");
if (fs.existsSync(readmePath)) {
  console.log("✅ README file exists");

  // Read the file content
  const readmeContent = fs.readFileSync(readmePath, "utf8");

  // Check for rate limiting documentation
  if (readmeContent.includes("Rate limiting")) {
    console.log("✅ Rate limiting documented in README");
  } else {
    console.log("❌ Rate limiting not documented in README");
  }
} else {
  console.log("❌ README file does not exist");
}

console.log("Rate Limiting Implementation Test Complete");
