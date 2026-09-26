const mongoose = require("mongoose");

const receiveRequestSchema =
  new mongoose.Schema(
    {
      requestId: {
        type: String,
        required: true,
        unique: true
      },

      userId: {
        type: String,
        required: true
      },

      requestedFrom: {
        type: String,
        default: ""
      },

      requestedTo: {
        type: String,
        default: ""
      },

      asset: {
        type: String,
        required: true
      },

      amount: {
        type: Number,
        required: true
      },

      walletAddress: {
        type: String,
        default: ""
      },

      network: {
        type: String,
        default: ""
      },

      status: {
        type: String,
        enum: [
          "pending",
          "completed",
          "cancelled"
        ],
        default: "pending"
      },

      createdAt: {
        type: Date,
        default: Date.now
      },

      completedAt: {
        type: Date,
        default: null
      }
    },
    {
      collection: "receive_requests"
    }
  );

const ReceiveRequest =
  mongoose.model(
    "ReceiveRequest",
    receiveRequestSchema
  );

module.exports = ReceiveRequest;