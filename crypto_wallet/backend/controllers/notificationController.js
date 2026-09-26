const Notification = require("../models/Notification");

const generateNotificationId = () => {
  return `NT-${Date.now()}-${Math.random()
    .toString(36)
    .substring(2, 8)
    .toUpperCase()}`;
};

const getNotifications = async (req, res) => {
  try {
    const notifications = await Notification.find({
      userId: req.user.userId
    }).sort({
      createdAt: -1
    });

    return res.status(200).json({
      success: true,
      notifications
    });
  } catch (error) {
    console.error("Get notifications error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error while fetching notifications"
    });
  }
};

const createNotification = async (req, res) => {
  try {
    const {
      title,
      message,
      type,
      isRead
    } = req.body;

    if (!title || !message) {
      return res.status(400).json({
        success: false,
        message: "Title and message are required"
      });
    }

    const notification = await Notification.create({
      notificationId: generateNotificationId(),
      userId: req.user.userId,
      title,
      message,
      type: type || "general",
      isRead: isRead || false
    });

    return res.status(201).json({
      success: true,
      message: "Notification created successfully",
      notification
    });
  } catch (error) {
    console.error("Create notification error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error while creating notification"
    });
  }
};

const markNotificationAsRead = async (req, res) => {
  try {
    const { notificationId } = req.params;

    const notification = await Notification.findOne({
      notificationId,
      userId: req.user.userId
    });

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: "Notification not found"
      });
    }

    notification.isRead = true;

    await notification.save();

    return res.status(200).json({
      success: true,
      message: "Notification marked as read",
      notification
    });
  } catch (error) {
    console.error("Mark notification as read error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error while updating notification"
    });
  }
};

const deleteNotification = async (req, res) => {
  try {
    const { notificationId } = req.params;

    const notification =
      await Notification.findOneAndDelete({
        notificationId,
        userId: req.user.userId
      });

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: "Notification not found"
      });
    }

    return res.status(200).json({
      success: true,
      message: "Notification deleted successfully"
    });
  } catch (error) {
    console.error("Delete notification error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error while deleting notification"
    });
  }
};

module.exports = {
  getNotifications,
  createNotification,
  markNotificationAsRead,
  deleteNotification
};