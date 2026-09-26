const User = require("../models/User");

const getProfile = async (req, res) => {
  try {
    const user = await User.findOne({
      userId: req.user.userId
    }).select("-passwordHash");

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found"
      });
    }

    return res.status(200).json({
      success: true,
      user
    });
  } catch (error) {
    console.error("Get profile error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error while fetching profile"
    });
  }
};

const updateProfile = async (req, res) => {
  try {
    const {
      fullName,
      location,
      phone
    } = req.body;

    const user = await User.findOne({
      userId: req.user.userId
    });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found"
      });
    }

    if (fullName !== undefined) {
      user.fullName = fullName;
    }

    if (location !== undefined) {
      user.location = location;
    }

    if (phone !== undefined) {
      user.phone = phone;
    }

    await user.save();

    return res.status(200).json({
      success: true,
      message: "Profile updated successfully",
      user: {
        userId: user.userId,
        fullName: user.fullName,
        email: user.email,
        location: user.location,
        phone: user.phone,
        walletAddress: user.walletAddress
      }
    });
  } catch (error) {
    console.error("Update profile error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error while updating profile"
    });
  }
};

module.exports = {
  getProfile,
  updateProfile
};