const mongoose = require("mongoose");

const notificationSchema = new mongoose.Schema(
  {
    notificationId: {
      type: String,
      required: true,
      unique: true
    },

    userId: {
      type: String,
      required: true
    },

    title: {
      type: String,
      required: true
    },

    message: {
      type: String,
      required: true
    },

    type: {
      type: String,
      enum: [
        "transaction",
        "swap",
        "p2p",
        "receive_request",
        "security",
        "system",
        "general"
      ],
      default: "general"
    },

    referenceId: {
      type: String,
      default: ""
    },

    isRead: {
      type: Boolean,
      default: false
    },

    createdAt: {
      type: Date,
      default: Date.now
    }
  },
  {
    collection: "notifications"
  }
);

const Notification = mongoose.model(
  "Notification",
  notificationSchema
);

module.exports = Notification;