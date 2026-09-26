const mongoose = require("mongoose");

const p2pOfferSchema = new mongoose.Schema(
  {
    offerId: {
      type: String,
      required: true,
      unique: true
    },

    sellerUserId: {
      type: String,
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

    price: {
      type: Number,
      required: true
    },

    paymentMethod: {
      type: String,
      required: true
    },

    minLimit: {
      type: Number,
      default: 0
    },

    maxLimit: {
      type: Number,
      default: 0
    },

    status: {
      type: String,
      enum: [
        "active",
        "paused",
        "completed",
        "cancelled"
      ],
      default: "active"
    },

    createdAt: {
      type: Date,
      default: Date.now
    },

    updatedAt: {
      type: Date,
      default: Date.now
    }
  },
  {
    collection: "p2p_offers"
  }
);

const P2POffer = mongoose.model(
  "P2POffer",
  p2pOfferSchema
);

module.exports = P2POffer;