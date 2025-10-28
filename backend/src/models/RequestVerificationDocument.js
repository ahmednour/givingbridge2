const { DataTypes } = require("sequelize");
const { sequelize } = require("../config/db");

const RequestVerificationDocument = sequelize.define(
  "RequestVerificationDocument",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    requestId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: "requests",
        key: "id",
      },
    },
    documentType: {
      type: DataTypes.ENUM("proof_of_need", "receipt", "photo", "other"),
      allowNull: false,
    },
    documentUrl: {
      type: DataTypes.STRING(500),
      allowNull: false,
    },
    documentName: {
      type: DataTypes.STRING(255),
      allowNull: false,
    },
    documentSize: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    isVerified: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },
    verifiedBy: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: "users",
        key: "id",
      },
    },
    verifiedAt: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    rejectionReason: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
  },
  {
    tableName: "request_verification_documents",
    timestamps: true,
    createdAt: "createdAt",
    updatedAt: "updatedAt",
    indexes: [
      {
        fields: ["requestId"],
      },
      {
        fields: ["documentType"],
      },
      {
        fields: ["isVerified"],
      },
      {
        fields: ["verifiedBy"],
      },
    ],
  }
);

// Define associations in a separate function to avoid circular dependencies
RequestVerificationDocument.associate = (models) => {
  RequestVerificationDocument.belongsTo(models.Request, {
    foreignKey: "requestId",
    as: "request",
  });
  RequestVerificationDocument.belongsTo(models.User, {
    foreignKey: "verifiedBy",
    as: "verifier",
  });
};

module.exports = RequestVerificationDocument;
