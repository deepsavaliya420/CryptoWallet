const Transaction = require("../models/Transaction");

const generateTransactionId = () => {
  return `TX-${Date.now()}-${Math.random()
    .toString(36)
    .substring(2, 8)
    .toUpperCase()}`;
};

const getTransactions = async (req, res) => {
  try {
    const transactions = await Transaction.find({
      userId: req.user.userId
    }).sort({
      createdAt: -1
    });

    return res.status(200).json({
      success: true,
      transactions
    });
  } catch (error) {
    console.error("Get transactions error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error while fetching transactions"
    });
  }
};

const createTransaction = async (req, res) => {
  try {
    const {
      type,
      asset,
      amount,
      from,
      to,
      status,
      network,
      description
    } = req.body;

    if (!type || !asset || amount === undefined) {
      return res.status(400).json({
        success: false,
        message: "Type, asset and amount are required"
      });
    }

    const transaction = await Transaction.create({
      transactionId: generateTransactionId(),
      userId: req.user.userId,
      type,
      asset,
      amount,
      from: from || "",
      to: to || "",
      status: status || "completed",
      network: network || "",
      description: description || ""
    });

    return res.status(201).json({
      success: true,
      message: "Transaction created successfully",
      transaction
    });
  } catch (error) {
    console.error("Create transaction error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error while creating transaction"
    });
  }
};

module.exports = {
  getTransactions,
  createTransaction
};