const Wallet = require("../models/Wallet");

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

    const supportedAssets = [
      "ETH",
      "USDT",
      "SOL",
      "TRX",
      "INR",
      "USD"
    ];

    if (!supportedAssets.includes(asset)) {
      return res.status(400).json({
        success: false,
        message: "Unsupported asset"
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

    wallet.balances[asset] = amount;
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
      message: "Server error while updating wallet"
    });
  }
};

module.exports = {
  getWallet,
  updateBalance
};