const mongoose = require("mongoose");

const transactionSchema = new mongoose.Schema(
  {
    transactionId: {
      type: String,
      required: true,
      unique: true
    },

    userId: {
      type: String,
      required: true
    },

    type: {
      type: String,
      enum: [
        "sent",
        "received",
        "p2p_received",
        "swap"
      ],
      required: true
    },

    asset: {
      type: String,
      required: true
    },

    amount: {
      type: Number,
      required: true
    },

    from: {
      type: String,
      default: ""
    },

    to: {
      type: String,
      default: ""
    },

    status: {
      type: String,
      enum: [
        "pending",
        "completed",
        "failed"
      ],
      default: "completed"
    },

    network: {
      type: String,
      default: ""
    },

    description: {
      type: String,
      default: ""
    },

    createdAt: {
      type: Date,
      default: Date.now
    }
  },
  {
    collection: "transactions"
  }
);

const Transaction = mongoose.model(
  "Transaction",
  transactionSchema
);

module.exports = Transaction;