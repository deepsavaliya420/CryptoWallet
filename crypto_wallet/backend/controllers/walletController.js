const Wallet = require("../models/Wallet");

const SUPPORTED_ASSETS = [
  "ETH",
  "USDT",
  "SOL",
  "TRX",
  "USD",
  "INR",
  "EUR",
  "GBP",
  "AED",
  "JPY",
  "USDC",
  "BTC"
];

const getWallet = async (req, res) => {
  try {
    const wallet = await Wallet.findOne({
      userId: req.user.userId
    });

    if (!wallet) {
      return res.status(404).json({
        success: false,
        message: "Wallet not found"
      });
    }

    return res.status(200).json({
      success: true,
      wallet
    });
  } catch (error) {
    console.error("Get wallet error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error while fetching wallet"
    });
  }
};

const updateBalance = async (req, res) => {
  try {
    const { asset, amount } = req.body;

    if (!asset || amount === undefined) {
      return res.status(400).json({
        success: false,
        message: "Asset and amount are required"
      });
    }

    const normalizedAsset =
      asset.toString().trim().toUpperCase();

    const numericAmount = Number(amount);

    if (!SUPPORTED_ASSETS.includes(normalizedAsset)) {
      return res.status(400).json({
        success: false,
        message: "Unsupported asset"
      });
    }

    if (
      !Number.isFinite(numericAmount) ||
      numericAmount < 0
    ) {
      return res.status(400).json({
        success: false,
        message: "Amount must be a valid non-negative number"
      });
    }

    const wallet = await Wallet.findOne({
      userId: req.user.userId
    });

    if (!wallet) {
      return res.status(404).json({
        success: false,
        message: "Wallet not found"
      });
    }

    wallet.balances[normalizedAsset] = numericAmount;
    wallet.updatedAt = new Date();

    await wallet.save();

    return res.status(200).json({
      success: true,
      message: "Wallet balance updated successfully",
      wallet
    });
  } catch (error) {
    console.error("Update wallet balance error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error while updating wallet balance"
    });
  }
};

module.exports = {
  getWallet,
  updateBalance
};