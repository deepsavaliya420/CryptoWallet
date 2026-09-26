const Swap = require("../models/Swap");

const generateSwapId = () => {
  return `SW-${Date.now()}-${Math.random()
    .toString(36)
    .substring(2, 8)
    .toUpperCase()}`;
};

const getSwaps = async (req, res) => {
  try {
    const swaps = await Swap.find({
      userId: req.user.userId
    }).sort({
      createdAt: -1
    });

    return res.status(200).json({
      success: true,
      swaps
    });
  } catch (error) {
    console.error("Get swaps error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error while fetching swaps"
    });
  }
};

const createSwap = async (req, res) => {
  try {
    const {
      fromAsset,
      toAsset,
      fromAmount,
      toAmount,
      rate,
      status
    } = req.body;

    if (
      !fromAsset ||
      !toAsset ||
      fromAmount === undefined ||
      toAmount === undefined
    ) {
      return res.status(400).json({
        success: false,
        message: "From asset, to asset, from amount and to amount are required"
      });
    }

    if (fromAsset === toAsset) {
      return res.status(400).json({
        success: false,
        message: "From asset and to asset must be different"
      });
    }

    const swap = await Swap.create({
      swapId: generateSwapId(),
      userId: req.user.userId,
      fromAsset,
      toAsset,
      fromAmount,
      toAmount,
      rate: rate || 0,
      status: status || "completed"
    });

    return res.status(201).json({
      success: true,
      message: "Swap created successfully",
      swap
    });
  } catch (error) {
    console.error("Create swap error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error while creating swap"
    });
  }
};

module.exports = {
  getSwaps,
  createSwap
};