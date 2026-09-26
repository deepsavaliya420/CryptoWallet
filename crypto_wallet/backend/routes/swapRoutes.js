const express = require("express");

const {
  getSwaps,
  createSwap
} = require("../controllers/swapController");

const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

router.get("/", authMiddleware, getSwaps);

router.post("/", authMiddleware, createSwap);

module.exports = router;