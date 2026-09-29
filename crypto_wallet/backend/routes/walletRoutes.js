const express = require("express");

const {
  getWallet,
  updateBalance,
  transferUsd
} = require("../controllers/walletController");

const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

router.get("/", authMiddleware, getWallet);

router.put("/balance", authMiddleware, updateBalance);

router.put("/transfer", authMiddleware, transferUsd);

module.exports = router;