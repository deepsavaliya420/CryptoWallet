const P2POffer = require("../models/P2POffer");

const generateOfferId = () => {
  return `PO-${Date.now()}-${Math.random()
    .toString(36)
    .substring(2, 8)
    .toUpperCase()}`;
};

const getOffers = async (req, res) => {
  try {
    const offers = await P2POffer.find({
      status: "active"
    }).sort({
      createdAt: -1
    });

    return res.status(200).json({
      success: true,
      offers
    });
  } catch (error) {
    console.error("Get P2P offers error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error while fetching P2P offers"
    });
  }
};

const getMyOffers = async (req, res) => {
  try {
    const offers = await P2POffer.find({
      sellerUserId: req.user.userId
    }).sort({
      createdAt: -1
    });

    return res.status(200).json({
      success: true,
      offers
    });
  } catch (error) {
    console.error("Get my P2P offers error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error while fetching your P2P offers"
    });
  }
};

const createOffer = async (req, res) => {
  try {
    const {
      asset,
      amount,
      price,
      paymentMethod,
      minLimit,
      maxLimit,
      status
    } = req.body;

    if (
      !asset ||
      amount === undefined ||
      price === undefined ||
      !paymentMethod
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Asset, amount, price and payment method are required"
      });
    }

    if (amount <= 0 || price <= 0) {
      return res.status(400).json({
        success: false,
        message: "Amount and price must be greater than zero"
      });
    }

    const offer = await P2POffer.create({
      offerId: generateOfferId(),
      sellerUserId: req.user.userId,
      asset,
      amount,
      price,
      paymentMethod,
      minLimit: minLimit || 0,
      maxLimit: maxLimit || 0,
      status: status || "active"
    });

    return res.status(201).json({
      success: true,
      message: "P2P offer created successfully",
      offer
    });
  } catch (error) {
    console.error("Create P2P offer error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error while creating P2P offer"
    });
  }
};

const updateOffer = async (req, res) => {
  try {
    const { offerId } = req.params;

    const {
      asset,
      amount,
      price,
      paymentMethod,
      minLimit,
      maxLimit,
      status
    } = req.body;

    const offer = await P2POffer.findOne({
      offerId,
      sellerUserId: req.user.userId
    });

    if (!offer) {
      return res.status(404).json({
        success: false,
        message: "P2P offer not found"
      });
    }

    if (asset !== undefined) {
      offer.asset = asset;
    }

    if (amount !== undefined) {
      if (amount <= 0) {
        return res.status(400).json({
          success: false,
          message: "Amount must be greater than zero"
        });
      }

      offer.amount = amount;
    }

    if (price !== undefined) {
      if (price <= 0) {
        return res.status(400).json({
          success: false,
          message: "Price must be greater than zero"
        });
      }

      offer.price = price;
    }

    if (paymentMethod !== undefined) {
      offer.paymentMethod = paymentMethod;
    }

    if (minLimit !== undefined) {
      offer.minLimit = minLimit;
    }

    if (maxLimit !== undefined) {
      offer.maxLimit = maxLimit;
    }

    if (status !== undefined) {
      const allowedStatuses = [
        "active",
        "paused",
        "completed",
        "cancelled"
      ];

      if (!allowedStatuses.includes(status)) {
        return res.status(400).json({
          success: false,
          message: "Invalid offer status"
        });
      }

      offer.status = status;
    }

    offer.updatedAt = new Date();

    await offer.save();

    return res.status(200).json({
      success: true,
      message: "P2P offer updated successfully",
      offer
    });
  } catch (error) {
    console.error("Update P2P offer error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error while updating P2P offer"
    });
  }
};

const deleteOffer = async (req, res) => {
  try {
    const { offerId } = req.params;

    const offer = await P2POffer.findOneAndDelete({
      offerId,
      sellerUserId: req.user.userId
    });

    if (!offer) {
      return res.status(404).json({
        success: false,
        message: "P2P offer not found"
      });
    }

    return res.status(200).json({
      success: true,
      message: "P2P offer deleted successfully"
    });
  } catch (error) {
    console.error("Delete P2P offer error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error while deleting P2P offer"
    });
  }
};

module.exports = {
  getOffers,
  getMyOffers,
  createOffer,
  updateOffer,
  deleteOffer
};