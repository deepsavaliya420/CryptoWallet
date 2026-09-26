const express = require("express");

const {
  getNotifications,
  createNotification,
  markNotificationAsRead,
  deleteNotification
} = require("../controllers/notificationController");

const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

router.get("/", authMiddleware, getNotifications);

router.post("/", authMiddleware, createNotification);

router.put("/:notificationId/read", authMiddleware, markNotificationAsRead);

router.delete("/:notificationId", authMiddleware, deleteNotification);

module.exports = router;