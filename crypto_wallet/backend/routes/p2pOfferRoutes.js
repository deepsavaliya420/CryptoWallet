const express = require("express");

const {
  getOffers,
  getMyOffers,
  createOffer,
  updateOffer,
  deleteOffer
} = require("../controllers/p2pOfferController");

const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

router.get("/", authMiddleware, getOffers);

router.get("/my", authMiddleware, getMyOffers);

router.post("/", authMiddleware, createOffer);

router.put("/:offerId", authMiddleware, updateOffer);

router.delete("/:offerId", authMiddleware, deleteOffer);

module.exports = router;