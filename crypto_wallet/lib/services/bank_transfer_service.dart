import '../models/bank_account.dart';
import '../services/transaction_service.dart';
import '../services/wallet_service.dart';

class BankTransferService {
  static Future<void> depositINR({
    required double amount,
    required BankAccount bankAccount,
  }) async {
    if (amount <= 0) {
      throw StateError(
        'Deposit amount must be greater than zero.',
      );
    }

    await WalletService.addCurrency(
      currency: 'INR',
      amount: amount,
    );

    await TransactionService.createTransaction(
      type: 'Deposit',
      asset: 'INR',
      network: 'Bank',
      amount: amount,
      value: WalletService.toUsdValue(
        amount: amount,
        currency: 'INR',
      ),
      from: bankAccount.bankName,
      to: 'My Wallet',
    );
  }

  static Future<void> withdrawINR({
    required double amount,
    required BankAccount bankAccount,
  }) async {
    if (amount <= 0) {
      throw StateError(
        'Withdrawal amount must be greater than zero.',
      );
    }

    await WalletService.subtractCurrency(
      currency: 'INR',
      amount: amount,
    );

    await TransactionService.createTransaction(
      type: 'Withdrawal',
      asset: 'INR',
      network: 'Bank',
      amount: amount,
      value: WalletService.toUsdValue(
        amount: amount,
        currency: 'INR',
      ),
      from: 'My Wallet',
      to: bankAccount.bankName,
    );
  }
}