const express = require("express");

const {
  getNotifications,
  createNotification,
  markNotificationAsRead,
  markAllNotificationsAsRead,
  deleteNotification,
  clearNotifications
} = require("../controllers/notificationController");

const authMiddleware =
  require("../middleware/authMiddleware");

const router = express.Router();

// ============================================================
// GET ALL NOTIFICATIONS
// ============================================================

router.get(
  "/",
  authMiddleware,
  getNotifications
);

// ============================================================
// CREATE NOTIFICATION
// ============================================================

router.post(
  "/",
  authMiddleware,
  createNotification
);

// ============================================================
// MARK ALL NOTIFICATIONS AS READ
// IMPORTANT: Keep this BEFORE /:notificationId/read
// ============================================================

router.put(
  "/read-all",
  authMiddleware,
  markAllNotificationsAsRead
);

// ============================================================
// MARK ONE NOTIFICATION AS READ
// ============================================================

router.put(
  "/:notificationId/read",
  authMiddleware,
  markNotificationAsRead
);

// ============================================================
// CLEAR ALL NOTIFICATIONS
// IMPORTANT: Keep this BEFORE /:notificationId
// ============================================================

router.delete(
  "/",
  authMiddleware,
  clearNotifications
);

// ============================================================
// DELETE ONE NOTIFICATION
// ============================================================

router.delete(
  "/:notificationId",
  authMiddleware,
  deleteNotification
);

module.exports = router;