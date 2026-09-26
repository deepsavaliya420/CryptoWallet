const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      required: true,
      unique: true
    },

    fullName: {
      type: String,
      required: true,
      trim: true
    },

    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true
    },

    passwordHash: {
      type: String,
      required: true
    },

    location: {
      type: String,
      default: "India"
    },

    phone: {
      type: String,
      default: ""
    },

    walletAddress: {
      type: String,
      default: ""
    },

    createdAt: {
      type: Date,
      default: Date.now
    }
  },
  {
    collection: "users"
  }
);

const User = mongoose.model("User", userSchema);

module.exports = User;