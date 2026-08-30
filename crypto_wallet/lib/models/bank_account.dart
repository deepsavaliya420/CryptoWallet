class BankAccount {
  final String accountHolderName;
  final String bankName;
  final String accountNumber;
  final String ifscCode;
  final String accountType;

  const BankAccount({
    required this.accountHolderName,
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
    required this.accountType,
  });
}