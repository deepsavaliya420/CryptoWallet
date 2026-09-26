const express = require("express");

const {
  getBankAccounts,
  addBankAccount,
  updateBankAccount,
  deleteBankAccount
} = require("../controllers/bankController");

const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

router.get("/", authMiddleware, getBankAccounts);

router.post("/", authMiddleware, addBankAccount);

router.put("/:bankAccountId", authMiddleware, updateBankAccount);

router.delete("/:bankAccountId", authMiddleware, deleteBankAccount);

module.exports = router;