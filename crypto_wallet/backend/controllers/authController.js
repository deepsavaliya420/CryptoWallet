const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

const User = require("../models/User");
const Wallet = require("../models/Wallet");

const generateUserId = () => {
  return `CV-${Date.now()}`;
};

const generateWalletAddress = () => {
  return `CW-${Date.now()}-${Math.random()
    .toString(36)
    .substring(2, 10)
    .toUpperCase()}`;
};

const register = async (req, res) => {
  try {
    const {
      fullName,
      email,
      password,
      location,
      phone
    } = req.body;

    if (!fullName || !email || !password) {
      return res.status(400).json({
        success: false,
        message: "Full name, email and password are required"
      });
    }

    const existingUser = await User.findOne({
      email: email.toLowerCase()
    });

    if (existingUser) {
      return res.status(409).json({
        success: false,
        message: "Email already registered"
      });
    }

    const passwordHash = await bcrypt.hash(password, 10);

    const userId = generateUserId();
    const walletAddress = generateWalletAddress();

    const user = await User.create({
      userId,
      fullName,
      email: email.toLowerCase(),
      passwordHash,
      location: location || "India",
      phone: phone || "",
      walletAddress
    });

    await Wallet.create({
      userId,
      walletAddress,
      balances: {
        ETH: 0.82,
        USDT: 250,
        SOL: 1.50,
        TRX: 12,
        INR: 0,
        USD: 0
      }
    });

    const token = jwt.sign(
      {
        userId: user.userId,
        email: user.email
      },
      process.env.JWT_SECRET,
      {
        expiresIn: "7d"
      }
    );

    return res.status(201).json({
      success: true,
      message: "Registration successful",
      token,
      user: {
        userId: user.userId,
        fullName: user.fullName,
        email: user.email,
        location: user.location,
        phone: user.phone,
        walletAddress: user.walletAddress
      }
    });
  } catch (error) {
    console.error("Register error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error during registration"
    });
  }
};

const login = async (req, res) => {
  try {
    const {
      email,
      password
    } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Email and password are required"
      });
    }

    const user = await User.findOne({
      email: email.toLowerCase()
    });

    if (!user) {
      return res.status(401).json({
        success: false,
        message: "Invalid email or password"
      });
    }

    const passwordMatch = await bcrypt.compare(
      password,
      user.passwordHash
    );

    if (!passwordMatch) {
      return res.status(401).json({
        success: false,
        message: "Invalid email or password"
      });
    }

    const token = jwt.sign(
      {
        userId: user.userId,
        email: user.email
      },
      process.env.JWT_SECRET,
      {
        expiresIn: "7d"
      }
    );

    return res.status(200).json({
      success: true,
      message: "Login successful",
      token,
      user: {
        userId: user.userId,
        fullName: user.fullName,
        email: user.email,
        location: user.location,
        phone: user.phone,
        walletAddress: user.walletAddress
      }
    });
  } catch (error) {
    console.error("Login error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error during login"
    });
  }
};

module.exports = {
  register,
  login
};