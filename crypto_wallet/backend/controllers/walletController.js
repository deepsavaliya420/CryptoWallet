const Wallet = require("../models/Wallet");
const User = require("../models/User");
const Transaction = require("../models/Transaction");
const Notification = require("../models/Notification");

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

const generateTransactionId = () => {
  return `TX-${Date.now()}-${Math.random()
    .toString(36)
    .substring(2, 8)
    .toUpperCase()}`;
};

const generateNotificationId = () => {
  return `NT-${Date.now()}-${Math.random()
    .toString(36)
    .substring(2, 8)
    .toUpperCase()}`;
};

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

// ============================================================
// TRANSFER USD FROM CURRENT USER TO ANOTHER WALLET
// ============================================================

const transferUsd = async (req, res) => {
  try {
    const { recipientAddress, amount } = req.body;

    if (!recipientAddress || amount === undefined) {
      return res.status(400).json({
        success: false,
        message: "Recipient wallet address and amount are required"
      });
    }

    const normalizedRecipientAddress =
      recipientAddress.toString().trim();

    const numericAmount = Number(amount);

    if (!normalizedRecipientAddress) {
      return res.status(400).json({
        success: false,
        message: "Recipient wallet address is required"
      });
    }

    if (
      !Number.isFinite(numericAmount) ||
      numericAmount <= 0
    ) {
      return res.status(400).json({
        success: false,
        message: "Amount must be greater than zero"
      });
    }

    // ----------------------------------------------------------
    // FIND SENDER
    // ----------------------------------------------------------

    const sender = await User.findOne({
      userId: req.user.userId
    });

    if (!sender) {
      return res.status(404).json({
        success: false,
        message: "Sender user not found"
      });
    }

    // ----------------------------------------------------------
    // PREVENT SENDING TO OWN WALLET
    // ----------------------------------------------------------

    if (
      sender.walletAddress &&
      sender.walletAddress.trim() ===
        normalizedRecipientAddress
    ) {
      return res.status(400).json({
        success: false,
        message: "You cannot send funds to your own wallet"
      });
    }

    // ----------------------------------------------------------
    // FIND RECIPIENT USER
    // ----------------------------------------------------------

    const recipient = await User.findOne({
      walletAddress: normalizedRecipientAddress
    });

    if (!recipient) {
      return res.status(404).json({
        success: false,
        message: "Recipient wallet address not found"
      });
    }

    // ----------------------------------------------------------
    // FIND BOTH WALLETS
    // ----------------------------------------------------------

    const senderWallet = await Wallet.findOne({
      userId: sender.userId
    });

    const recipientWallet = await Wallet.findOne({
      userId: recipient.userId
    });

    if (!senderWallet) {
      return res.status(404).json({
        success: false,
        message: "Sender wallet not found"
      });
    }

    if (!recipientWallet) {
      return res.status(404).json({
        success: false,
        message: "Recipient wallet not found"
      });
    }

    // ----------------------------------------------------------
    // CHECK SENDER BALANCE
    //
    // Send is based on total USD wallet value, exactly like
    // the existing Flutter WalletService.sendUsd() behavior.
    // ----------------------------------------------------------

    const currencyRates = {
      USD: 1.0,
      USDT: 1.0,
      USDC: 1.0,
      BTC: 0.0000105,
      ETH: 0.00030,
      SOL: 0.00680,
      TRX: 12.0
    };

    const sourceAssets = [
      "USD",
      "ETH",
      "USDT",
      "USDC",
      "SOL",
      "TRX",
      "BTC"
    ];

    const getUsdValue = (asset, balance) => {
      const rate = currencyRates[asset];

      if (!rate) {
        return 0;
      }

      return balance / rate;
    };

    let totalUsd = 0;

    for (const asset of sourceAssets) {
      const balance =
        Number(senderWallet.balances[asset]) || 0;

      if (balance > 0) {
        totalUsd += getUsdValue(
          asset,
          balance
        );
      }
    }

    if (
      numericAmount >
      totalUsd + 0.00000001
    ) {
      return res.status(400).json({
        success: false,
        message:
          `Insufficient wallet balance. Available: $${totalUsd.toFixed(2)}`
      });
    }

    // ----------------------------------------------------------
    // SAVE ORIGINAL BALANCES FOR ROLLBACK
    // ----------------------------------------------------------

    const senderOldBalances = {
      USD: Number(senderWallet.balances.USD) || 0,
      ETH: Number(senderWallet.balances.ETH) || 0,
      USDT: Number(senderWallet.balances.USDT) || 0,
      USDC: Number(senderWallet.balances.USDC) || 0,
      SOL: Number(senderWallet.balances.SOL) || 0,
      TRX: Number(senderWallet.balances.TRX) || 0,
      BTC: Number(senderWallet.balances.BTC) || 0
    };

    const recipientOldUsd =
      Number(recipientWallet.balances.USD) || 0;

    try {
      // --------------------------------------------------------
      // DEDUCT USD VALUE FROM SENDER
      //
      // Same order as existing Flutter WalletService:
      // USD -> ETH -> USDT -> USDC -> SOL -> TRX -> BTC
      // --------------------------------------------------------

      let remainingUsd = numericAmount;

      for (const asset of sourceAssets) {
        if (remainingUsd <= 0.00000001) {
          break;
        }

        const currentBalance =
          Number(senderWallet.balances[asset]) || 0;

        if (currentBalance <= 0) {
          continue;
        }

        const assetUsdValue =
          getUsdValue(
            asset,
            currentBalance
          );

        if (assetUsdValue <= 0) {
          continue;
        }

        const removeUsd =
          Math.min(
            assetUsdValue,
            remainingUsd
          );

        const removeAmount =
          removeUsd *
          currencyRates[asset];

        let newBalance =
          currentBalance - removeAmount;

        if (newBalance < 0) {
          newBalance = 0;
        }

        senderWallet.balances[asset] =
          newBalance;

        remainingUsd -= removeUsd;
      }

      if (remainingUsd > 0.00000001) {
        throw new Error(
          "Unable to deduct the requested amount from sender wallet"
        );
      }

      // --------------------------------------------------------
      // ADD TRANSFERRED VALUE TO RECIPIENT
      //
      // USD transfer is received as USD.
      // --------------------------------------------------------

      recipientWallet.balances.USD =
        recipientOldUsd + numericAmount;

      senderWallet.updatedAt = new Date();
      recipientWallet.updatedAt = new Date();

      await senderWallet.save();
      await recipientWallet.save();

      // --------------------------------------------------------
      // CREATE SENDER TRANSACTION
      // --------------------------------------------------------

      await Transaction.create({
        transactionId: generateTransactionId(),
        userId: sender.userId,
        type: "sent",
        asset: "USD",
        amount: numericAmount,
        from: sender.walletAddress || "",
        to:
          recipient.walletAddress ||
          normalizedRecipientAddress,
        status: "completed",
        network: "TRC-20",
        description: "USD wallet transfer"
      });

      // --------------------------------------------------------
      // CREATE RECIPIENT TRANSACTION
      // --------------------------------------------------------

      const recipientTransaction =
        await Transaction.create({
          transactionId: generateTransactionId(),
          userId: recipient.userId,
          type: "received",
          asset: "USD",
          amount: numericAmount,
          from: sender.walletAddress || "",
          to:
            recipient.walletAddress ||
            normalizedRecipientAddress,
          status: "completed",
          network: "TRC-20",
          description: "USD wallet transfer received"
        });

      // --------------------------------------------------------
      // CREATE RECIPIENT NOTIFICATION
      // --------------------------------------------------------

      await Notification.create({
        notificationId: generateNotificationId(),
        userId: recipient.userId,
        title: "USD Received",
        message:
          `$${numericAmount.toFixed(2)} USD received from ` +
          `${sender.walletAddress || "another wallet"}`,
        type: "transaction",
        referenceId:
          recipientTransaction.transactionId,
        isRead: false
      });

      return res.status(200).json({
        success: true,
        message: "USD transferred successfully",
        amount: numericAmount,
        from: sender.walletAddress || "",
        to:
          recipient.walletAddress ||
          normalizedRecipientAddress
      });
    } catch (error) {
      // --------------------------------------------------------
      // ROLLBACK WALLET BALANCES
      // --------------------------------------------------------

      senderWallet.balances.USD =
        senderOldBalances.USD;

      senderWallet.balances.ETH =
        senderOldBalances.ETH;

      senderWallet.balances.USDT =
        senderOldBalances.USDT;

      senderWallet.balances.USDC =
        senderOldBalances.USDC;

      senderWallet.balances.SOL =
        senderOldBalances.SOL;

      senderWallet.balances.TRX =
        senderOldBalances.TRX;

      senderWallet.balances.BTC =
        senderOldBalances.BTC;

      recipientWallet.balances.USD =
        recipientOldUsd;

      await senderWallet.save();
      await recipientWallet.save();

      throw error;
    }
  } catch (error) {
    console.error("Transfer USD error:", error);

    return res.status(500).json({
      success: false,
      message:
        error.message ||
        "Server error while transferring USD"
    });
  }
};

module.exports = {
  getWallet,
  updateBalance,
  transferUsd
};