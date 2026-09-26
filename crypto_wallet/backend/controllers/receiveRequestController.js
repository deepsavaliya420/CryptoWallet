const ReceiveRequest = require("../models/ReceiveRequest");

const generateRequestId = () => {
  return `RR-${Date.now()}-${Math.random()
    .toString(36)
    .substring(2, 8)
    .toUpperCase()}`;
};

const getReceiveRequests = async (req, res) => {
  try {
    const receiveRequests = await ReceiveRequest.find({
      userId: req.user.userId
    }).sort({
      createdAt: -1
    });

    return res.status(200).json({
      success: true,
      receiveRequests
    });
  } catch (error) {
    console.error("Get receive requests error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error while fetching receive requests"
    });
  }
};

const createReceiveRequest = async (req, res) => {
  try {
    const {
      asset,
      amount,
      walletAddress,
      network,
      status
    } = req.body;

    if (!asset || amount === undefined) {
      return res.status(400).json({
        success: false,
        message: "Asset and amount are required"
      });
    }

    const receiveRequest = await ReceiveRequest.create({
      requestId: generateRequestId(),
      userId: req.user.userId,
      asset,
      amount,
      walletAddress: walletAddress || "",
      network: network || "",
      status: status || "pending"
    });

    return res.status(201).json({
      success: true,
      message: "Receive request created successfully",
      receiveRequest
    });
  } catch (error) {
    console.error("Create receive request error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error while creating receive request"
    });
  }
};

const updateReceiveRequest = async (req, res) => {
  try {
    const { requestId } = req.params;
    const { status } = req.body;

    if (!status) {
      return res.status(400).json({
        success: false,
        message: "Status is required"
      });
    }

    const allowedStatuses = [
      "pending",
      "completed",
      "cancelled"
    ];

    if (!allowedStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: "Invalid status"
      });
    }

    const receiveRequest = await ReceiveRequest.findOne({
      requestId,
      userId: req.user.userId
    });

    if (!receiveRequest) {
      return res.status(404).json({
        success: false,
        message: "Receive request not found"
      });
    }

    receiveRequest.status = status;

    await receiveRequest.save();

    return res.status(200).json({
      success: true,
      message: "Receive request updated successfully",
      receiveRequest
    });
  } catch (error) {
    console.error("Update receive request error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error while updating receive request"
    });
  }
};

const deleteReceiveRequest = async (req, res) => {
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
        message: "Receive request not found"
      });
    }

    return res.status(200).json({
      success: true,
      message: "Receive request deleted successfully"
    });
  } catch (error) {
    console.error("Delete receive request error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error while deleting receive request"
    });
  }
};

module.exports = {
  getReceiveRequests,
  createReceiveRequest,
  updateReceiveRequest,
  deleteReceiveRequest
};