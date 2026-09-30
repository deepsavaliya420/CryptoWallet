const mongoose = require("mongoose");

const swapSchema = new mongoose.Schema(
  {
    swapId: {
      type: String,
      required: true,
      unique: true
    },

    userId: {
      type: String,
      required: true
    },

    fromAsset: {
      type: String,
      required: true
    },

    fromNetwork: {
      type: String,
      required: true
    },

    toAsset: {
      type: String,
      required: true
    },

    toNetwork: {
      type: String,
      required: true
    },

    fromAmount: {
      type: Number,
      required: true
    },

    toAmount: {
      type: Number,
      required: true
    },

    rate: {
      type: Number,
      default: 0
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

    createdAt: {
      type: Date,
      default: Date.now
    }
  },
  {
    collection: "swaps"
  }
);

const Swap = mongoose.model("Swap", swapSchema);

module.exports = Swap;