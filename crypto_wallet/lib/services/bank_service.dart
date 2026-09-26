import '../models/bank_account.dart';
import 'api_service.dart';

class BankService {
  static BankAccount? _currentBankAccount;

  static Future<BankAccount?> getBankAccount() async {
    try {
      final response = await ApiService.get('/bank');

      if (response['success'] != true) {
        return null;
      }

      final List<dynamic> bankAccounts =
          response['bankAccounts'] ?? [];

      if (bankAccounts.isEmpty) {
        _currentBankAccount = null;
        return null;
      }

      final accountData = bankAccounts.first;

      _currentBankAccount = BankAccount(
        accountHolderName:
        accountData['accountHolderName'] ?? '',
        bankName:
        accountData['bankName'] ?? '',
        accountNumber:
        accountData['accountNumber'] ?? '',
        ifscCode:
        accountData['ifscCode'] ?? '',
        accountType:
        accountData['accountType'] ?? 'Savings',
      );

      return _currentBankAccount;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> saveBankAccount(
      BankAccount account,
      ) async {
    try {
      final response = await ApiService.post(
        '/bank',
        {
          'accountHolderName':
          account.accountHolderName,
          'bankName':
          account.bankName,
          'accountNumber':
          account.accountNumber,
          'ifscCode':
          account.ifscCode,
          'accountType':
          account.accountType,
          'isPrimary': true,
        },
      );

      if (response['success'] != true) {
        return false;
      }

      _currentBankAccount = account;

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateBankAccount(
      String bankAccountId,
      BankAccount account,
      ) async {
    try {
      final response = await ApiService.put(
        '/bank/$bankAccountId',
        {
          'accountHolderName':
          account.accountHolderName,
          'bankName':
          account.bankName,
          'accountNumber':
          account.accountNumber,
          'ifscCode':
          account.ifscCode,
          'accountType':
          account.accountType,
          'isPrimary': true,
        },
      );

      if (response['success'] != true) {
        return false;
      }

      _currentBankAccount = account;

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteBankAccount(
      String bankAccountId,
      ) async {
    try {
      final response = await ApiService.delete(
        '/bank/$bankAccountId',
      );

      if (response['success'] != true) {
        return false;
      }

      _currentBankAccount = null;

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> clearBankAccount() async {
    _currentBankAccount = null;
  }
}