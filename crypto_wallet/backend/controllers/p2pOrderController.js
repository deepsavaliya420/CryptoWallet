const P2POrder = require("../models/P2POrder");
const P2POffer = require("../models/P2POffer");
const Wallet = require("../models/Wallet");

const generateOrderId = () =>
  `PO-${Date.now()}-${Math.random().toString(36).substring(2, 8).toUpperCase()}`;

const getOrders = async (req, res) => {
  try {
    const orders = await P2POrder.find({
      $or: [
        { buyerUserId: req.user.userId },
        { sellerUserId: req.user.userId }
      ]
    }).sort({ createdAt: -1 });

    return res.status(200).json({
      success: true,
      orders
    });
  } catch (error) {
    console.error("Get P2P orders error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error while fetching P2P orders"
    });
  }
};

const getMyOrders = async (req, res) => {
  try {
    const orders = await P2POrder.find({
      buyerUserId: req.user.userId
    }).sort({ createdAt: -1 });

    return res.status(200).json({
      success: true,
      orders
    });
  } catch (error) {
    console.error("Get my P2P orders error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error while fetching your P2P orders"
    });
  }
};

const createOrder = async (req, res) => {
  try {
    const { offerId, amount } = req.body;

    if (!offerId || amount === undefined) {
      return res.status(400).json({
        success: false,
        message: "Offer ID and amount are required"
      });
    }

    if (amount <= 0) {
      return res.status(400).json({
        success: false,
        message: "Amount must be greater than zero"
      });
    }

    const offer = await P2POffer.findOne({
      offerId,
      status: "active"
    });

    if (!offer) {
      return res.status(404).json({
        success: false,
        message: "Active P2P offer not found"
      });
    }

    if (offer.sellerUserId === req.user.userId) {
      return res.status(400).json({
        success: false,
        message: "You cannot buy your own offer"
      });
    }

    if (amount > offer.amount) {
      return res.status(400).json({
        success: false,
        message: "Requested amount exceeds available offer amount"
      });
    }

    if (offer.minLimit > 0 && amount < offer.minLimit) {
      return res.status(400).json({
        success: false,
        message: `Minimum order amount is ${offer.minLimit}`
      });
    }

    if (offer.maxLimit > 0 && amount > offer.maxLimit) {
      return res.status(400).json({
        success: false,
        message: `Maximum order amount is ${offer.maxLimit}`
      });
    }

    const totalAmount = amount * offer.price;

    const buyerWallet = await Wallet.findOne({
      userId: req.user.userId
    });

    const sellerWallet = await Wallet.findOne({
      userId: offer.sellerUserId
    });

    if (!buyerWallet) {
      return res.status(404).json({
        success: false,
        message: "Buyer wallet not found"
      });
    }

    if (!sellerWallet) {
      return res.status(404).json({
        success: false,
        message: "Seller wallet not found"
      });
    }

    const order = await P2POrder.create({
      orderId: generateOrderId(),
      offerId: offer.offerId,
      buyerUserId: req.user.userId,
      sellerUserId: offer.sellerUserId,
      asset: offer.asset,
      amount,
      price: offer.price,
      totalAmount,
      paymentMethod: offer.paymentMethod,
      status: "pending",
      buyerWalletAddress: buyerWallet.walletAddress,
      sellerWalletAddress: sellerWallet.walletAddress
    });

    return res.status(201).json({
      success: true,
      message: "P2P order created successfully",
      order
    });
  } catch (error) {
    console.error("Create P2P order error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error while creating P2P order"
    });
  }
};

const updateOrderStatus = async (req, res) => {
  try {
    const { orderId } = req.params;
    const { status } = req.body;

    const allowedStatuses = [
      "pending",
      "payment_sent",
      "payment_confirmed",
      "completed",
      "cancelled",
      "disputed"
    ];

    if (!status || !allowedStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: "Invalid order status"
      });
    }

    const order = await P2POrder.findOne({
      orderId,
      $or: [
        { buyerUserId: req.user.userId },
        { sellerUserId: req.user.userId }
      ]
    });

    if (!order) {
      return res.status(404).json({
        success: false,
        message: "P2P order not found"
      });
    }

    order.status = status;
    order.updatedAt = new Date();

    await order.save();

    return res.status(200).json({
      success: true,
      message: "P2P order status updated successfully",
      order
    });
  } catch (error) {
    console.error("Update P2P order error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error while updating P2P order"
    });
  }
};

const cancelOrder = async (req, res) => {
  try {
    const { orderId } = req.params;

    const order = await P2POrder.findOne({
      orderId,
      $or: [
        { buyerUserId: req.user.userId },
        { sellerUserId: req.user.userId }
      ]
    });

    if (!order) {
      return res.status(404).json({
        success: false,
        message: "P2P order not found"
      });
    }

    if (order.status === "completed") {
      return res.status(400).json({
        success: false,
        message: "Completed order cannot be cancelled"
      });
    }

    order.status = "cancelled";
    order.updatedAt = new Date();

    await order.save();

    return res.status(200).json({
      success: true,
      message: "P2P order cancelled successfully",
      order
    });
  } catch (error) {
    console.error("Cancel P2P order error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error while cancelling P2P order"
    });
  }
};

module.exports = {
  getOrders,
  getMyOrders,
  createOrder,
  updateOrderStatus,
  cancelOrder
};