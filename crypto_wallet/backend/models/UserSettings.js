const mongoose = require("mongoose");

const userSettingsSchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      required: true,
      unique: true
    },

    notificationsEnabled: {
      type: Boolean,
      default: true
    },

    transactionNotifications: {
      type: Boolean,
      default: true
    },

    securityNotifications: {
      type: Boolean,
      default: true
    },

    biometricEnabled: {
      type: Boolean,
      default: false
    },

    darkMode: {
      type: Boolean,
      default: false
    },

    currency: {
      type: String,
      default: "INR"
    },

    language: {
      type: String,
      default: "English"
    },

    updatedAt: {
      type: Date,
      default: Date.now
    }
  },
  {
    collection: "user_settings"
  }
);

const UserSettings = mongoose.model(
  "UserSettings",
  userSettingsSchema
);

module.exports = UserSettings;