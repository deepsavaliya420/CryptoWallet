const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
require("dotenv").config();

const authRoutes = require("./routes/authRoutes");
const userRoutes = require("./routes/userRoutes");
const walletRoutes = require("./routes/walletRoutes");
const transactionRoutes = require("./routes/transactionRoutes");
const swapRoutes = require("./routes/swapRoutes");
const bankRoutes = require("./routes/bankRoutes");
const receiveRequestRoutes = require("./routes/receiveRequestRoutes");
const notificationRoutes = require("./routes/notificationRoutes");
const userSettingsRoutes = require("./routes/userSettingsRoutes");
const p2pOfferRoutes = require("./routes/p2pOfferRoutes");
const p2pOrderRoutes = require("./routes/p2pOrderRoutes");

const app = express();

app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.json({
    success: true,
    message: "Crypto Wallet API is running"
  });
});

app.use("/api/auth", authRoutes);
app.use("/api/user", userRoutes);
app.use("/api/wallet", walletRoutes);
app.use("/api/transactions", transactionRoutes);
app.use("/api/swaps", swapRoutes);
app.use("/api/bank", bankRoutes);
app.use("/api/receive-requests", receiveRequestRoutes);
app.use("/api/notifications", notificationRoutes);
app.use("/api/settings", userSettingsRoutes);
app.use("/api/p2p/offers", p2pOfferRoutes);
app.use("/api/p2p/orders", p2pOrderRoutes);

mongoose
  .connect(process.env.MONGO_URI)
  .then(() => {
    console.log("MongoDB connected successfully");

    app.listen(process.env.PORT, () => {
      console.log(`Server running on port ${process.env.PORT}`);
    });
  })
  .catch((error) => {
    console.error("MongoDB connection failed:", error.message);
  });