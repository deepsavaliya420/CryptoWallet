const mongoose = require("mongoose");

const p2pOrderSchema = new mongoose.Schema(
  {
    orderId: {
      type: String,
      required: true,
      unique: true
    },

    offerId: {
      type: String,
      required: true
    },

    buyerUserId: {
      type: String,
      required: true
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

    totalAmount: {
      type: Number,
      required: true
    },

    paymentMethod: {
      type: String,
      required: true
    },

    status: {
      type: String,
      enum: [
        "pending",
        "payment_sent",
        "payment_confirmed",
        "completed",
        "cancelled",
        "disputed"
      ],
      default: "pending"
    },

    buyerWalletAddress: {
      type: String,
      default: ""
    },

    sellerWalletAddress: {
      type: String,
      default: ""
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
    collection: "p2p_orders"
  }
);

const P2POrder = mongoose.model("P2POrder", p2pOrderSchema);

module.exports = P2POrder;