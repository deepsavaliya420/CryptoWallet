const BankAccount = require("../models/BankAccount");

const generateBankAccountId = () => {
  return `BA-${Date.now()}-${Math.random()
    .toString(36)
    .substring(2, 8)
    .toUpperCase()}`;
};

const getBankAccounts = async (req, res) => {
  try {
    const bankAccounts = await BankAccount.find({
      userId: req.user.userId
    }).sort({
      createdAt: -1
    });

    return res.status(200).json({
      success: true,
      bankAccounts
    });
  } catch (error) {
    console.error("Get bank accounts error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error while fetching bank accounts"
    });
  }
};

const addBankAccount = async (req, res) => {
  try {
    const {
      accountHolderName,
      bankName,
      accountNumber,
      ifscCode,
      branchName,
      accountType,
      isPrimary
    } = req.body;

    if (
      !accountHolderName ||
      !bankName ||
      !accountNumber ||
      !ifscCode
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Account holder name, bank name, account number and IFSC code are required"
      });
    }

    if (isPrimary === true) {
      await BankAccount.updateMany(
        {
          userId: req.user.userId
        },
        {
          isPrimary: false
        }
      );
    }

    const bankAccount = await BankAccount.create({
      bankAccountId: generateBankAccountId(),
      userId: req.user.userId,
      accountHolderName,
      bankName,
      accountNumber,
      ifscCode,
      branchName: branchName || "",
      accountType: accountType || "Savings",
      isPrimary: isPrimary || false
    });

    return res.status(201).json({
      success: true,
      message: "Bank account added successfully",
      bankAccount
    });
  } catch (error) {
    console.error("Add bank account error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error while adding bank account"
    });
  }
};

const updateBankAccount = async (req, res) => {
  try {
    const { bankAccountId } = req.params;

    const {
      accountHolderName,
      bankName,
      accountNumber,
      ifscCode,
      branchName,
      accountType,
      isPrimary
    } = req.body;

    const bankAccount = await BankAccount.findOne({
      bankAccountId,
      userId: req.user.userId
    });

    if (!bankAccount) {
      return res.status(404).json({
        success: false,
        message: "Bank account not found"
      });
    }

    if (isPrimary === true) {
      await BankAccount.updateMany(
        {
          userId: req.user.userId,
          bankAccountId: { $ne: bankAccountId }
        },
        {
          isPrimary: false
        }
      );
    }

    if (accountHolderName !== undefined) {
      bankAccount.accountHolderName = accountHolderName;
    }

    if (bankName !== undefined) {
      bankAccount.bankName = bankName;
    }

    if (accountNumber !== undefined) {
      bankAccount.accountNumber = accountNumber;
    }

    if (ifscCode !== undefined) {
      bankAccount.ifscCode = ifscCode;
    }

    if (branchName !== undefined) {
      bankAccount.branchName = branchName;
    }

    if (accountType !== undefined) {
      bankAccount.accountType = accountType;
    }

    if (isPrimary !== undefined) {
      bankAccount.isPrimary = isPrimary;
    }

    await bankAccount.save();

    return res.status(200).json({
      success: true,
      message: "Bank account updated successfully",
      bankAccount
    });
  } catch (error) {
    console.error("Update bank account error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error while updating bank account"
    });
  }
};

const deleteBankAccount = async (req, res) => {
  try {
    const { bankAccountId } = req.params;

    const bankAccount = await BankAccount.findOneAndDelete({
      bankAccountId,
      userId: req.user.userId
    });

    if (!bankAccount) {
      return res.status(404).json({
        success: false,
        message: "Bank account not found"
      });
    }

    return res.status(200).json({
      success: true,
      message: "Bank account deleted successfully"
    });
  } catch (error) {
    console.error("Delete bank account error:", error);

    return res.status(500).json({
      success: false,
      message: "Server error while deleting bank account"
    });
  }
};

module.exports = {
  getBankAccounts,
  addBankAccount,
  updateBankAccount,
  deleteBankAccount
};