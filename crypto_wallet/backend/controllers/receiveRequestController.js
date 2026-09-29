const ReceiveRequest = require("../models/ReceiveRequest");
const Notification = require("../models/Notification");
const Wallet = require("../models/Wallet");
const User = require("../models/User");

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

const generateRequestId = () => {
  return `RR-${Date.now()}-${Math.random()
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

// ============================================================
// GET RECEIVE REQUESTS
// ============================================================

const getReceiveRequests = async (req, res) => {
  try {
    const receiveRequests =
      await ReceiveRequest.find({
        userId: req.user.userId
      }).sort({
        createdAt: -1
      });

    return res.status(200).json({
      success: true,
      receiveRequests
    });
  } catch (error) {
    console.error(
      "Get receive requests error:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "Server error while fetching receive requests"
    });
  }
};

// ============================================================
// CREATE RECEIVE REQUEST
// ============================================================

const createReceiveRequest = async (req, res) => {
  try {
    const {
      requestedFrom,
      requestedTo,
      asset,
      amount,
      walletAddress,
      network
    } = req.body;

    if (!asset || amount === undefined) {
      return res.status(400).json({
        success: false,
        message: "Asset and amount are required"
      });
    }

    const numericAmount = Number(amount);

    if (
      !Number.isFinite(numericAmount) ||
      numericAmount <= 0
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Amount must be greater than zero"
      });
    }

    const normalizedAsset =
      asset.toString().trim().toUpperCase();

    if (!SUPPORTED_ASSETS.includes(normalizedAsset)) {
      return res.status(400).json({
        success: false,
        message: "Unsupported asset"
      });
    }

    const targetWalletAddress =
      (
        requestedFrom ||
        walletAddress ||
        ""
      )
        .toString()
        .trim();

    const requesterWalletAddress =
      (
        requestedTo ||
        ""
      )
        .toString()
        .trim();

    if (!targetWalletAddress) {
      return res.status(400).json({
        success: false,
        message:
          "Sender wallet address is required"
      });
    }

    if (!requesterWalletAddress) {
      return res.status(400).json({
        success: false,
        message:
          "Your wallet address is required"
      });
    }

    // Find the user who owns the wallet address
    const receiver = await User.findOne({
      walletAddress: targetWalletAddress
    });

    if (!receiver) {
      return res.status(404).json({
        success: false,
        message:
          "Wallet address does not belong to any user"
      });
    }

    // Prevent requesting money from yourself
    if (receiver.userId === req.user.userId) {
      return res.status(400).json({
        success: false,
        message:
          "You cannot create a receive request for your own wallet"
      });
    }

    const receiveRequest =
      await ReceiveRequest.create({
        requestId: generateRequestId(),

        // User who wants to receive money
        userId: req.user.userId,

        // User whose balance will be deducted
        receiverUserId: receiver.userId,

        requestedFrom:
          targetWalletAddress,

        requestedTo:
          requesterWalletAddress,

        asset:
          normalizedAsset,

        amount:
          numericAmount,

        walletAddress:
          requesterWalletAddress,

        network:
          network || "",

        status:
          "pending"
      });

    // Notify the person whose balance will be deducted
    await Notification.create({
      notificationId:
        generateNotificationId(),

      userId:
        receiver.userId,

      title:
        "New Receive Request",

      message:
        `${numericAmount} ${normalizedAsset} has been requested from you.`,

      type:
        "receive_request",

      referenceId:
        receiveRequest.requestId,

      isRead:
        false
    });

    return res.status(201).json({
      success: true,
      message:
        "Receive request created successfully",

      receiveRequest
    });
  } catch (error) {
    console.error(
      "Create receive request error:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "Server error while creating receive request"
    });
  }
};

// ============================================================
// UPDATE REQUEST
// REQUESTER CAN ONLY CANCEL
// ============================================================

const updateReceiveRequest = async (
  req,
  res
) => {
  try {
    const { requestId } = req.params;
    const { status } = req.body;

    if (!status) {
      return res.status(400).json({
        success: false,
        message: "Status is required"
      });
    }

    // Only cancellation is allowed through this endpoint.
    // Approval and denial have their own protected endpoints.
    if (status !== "cancelled") {
      return res.status(400).json({
        success: false,
        message:
          "Only cancellation is allowed through this endpoint"
      });
    }

    const receiveRequest =
      await ReceiveRequest.findOne({
        requestId,
        userId: req.user.userId
      });

    if (!receiveRequest) {
      return res.status(404).json({
        success: false,
        message:
          "Receive request not found"
      });
    }

    if (receiveRequest.status !== "pending") {
      return res.status(400).json({
        success: false,
        message:
          "This request has already been processed"
      });
    }

    receiveRequest.status =
      "cancelled";

    receiveRequest.completedAt =
      new Date();

    await receiveRequest.save();

    return res.status(200).json({
      success: true,
      message:
        "Receive request cancelled successfully",
      receiveRequest
    });
  } catch (error) {
    console.error(
      "Update receive request error:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "Server error while updating receive request"
    });
  }
};

// ============================================================
// APPROVE RECEIVE REQUEST
// ============================================================

const approveReceiveRequest = async (
  req,
  res
) => {
  try {
    const { requestId } = req.params;

    // ----------------------------------------------------------
    // Atomically claim the request.
    //
    // This prevents two simultaneous approve requests from
    // processing the same pending request.
    // ----------------------------------------------------------

    const receiveRequest =
      await ReceiveRequest.findOneAndUpdate(
        {
          requestId,
          receiverUserId: req.user.userId,
          status: "pending"
        },
        {
          $set: {
            status: "processing"
          }
        },
        {
          new: true
        }
      );

    if (!receiveRequest) {
      const existingRequest =
        await ReceiveRequest.findOne({
          requestId
        });

      if (!existingRequest) {
        return res.status(404).json({
          success: false,
          message:
            "Receive request not found"
        });
      }

      if (
        existingRequest.receiverUserId !==
        req.user.userId
      ) {
        return res.status(403).json({
          success: false,
          message:
            "You are not authorized to approve this request"
        });
      }

      return res.status(400).json({
        success: false,
        message:
          "This request has already been processed"
      });
    }

    const asset =
      receiveRequest.asset
        .toString()
        .trim()
        .toUpperCase();

    const amount =
      Number(receiveRequest.amount);

    if (!SUPPORTED_ASSETS.includes(asset)) {
      await ReceiveRequest.updateOne(
        {
          requestId,
          status: "processing"
        },
        {
          $set: {
            status: "pending"
          }
        }
      );

      return res.status(400).json({
        success: false,
        message:
          "Unsupported asset"
      });
    }

    if (
      !Number.isFinite(amount) ||
      amount <= 0
    ) {
      await ReceiveRequest.updateOne(
        {
          requestId,
          status: "processing"
        },
        {
          $set: {
            status: "pending"
          }
        }
      );

      return res.status(400).json({
        success: false,
        message:
          "Invalid request amount"
      });
    }

    // ----------------------------------------------------------
    // Find payer wallet
    // ----------------------------------------------------------

    const senderWallet =
      await Wallet.findOne({
        userId:
          receiveRequest.receiverUserId
      });

    if (!senderWallet) {
      await ReceiveRequest.updateOne(
        {
          requestId,
          status: "processing"
        },
        {
          $set: {
            status: "pending"
          }
        }
      );

      return res.status(404).json({
        success: false,
        message:
          "Your wallet was not found"
      });
    }

    // ----------------------------------------------------------
    // USD CONVERSION RATES
    //
    // These rates represent how many units of each asset
    // equal approximately 1 USD.
    //
    // Same rates used by the wallet transfer logic.
    // ----------------------------------------------------------

    const currencyRates = {
      USD: 1.0,
      USDT: 1.0,
      USDC: 1.0,
      BTC: 0.0000105,
      ETH: 0.00030,
      SOL: 0.00680,
      TRX: 12.0,
      INR: 83.50,
      EUR: 0.92,
      GBP: 0.79,
      AED: 3.6725,
      JPY: 157.0
    };

    // ----------------------------------------------------------
    // Assets that can be used to pay from the wallet.
    //
    // This follows the same order used by the wallet's
    // USD transfer logic.
    // ----------------------------------------------------------

    const sourceAssets = [
      "USD",
      "ETH",
      "USDT",
      "USDC",
      "SOL",
      "TRX",
      "BTC"
    ];

    // ----------------------------------------------------------
    // Calculate USD value of an asset balance.
    // ----------------------------------------------------------

    const getUsdValue = (
      sourceAsset,
      balance
    ) => {
      const rate =
        currencyRates[sourceAsset];

      if (
        !Number.isFinite(rate) ||
        rate <= 0
      ) {
        return 0;
      }

      return balance / rate;
    };

    // ----------------------------------------------------------
    // Calculate total wallet USD value
    // ----------------------------------------------------------

    let totalUsdBalance = 0;

    for (const sourceAsset of sourceAssets) {
      const balance =
        Number(
          senderWallet.balances[sourceAsset]
        ) || 0;

      if (balance <= 0) {
        continue;
      }

      totalUsdBalance +=
        getUsdValue(
          sourceAsset,
          balance
        );
    }

    // ----------------------------------------------------------
    // Calculate required USD value of requested amount
    // ----------------------------------------------------------

    const requestedAssetRate =
      currencyRates[asset];

    if (
      !Number.isFinite(
        requestedAssetRate
      ) ||
      requestedAssetRate <= 0
    ) {
      await ReceiveRequest.updateOne(
        {
          requestId,
          status: "processing"
        },
        {
          $set: {
            status: "pending"
          }
        }
      );

      return res.status(400).json({
        success: false,
        message:
          `No USD conversion rate available for ${asset}`
      });
    }

    const requiredUsd =
      amount / requestedAssetRate;

    // ----------------------------------------------------------
    // Check TOTAL wallet balance.
    //
    // Previously this checked only:
    //
    // balances.USDT >= amount
    //
    // That caused "Insufficient USDT balance" even when the
    // user had enough total wallet value in USD/ETH/SOL/etc.
    // ----------------------------------------------------------

    if (
      requiredUsd >
      totalUsdBalance + 0.00000001
    ) {
      await ReceiveRequest.updateOne(
        {
          requestId,
          status: "processing"
        },
        {
          $set: {
            status: "pending"
          }
        }
      );

      return res.status(400).json({
        success: false,
        message:
          `Insufficient wallet balance. Available: $${totalUsdBalance.toFixed(2)}`
      });
    }

    // ----------------------------------------------------------
    // SAVE ORIGINAL SENDER BALANCES
    //
    // These are used only if something fails later and we need
    // to rollback the sender wallet.
    // ----------------------------------------------------------

    const originalSenderBalances = {};

    for (const sourceAsset of sourceAssets) {
      originalSenderBalances[sourceAsset] =
        Number(
          senderWallet.balances[sourceAsset]
        ) || 0;
    }

    // ----------------------------------------------------------
    // DEDUCT REQUIRED USD VALUE FROM SENDER
    //
    // Order:
    //
    // USD -> ETH -> USDT -> USDC -> SOL -> TRX -> BTC
    //
    // The requester will still receive the exact requested
    // asset and amount.
    // ----------------------------------------------------------

    let remainingUsd =
      requiredUsd;

    for (const sourceAsset of sourceAssets) {
      if (
        remainingUsd <=
        0.00000001
      ) {
        break;
      }

      const currentBalance =
        Number(
          senderWallet.balances[sourceAsset]
        ) || 0;

      if (currentBalance <= 0) {
        continue;
      }

      const assetUsdValue =
        getUsdValue(
          sourceAsset,
          currentBalance
        );

      if (assetUsdValue <= 0) {
        continue;
      }

      const usdToDeduct =
        Math.min(
          assetUsdValue,
          remainingUsd
        );

      const assetAmountToDeduct =
        usdToDeduct *
        currencyRates[sourceAsset];

      let newBalance =
        currentBalance -
        assetAmountToDeduct;

      if (
        newBalance <
        0.00000001
      ) {
        newBalance = 0;
      }

      senderWallet.balances[
        sourceAsset
      ] = newBalance;

      remainingUsd -=
        usdToDeduct;
    }

    // ----------------------------------------------------------
    // Final safety check
    // ----------------------------------------------------------

    if (
      remainingUsd >
      0.00000001
    ) {
      await ReceiveRequest.updateOne(
        {
          requestId,
          status: "processing"
        },
        {
          $set: {
            status: "pending"
          }
        }
      );

      return res.status(400).json({
        success: false,
        message:
          "Unable to deduct the requested amount from your wallet"
      });
    }

    // ----------------------------------------------------------
    // Find requester wallet
    // ----------------------------------------------------------

    const requesterWallet =
      await Wallet.findOne({
        userId:
          receiveRequest.userId
      });

    if (!requesterWallet) {
      await ReceiveRequest.updateOne(
        {
          requestId,
          status: "processing"
        },
        {
          $set: {
            status: "pending"
          }
        }
      );

      return res.status(404).json({
        success: false,
        message:
          "Requester wallet was not found"
      });
    }

    // ----------------------------------------------------------
    // SAVE ORIGINAL REQUESTER BALANCE
    // ----------------------------------------------------------

    const originalRequesterBalance =
      Number(
        requesterWallet.balances[asset]
      ) || 0;

    // ----------------------------------------------------------
    // Add requested amount to requester wallet
    // ----------------------------------------------------------

    requesterWallet.balances[asset] =
      originalRequesterBalance +
      amount;

    senderWallet.updatedAt =
      new Date();

    requesterWallet.updatedAt =
      new Date();

    // ----------------------------------------------------------
    // SAVE BOTH WALLETS
    // ----------------------------------------------------------

    try {
      await senderWallet.save();
      await requesterWallet.save();
    } catch (walletSaveError) {
      // --------------------------------------------------------
      // Rollback sender in memory and database
      // --------------------------------------------------------

      for (const sourceAsset of sourceAssets) {
        senderWallet.balances[
          sourceAsset
        ] =
          originalSenderBalances[
            sourceAsset
          ];
      }

      // --------------------------------------------------------
      // Rollback requester in memory
      // --------------------------------------------------------

      requesterWallet.balances[asset] =
        originalRequesterBalance;

      try {
        await Wallet.findOneAndUpdate(
          {
            userId:
              receiveRequest.receiverUserId
          },
          {
            $set: {
              [`balances.USD`]:
                originalSenderBalances.USD,

              [`balances.ETH`]:
                originalSenderBalances.ETH,

              [`balances.USDT`]:
                originalSenderBalances.USDT,

              [`balances.USDC`]:
                originalSenderBalances.USDC,

              [`balances.SOL`]:
                originalSenderBalances.SOL,

              [`balances.TRX`]:
                originalSenderBalances.TRX,

              [`balances.BTC`]:
                originalSenderBalances.BTC,

              updatedAt:
                new Date()
            }
          }
        );

        await Wallet.findOneAndUpdate(
          {
            userId:
              receiveRequest.userId
          },
          {
            $set: {
              [`balances.${asset}`]:
                originalRequesterBalance,

              updatedAt:
                new Date()
            }
          }
        );
      } catch (rollbackError) {
        console.error(
          "Wallet save rollback error:",
          rollbackError
        );
      }

      throw walletSaveError;
    }

    // ----------------------------------------------------------
    // Mark request completed
    // ----------------------------------------------------------

    const completedRequest =
      await ReceiveRequest.findOneAndUpdate(
        {
          requestId,
          status: "processing"
        },
        {
          $set: {
            status: "completed",
            completedAt:
              new Date()
          }
        },
        {
          new: true
        }
      );

    if (!completedRequest) {
      // --------------------------------------------------------
      // Rollback sender wallet
      // --------------------------------------------------------

      try {
        await Wallet.findOneAndUpdate(
          {
            userId:
              receiveRequest.receiverUserId
          },
          {
            $set: {
              [`balances.USD`]:
                originalSenderBalances.USD,

              [`balances.ETH`]:
                originalSenderBalances.ETH,

              [`balances.USDT`]:
                originalSenderBalances.USDT,

              [`balances.USDC`]:
                originalSenderBalances.USDC,

              [`balances.SOL`]:
                originalSenderBalances.SOL,

              [`balances.TRX`]:
                originalSenderBalances.TRX,

              [`balances.BTC`]:
                originalSenderBalances.BTC,

              updatedAt:
                new Date()
            }
          }
        );

        // ------------------------------------------------------
        // Rollback requester wallet
        // ------------------------------------------------------

        await Wallet.findOneAndUpdate(
          {
            userId:
              receiveRequest.userId
          },
          {
            $set: {
              [`balances.${asset}`]:
                originalRequesterBalance,

              updatedAt:
                new Date()
            }
          }
        );
      } catch (rollbackError) {
        console.error(
          "Receive request completion rollback error:",
          rollbackError
        );
      }

      return res.status(500).json({
        success: false,
        message:
          "Receive request could not be completed"
      });
    }

    // ----------------------------------------------------------
    // Notify requester
    // ----------------------------------------------------------

    await Notification.create({
      notificationId:
        generateNotificationId(),

      userId:
        receiveRequest.userId,

      title:
        "Receive Request Approved",

      message:
        `${amount} ${asset} receive request has been approved and added to your wallet.`,

      type:
        "transaction",

      referenceId:
        receiveRequest.requestId,

      isRead:
        false
    });

    return res.status(200).json({
      success: true,
      message:
        `${amount} ${asset} transferred successfully`,

      receiveRequest:
        completedRequest
    });
  } catch (error) {
    console.error(
      "Approve receive request error:",
      error
    );

    // If an unexpected error occurs after the request
    // was claimed, put it back to pending so the user
    // does not permanently lose the request.
    try {
      const { requestId } = req.params;

      await ReceiveRequest.updateOne(
        {
          requestId,
          status: "processing"
        },
        {
          $set: {
            status: "pending"
          }
        }
      );
    } catch (rollbackError) {
      console.error(
        "Receive request status rollback error:",
        rollbackError
      );
    }

    return res.status(500).json({
      success: false,
      message:
        "Server error while approving receive request"
    });
  }
};

// ============================================================
// DENY RECEIVE REQUEST
// ============================================================

const denyReceiveRequest = async (
  req,
  res
) => {
  try {
    const { requestId } = req.params;

    const receiveRequest =
      await ReceiveRequest.findOneAndUpdate(
        {
          requestId,
          receiverUserId: req.user.userId,
          status: "pending"
        },
        {
          $set: {
            status: "denied",
            completedAt:
              new Date()
          }
        },
        {
          new: true
        }
      );

    if (!receiveRequest) {
      const existingRequest =
        await ReceiveRequest.findOne({
          requestId
        });

      if (!existingRequest) {
        return res.status(404).json({
          success: false,
          message:
            "Receive request not found"
        });
      }

      if (
        existingRequest.receiverUserId !==
        req.user.userId
      ) {
        return res.status(403).json({
          success: false,
          message:
            "You are not authorized to deny this request"
        });
      }

      return res.status(400).json({
        success: false,
        message:
          "This request has already been processed"
      });
    }

    // ----------------------------------------------------------
    // Notify requester
    // ----------------------------------------------------------

    await Notification.create({
      notificationId:
        generateNotificationId(),

      userId:
        receiveRequest.userId,

      title:
        "Receive Request Denied",

      message:
        `${receiveRequest.amount} ${receiveRequest.asset} receive request has been denied.`,

      type:
        "transaction",

      referenceId:
        receiveRequest.requestId,

      isRead:
        false
    });

    return res.status(200).json({
      success: true,
      message:
        "Receive request denied successfully",

      receiveRequest
    });
  } catch (error) {
    console.error(
      "Deny receive request error:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "Server error while denying receive request"
    });
  }
};

// ============================================================
// DELETE REQUEST
// ============================================================

const deleteReceiveRequest = async (
  req,
  res
) => {
  try {
    const { requestId } = req.params;

    const receiveRequest =
      await ReceiveRequest.findOneAndDelete({
        requestId,
        userId: req.user.userId
      });

    if (!receiveRequest) {
      return res.status(404).json({
        success: false,
        message:
          "Receive request not found"
      });
    }

    return res.status(200).json({
      success: true,
      message:
        "Receive request deleted successfully"
    });
  } catch (error) {
    console.error(
      "Delete receive request error:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "Server error while deleting receive request"
    });
  }
};

// ============================================================
// CLEAR REQUESTS
// ============================================================

const clearReceiveRequests = async (
  req,
  res
) => {
  try {
    await ReceiveRequest.deleteMany({
      userId: req.user.userId
    });

    return res.status(200).json({
      success: true,
      message:
        "All receive requests deleted successfully"
    });
  } catch (error) {
    console.error(
      "Clear receive requests error:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "Server error while clearing receive requests"
    });
  }
};

// ============================================================
// EXPORTS
// ============================================================

module.exports = {
  getReceiveRequests,
  createReceiveRequest,
  updateReceiveRequest,
  approveReceiveRequest,
  denyReceiveRequest,
  deleteReceiveRequest,
  clearReceiveRequests
};