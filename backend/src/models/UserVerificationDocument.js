const { DataTypes } = require("sequelize");
const { sequelize } = require("../config/db");

const UserVerificationDocument = sequelize.define(
  "UserVerificationDocument",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: "users",
        key: "id",
      },
    },
    documentType: {
      type: DataTypes.ENUM(
        "id_card",
        "passport",
        "driver_license",
        "utility_bill",
        "other"
      ),
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
    tableName: "user_verification_documents",
    timestamps: true,
    createdAt: "createdAt",
    updatedAt: "updatedAt",
    indexes: [
      {
        fields: ["userId"],
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
UserVerificationDocument.associate = (models) => {
  UserVerificationDocument.belongsTo(models.User, {
    foreignKey: "userId",
    as: "user",
  });
  UserVerificationDocument.belongsTo(models.User, {
    foreignKey: "verifiedBy",
    as: "verifier",
  });
};

module.exports = UserVerificationDocument;
