const express = require("express");

const {
  getOrders,
  getMyOrders,
  createOrder,
  updateOrderStatus,
  cancelOrder
} = require("../controllers/p2pOrderController");

const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

router.get("/", authMiddleware, getOrders);

router.get("/my", authMiddleware, getMyOrders);

router.post("/", authMiddleware, createOrder);

router.put("/:orderId/status", authMiddleware, updateOrderStatus);

router.put("/:orderId/cancel", authMiddleware, cancelOrder);

module.exports = router;