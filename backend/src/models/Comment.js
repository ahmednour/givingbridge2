const { DataTypes } = require("sequelize");
const { sequelize } = require("../config/db");

const Comment = sequelize.define(
  "Comment",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    donationId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: "donations",
        key: "id",
      },
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: "users",
        key: "id",
      },
    },
    parentId: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: "comments",
        key: "id",
      },
    },
    content: {
      type: DataTypes.TEXT,
      allowNull: false,
      validate: {
        notEmpty: true,
      },
    },
  },
  {
    tableName: "comments",
    timestamps: true,
    createdAt: "createdAt",
    updatedAt: "updatedAt",
    indexes: [
      {
        fields: ["donationId"],
      },
      {
        fields: ["userId"],
      },
      {
        fields: ["parentId"],
      },
      {
        fields: ["createdAt"],
      },
    ],
  }
);

// Define associations in a separate function to avoid circular dependencies
Comment.associate = (models) => {
  Comment.belongsTo(models.Donation, {
    foreignKey: "donationId",
    as: "donation",
  });
  Comment.belongsTo(models.User, {
    foreignKey: "userId",
    as: "user",
  });
  Comment.belongsTo(models.Comment, {
    foreignKey: "parentId",
    as: "parent",
  });
  Comment.hasMany(models.Comment, {
    foreignKey: "parentId",
    as: "replies",
  });
};

module.exports = Comment;
