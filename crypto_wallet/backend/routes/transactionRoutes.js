const express = require("express");

const {
  getTransactions,
  createTransaction
} = require("../controllers/transactionController");

const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

router.get("/", authMiddleware, getTransactions);

router.post("/", authMiddleware, createTransaction);

module.exports = router;