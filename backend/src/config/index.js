/**
 * Environment configuration management
 * Validates required environment variables and provides defaults
 */

const requiredEnvVars = [
  "JWT_SECRET",
  "DB_HOST",
  "DB_NAME",
  "DB_USER",
  "DB_PASSWORD",
];

const optionalEnvVars = {
  NODE_ENV: "development",
  PORT: "3000",
  DB_PORT: "3307",
  FRONTEND_URL: "http://localhost:8080",
  LOG_LEVEL: "info",
  RATE_LIMIT_WINDOW_MS: "900000", // 15 minutes
  RATE_LIMIT_MAX_REQUESTS: "100",
  LOGIN_RATE_LIMIT_WINDOW_MS: "900000", // 15 minutes
  LOGIN_RATE_LIMIT_MAX_ATTEMPTS: "5",
  JWT_EXPIRES_IN: "7d",
  BCRYPT_ROUNDS: "12",
  MAX_FILE_SIZE: "10485760", // 10MB
  CORS_ORIGIN: "http://localhost:8080,http://localhost:3000",
};

class Config {
  constructor() {
    this.validateRequiredEnvVars();
    this.setOptionalEnvVars();
  }

  validateRequiredEnvVars() {
    const missing = requiredEnvVars.filter((envVar) => !process.env[envVar]);

    if (missing.length > 0) {
      throw new Error(
        `Missing required environment variables: ${missing.join(", ")}\n` +
          "Please check your .env file or environment configuration."
      );
    }
  }

  setOptionalEnvVars() {
    Object.entries(optionalEnvVars).forEach(([key, defaultValue]) => {
      if (!process.env[key]) {
        process.env[key] = defaultValue;
      }
    });
  }

  get isDevelopment() {
    return process.env.NODE_ENV === "development";
  }

  get isProduction() {
    return process.env.NODE_ENV === "production";
  }

  get isTest() {
    return process.env.NODE_ENV === "test";
  }

  get port() {
    return parseInt(process.env.PORT, 10);
  }

  get jwtSecret() {
    return process.env.JWT_SECRET;
  }

  get jwtExpiresIn() {
    return process.env.JWT_EXPIRES_IN;
  }

  get bcryptRounds() {
    return parseInt(process.env.BCRYPT_ROUNDS, 10);
  }

  get database() {
    return {
      host: process.env.DB_HOST,
      port: parseInt(process.env.DB_PORT, 10),
      name: process.env.DB_NAME,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      url: process.env.DATABASE_URL,
    };
  }

  get cors() {
    const origins = process.env.CORS_ORIGIN.split(",").map((origin) =>
      origin.trim()
    );
    return {
      origin: origins,
      credentials: true,
    };
  }

  get rateLimits() {
    return {
      windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS, 10),
      maxRequests: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS, 10),
      loginWindowMs: parseInt(process.env.LOGIN_RATE_LIMIT_WINDOW_MS, 10),
      loginMaxAttempts: parseInt(process.env.LOGIN_RATE_LIMIT_MAX_ATTEMPTS, 10),
    };
  }

  get frontendUrl() {
    return process.env.FRONTEND_URL;
  }

  get logLevel() {
    return process.env.LOG_LEVEL;
  }

  get maxFileSize() {
    return parseInt(process.env.MAX_FILE_SIZE, 10);
  }

  get security() {
    return {
      helmet: {
        contentSecurityPolicy: this.isProduction ? undefined : false,
        crossOriginEmbedderPolicy: false,
      },
      cors: this.cors,
      rateLimit: this.rateLimits,
    };
  }

  get socket() {
    return {
      cors: this.cors,
      pingTimeout: 60000,
      pingInterval: 25000,
    };
  }

  // Validation helpers
  validateConfig() {
    const errors = [];

    // Validate port
    if (this.port < 1 || this.port > 65535) {
      errors.push("PORT must be between 1 and 65535");
    }

    // Validate database port
    if (this.database.port < 1 || this.database.port > 65535) {
      errors.push("DB_PORT must be between 1 and 65535");
    }

    // Validate bcrypt rounds
    if (this.bcryptRounds < 10 || this.bcryptRounds > 15) {
      errors.push("BCRYPT_ROUNDS must be between 10 and 15");
    }

    // Validate JWT secret length
    if (this.jwtSecret.length < 32) {
      errors.push("JWT_SECRET must be at least 32 characters long");
    }

    // Validate JWT secret is not default
    if (
      this.jwtSecret.includes("CHANGE_THIS") ||
      this.jwtSecret.includes("your-super-secret")
    ) {
      errors.push("JWT_SECRET must be changed from default value");
    }

    // Validate rate limit values
    if (this.rateLimits.maxRequests < 1) {
      errors.push("RATE_LIMIT_MAX_REQUESTS must be at least 1");
    }

    if (this.rateLimits.loginMaxAttempts < 1) {
      errors.push("LOGIN_RATE_LIMIT_MAX_ATTEMPTS must be at least 1");
    }

    // Production-specific validations
    if (this.isProduction) {
      if (this.frontendUrl.startsWith("http://")) {
        errors.push("FRONTEND_URL must use HTTPS in production");
      }

      if (
        this.database.password === "root" ||
        this.database.password === "password"
      ) {
        errors.push(
          "Database password must be changed from default in production"
        );
      }
    }

    if (errors.length > 0) {
      throw new Error(`Configuration validation failed:\n${errors.join("\n")}`);
    }
  }

  // Environment-specific configurations
  getEnvironmentConfig() {
    const baseConfig = {
      port: this.port,
      jwtSecret: this.jwtSecret,
      jwtExpiresIn: this.jwtExpiresIn,
      bcryptRounds: this.bcryptRounds,
      database: this.database,
      cors: this.cors,
      rateLimits: this.rateLimits,
      frontendUrl: this.frontendUrl,
      logLevel: this.logLevel,
      maxFileSize: this.maxFileSize,
      security: this.security,
      socket: this.socket,
    };

    if (this.isDevelopment) {
      return {
        ...baseConfig,
        logLevel: "debug",
        security: {
          ...baseConfig.security,
          helmet: {
            contentSecurityPolicy: false,
            crossOriginEmbedderPolicy: false,
          },
        },
      };
    }

    if (this.isProduction) {
      return {
        ...baseConfig,
        logLevel: "warn",
        security: {
          ...baseConfig.security,
          helmet: {
            contentSecurityPolicy: {
              directives: {
                defaultSrc: ["'self'"],
                styleSrc: ["'self'", "'unsafe-inline'"],
                scriptSrc: ["'self'"],
                imgSrc: ["'self'", "data:", "https:"],
                connectSrc: ["'self'"],
                fontSrc: ["'self'"],
                objectSrc: ["'none'"],
                mediaSrc: ["'self'"],
                frameSrc: ["'none'"],
                upgradeInsecureRequests: [],
              },
            },
            crossOriginEmbedderPolicy: false,
            hsts: {
              maxAge: 31536000,
              includeSubDomains: true,
              preload: true,
            },
            noSniff: true,
            xssFilter: true,
            referrerPolicy: { policy: "strict-origin-when-cross-origin" },
          },
        },
      };
    }

    if (this.isTest) {
      return {
        ...baseConfig,
        logLevel: "error",
        database: {
          ...baseConfig.database,
          name: `${baseConfig.database.name}_test`,
        },
      };
    }

    return baseConfig;
  }
}

// Create singleton instance
const config = new Config();

// Validate configuration
config.validateConfig();

module.exports = config;
