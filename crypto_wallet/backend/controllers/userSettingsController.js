const UserSettings = require("../models/UserSettings");

const getSettings = async (req, res) => {
  try {
    let settings = await UserSettings.findOne({
      userId: req.user.userId
    });

    if (!settings) {
      settings = await UserSettings.create({
        userId: req.user.userId
      });
    }

    return res.status(200).json({
      success: true,
      settings
    });
  } catch (error) {
    console.error("Get settings error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error while fetching settings"
    });
  }
};

const updateSettings = async (req, res) => {
  try {
    const {
      notificationsEnabled,
      transactionNotifications,
      securityNotifications,
      biometricEnabled,
      darkMode,
      currency,
      language
    } = req.body;

    let settings = await UserSettings.findOne({
      userId: req.user.userId
    });

    if (!settings) {
      settings = new UserSettings({
        userId: req.user.userId
      });
    }

    if (notificationsEnabled !== undefined) {
      settings.notificationsEnabled = notificationsEnabled;
    }

    if (transactionNotifications !== undefined) {
      settings.transactionNotifications =
        transactionNotifications;
    }

    if (securityNotifications !== undefined) {
      settings.securityNotifications =
        securityNotifications;
    }

    if (biometricEnabled !== undefined) {
      settings.biometricEnabled = biometricEnabled;
    }

    if (darkMode !== undefined) {
      settings.darkMode = darkMode;
    }

    if (currency !== undefined) {
      settings.currency = currency;
    }

    if (language !== undefined) {
      settings.language = language;
    }

    settings.updatedAt = new Date();

    await settings.save();

    return res.status(200).json({
      success: true,
      message: "Settings updated successfully",
      settings
    });
  } catch (error) {
    console.error("Update settings error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error while updating settings"
    });
  }
};

module.exports = {
  getSettings,
  updateSettings
};