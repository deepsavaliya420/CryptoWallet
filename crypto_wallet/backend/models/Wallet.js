const mongoose = require("mongoose");

const walletSchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      required: true,
      unique: true
    },

    balances: {
      ETH: {
        type: Number,
        default: 0
      },

      USDT: {
        type: Number,
        default: 0
      },

      SOL: {
        type: Number,
        default: 0
      },

      TRX: {
        type: Number,
        default: 0
      },

      USD: {
        type: Number,
        default: 0
      },

      INR: {
        type: Number,
        default: 0
      },

      EUR: {
        type: Number,
        default: 0
      },

      GBP: {
        type: Number,
        default: 0
      },

      AED: {
        type: Number,
        default: 0
      },

      JPY: {
        type: Number,
        default: 0
      },

      USDC: {
        type: Number,
        default: 0
      },

      BTC: {
        type: Number,
        default: 0
      }
    },

    walletAddress: {
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
    collection: "wallets"
  }
);

const Wallet = mongoose.model("Wallet", walletSchema);

module.exports = Wallet;