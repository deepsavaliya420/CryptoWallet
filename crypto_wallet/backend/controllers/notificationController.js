const Notification = require("../models/Notification");

const generateNotificationId = () => {
  return `NT-${Date.now()}-${Math.random()
    .toString(36)
    .substring(2, 8)
    .toUpperCase()}`;
};

// ============================================================
// GET NOTIFICATIONS
// ============================================================

const getNotifications = async (req, res) => {
  try {
    const notifications =
      await Notification.find({
        userId: req.user.userId
      }).sort({
        createdAt: -1
      });

    return res.status(200).json({
      success: true,
      notifications
    });
  } catch (error) {
    console.error(
      "Get notifications error:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "Server error while fetching notifications"
    });
  }
};

// ============================================================
// CREATE NOTIFICATION
// ============================================================

const createNotification = async (req, res) => {
  try {
    const {
      title,
      message,
      type,
      referenceId,
      isRead
    } = req.body;

    if (!title || !message) {
      return res.status(400).json({
        success: false,
        message:
          "Title and message are required"
      });
    }

    const notification =
      await Notification.create({
        notificationId:
          generateNotificationId(),

        userId:
          req.user.userId,

        title,

        message,

        type:
          type || "general",

        referenceId:
          referenceId || "",

        isRead:
          isRead === true
      });

    return res.status(201).json({
      success: true,
      message:
        "Notification created successfully",

      notification
    });
  } catch (error) {
    console.error(
      "Create notification error:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "Server error while creating notification"
    });
  }
};

// ============================================================
// MARK ONE NOTIFICATION AS READ
// ============================================================

const markNotificationAsRead = async (
  req,
  res
) => {
  try {
    const { notificationId } =
      req.params;

    const notification =
      await Notification.findOne({
        notificationId,
        userId: req.user.userId
      });

    if (!notification) {
      return res.status(404).json({
        success: false,
        message:
          "Notification not found"
      });
    }

    notification.isRead = true;

    await notification.save();

    return res.status(200).json({
      success: true,
      message:
        "Notification marked as read",

      notification
    });
  } catch (error) {
    console.error(
      "Mark notification as read error:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "Server error while updating notification"
    });
  }
};

// ============================================================
// MARK ALL NOTIFICATIONS AS READ
// ============================================================

const markAllNotificationsAsRead = async (
  req,
  res
) => {
  try {
    await Notification.updateMany(
      {
        userId: req.user.userId,
        isRead: false
      },
      {
        $set: {
          isRead: true
        }
      }
    );

    return res.status(200).json({
      success: true,
      message:
        "All notifications marked as read"
    });
  } catch (error) {
    console.error(
      "Mark all notifications as read error:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "Server error while updating notifications"
    });
  }
};

// ============================================================
// DELETE ONE NOTIFICATION
// ============================================================

const deleteNotification = async (
  req,
  res
) => {
  try {
    const { notificationId } =
      req.params;

    const notification =
      await Notification.findOneAndDelete({
        notificationId,
        userId: req.user.userId
      });

    if (!notification) {
      return res.status(404).json({
        success: false,
        message:
          "Notification not found"
      });
    }

    return res.status(200).json({
      success: true,
      message:
        "Notification deleted successfully"
    });
  } catch (error) {
    console.error(
      "Delete notification error:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "Server error while deleting notification"
    });
  }
};

// ============================================================
// CLEAR ALL NOTIFICATIONS
// ============================================================

const clearNotifications = async (
  req,
  res
) => {
  try {
    await Notification.deleteMany({
      userId: req.user.userId
    });

    return res.status(200).json({
      success: true,
      message:
        "All notifications deleted successfully"
    });
  } catch (error) {
    console.error(
      "Clear notifications error:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "Server error while clearing notifications"
    });
  }
};

// ============================================================
// EXPORTS
// ============================================================

module.exports = {
  getNotifications,
  createNotification,
  markNotificationAsRead,
  markAllNotificationsAsRead,
  deleteNotification,
  clearNotifications
};