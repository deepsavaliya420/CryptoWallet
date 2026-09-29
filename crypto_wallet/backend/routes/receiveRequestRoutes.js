const express = require("express");

const {
  getReceiveRequests,
  createReceiveRequest,
  updateReceiveRequest,
  approveReceiveRequest,
  denyReceiveRequest,
  deleteReceiveRequest,
  clearReceiveRequests
} = require("../controllers/receiveRequestController");

const authMiddleware =
  require("../middleware/authMiddleware");

const router = express.Router();

router.get(
  "/",
  authMiddleware,
  getReceiveRequests
);

router.post(
  "/",
  authMiddleware,
  createReceiveRequest
);

router.put(
  "/:requestId/approve",
  authMiddleware,
  approveReceiveRequest
);

router.put(
  "/:requestId/deny",
  authMiddleware,
  denyReceiveRequest
);

router.put(
  "/:requestId",
  authMiddleware,
  updateReceiveRequest
);

router.delete(
  "/",
  authMiddleware,
  clearReceiveRequests
);

router.delete(
  "/:requestId",
  authMiddleware,
  deleteReceiveRequest
);

module.exports = router;