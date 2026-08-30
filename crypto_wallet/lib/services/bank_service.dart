import 'package:shared_preferences/shared_preferences.dart';

import '../models/bank_account.dart';

class BankService {
  static const String _holderKey = 'bank_account_holder';
  static const String _bankNameKey = 'bank_name';
  static const String _accountNumberKey = 'bank_account_number';
  static const String _ifscKey = 'bank_ifsc';
  static const String _accountTypeKey = 'bank_account_type';

  static Future<BankAccount?> getBankAccount() async {
    final prefs = await SharedPreferences.getInstance();

    final holder = prefs.getString(_holderKey);
    final bankName = prefs.getString(_bankNameKey);
    final accountNumber = prefs.getString(_accountNumberKey);
    final ifsc = prefs.getString(_ifscKey);
    final accountType = prefs.getString(_accountTypeKey);

    if (holder == null ||
        bankName == null ||
        accountNumber == null ||
        ifsc == null ||
        accountType == null) {
      return null;
    }

    return BankAccount(
      accountHolderName: holder,
      bankName: bankName,
      accountNumber: accountNumber,
      ifscCode: ifsc,
      accountType: accountType,
    );
  }

  static Future<void> saveBankAccount(
      BankAccount account) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _holderKey,
      account.accountHolderName,
    );

    await prefs.setString(
      _bankNameKey,
      account.bankName,
    );

    await prefs.setString(
      _accountNumberKey,
      account.accountNumber,
    );

    await prefs.setString(
      _ifscKey,
      account.ifscCode,
    );

    await prefs.setString(
      _accountTypeKey,
      account.accountType,
    );
  }

  static Future<void> clearBankAccount() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_holderKey);
    await prefs.remove(_bankNameKey);
    await prefs.remove(_accountNumberKey);
    await prefs.remove(_ifscKey);
    await prefs.remove(_accountTypeKey);
  }
}