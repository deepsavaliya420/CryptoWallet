const express = require("express");

const {
  getWallet,
  updateBalance
} = require("../controllers/walletController");

const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

router.get("/", authMiddleware, getWallet);

router.put("/balance", authMiddleware, updateBalance);

module.exports = router;