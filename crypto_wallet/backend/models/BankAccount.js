const mongoose = require("mongoose");

const bankAccountSchema = new mongoose.Schema(
  {
    bankAccountId: {
      type: String,
      required: true,
      unique: true
    },

    userId: {
      type: String,
      required: true
    },

    accountHolderName: {
      type: String,
      required: true,
      trim: true
    },

    bankName: {
      type: String,
      required: true,
      trim: true
    },

    accountNumber: {
      type: String,
      required: true
    },

    ifscCode: {
      type: String,
      required: true,
      trim: true,
      uppercase: true
    },

    branchName: {
      type: String,
      default: ""
    },

    accountType: {
      type: String,
      enum: ["Savings", "Current"],
      default: "Savings"
    },

    isPrimary: {
      type: Boolean,
      default: false
    },

    createdAt: {
      type: Date,
      default: Date.now
    }
  },
  {
    collection: "bank_accounts"
  }
);

const BankAccount = mongoose.model(
  "BankAccount",
  bankAccountSchema
);

module.exports = BankAccount;