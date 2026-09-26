class BankAccount {
  final String bankAccountId;
  final String accountHolderName;
  final String bankName;
  final String accountNumber;
  final String ifscCode;
  final String accountType;

  const BankAccount({
    this.bankAccountId = '',
    required this.accountHolderName,
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
    required this.accountType,
  });

  BankAccount copyWith({
    String? bankAccountId,
    String? accountHolderName,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    String? accountType,
  }) {
    return BankAccount(
      bankAccountId:
      bankAccountId ?? this.bankAccountId,
      accountHolderName:
      accountHolderName ?? this.accountHolderName,
      bankName:
      bankName ?? this.bankName,
      accountNumber:
      accountNumber ?? this.accountNumber,
      ifscCode:
      ifscCode ?? this.ifscCode,
      accountType:
      accountType ?? this.accountType,
    );
  }
}