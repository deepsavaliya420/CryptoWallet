import 'package:flutter/material.dart';

import '../models/bank_account.dart';
import '../services/bank_transfer_service.dart';
import '../services/wallet_service.dart';

class INRTransferScreen
    extends StatefulWidget {
  final bool isDeposit;
  final BankAccount bankAccount;

  const INRTransferScreen({
    required this.isDeposit,
    required this.bankAccount,
    super.key,
  });

  @override
  State<INRTransferScreen> createState() =>
      _INRTransferScreenState();
}

class _INRTransferScreenState
    extends State<INRTransferScreen> {
  final _formKey =
  GlobalKey<FormState>();

  final _amountController =
  TextEditingController();

  double _currentBalance = 0.0;

  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final balance =
    await WalletService.getINRBalance();

    if (!mounted) return;

    setState(() {
      _currentBalance = balance;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();

    super.dispose();
  }

  double get _amount {
    return double.tryParse(
      _amountController.text.trim(),
    ) ??
        0.0;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      if (widget.isDeposit) {
        await BankTransferService
            .depositINR(
          amount: _amount,
          bankAccount:
          widget.bankAccount,
        );
      } else {
        await BankTransferService
            .withdrawINR(
          amount: _amount,
          bankAccount:
          widget.bankAccount,
        );
      }

      if (!mounted) return;

      Navigator.pop(
        context,
        true,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            _cleanError(error),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst(
      'Exception: ',
      '',
    )
        .replaceFirst(
      'Bad state: ',
      '',
    );
  }

  String _maskedAccountNumber(
      String number) {
    if (number.length <= 4) {
      return number;
    }

    return '•••• ${number.substring(number.length - 4)}';
  }

  @override
  Widget build(
      BuildContext context) {
    final colorScheme =
        Theme.of(context)
            .colorScheme;

    final title = widget.isDeposit
        ? 'Deposit INR'
        : 'Withdraw INR';

    final buttonText =
    widget.isDeposit
        ? 'Deposit INR'
        : 'Withdraw INR';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding:
            const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding:
                  const EdgeInsets.all(
                    18,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                            colorScheme
                                .primaryContainer,
                            child: Icon(
                              Icons
                                  .account_balance,
                              color: colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                Text(
                                  widget
                                      .bankAccount
                                      .bankName,
                                  style:
                                  const TextStyle(
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                    fontSize:
                                    17,
                                  ),
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  '${widget.bankAccount.accountType} • ${_maskedAccountNumber(widget.bankAccount.accountNumber)}',
                                  style:
                                  TextStyle(
                                    color: colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      Text(
                        'Current INR balance',
                        style: TextStyle(
                          color: colorScheme
                              .onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        '₹${_currentBalance.toStringAsFixed(2)}',
                        style:
                        const TextStyle(
                          fontSize: 25,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              Text(
                widget.isDeposit
                    ? 'Enter amount to add to your INR asset.'
                    : 'Enter amount to transfer from your INR asset to your bank account.',
                style:
                const TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              TextFormField(
                controller:
                _amountController,
                keyboardType:
                const TextInputType
                    .numberWithOptions(
                  decimal: true,
                ),
                decoration:
                const InputDecoration(
                  labelText:
                  'INR Amount',
                  hintText:
                  'Example: 5000',
                  prefixIcon: Icon(
                    Icons.currency_rupee,
                  ),
                  suffixText: 'INR',
                  border:
                  OutlineInputBorder(),
                ),
                onChanged: (_) {
                  setState(() {});
                },
                validator: (value) {
                  final amount =
                  double.tryParse(
                    value?.trim() ??
                        '',
                  );

                  if (amount == null) {
                    return 'Enter a valid amount';
                  }

                  if (amount <= 0) {
                    return 'Amount must be greater than zero';
                  }

                  if (!widget.isDeposit &&
                      amount >
                          _currentBalance) {
                    return 'Insufficient INR balance';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 20,
              ),

              Card(
                color: colorScheme
                    .surfaceContainerHighest,
                child: Padding(
                  padding:
                  const EdgeInsets.all(
                    16,
                  ),
                  child: Column(
                    children: [
                      _SummaryRow(
                        title: 'Amount',
                        value:
                        '₹${_amount.toStringAsFixed(2)}',
                      ),
                      _SummaryRow(
                        title: 'Bank',
                        value: widget
                            .bankAccount
                            .bankName,
                      ),
                      _SummaryRow(
                        title: 'Account',
                        value:
                        _maskedAccountNumber(
                          widget
                              .bankAccount
                              .accountNumber,
                        ),
                      ),
                      const Divider(
                        height: 24,
                      ),
                      _SummaryRow(
                        title: widget
                            .isDeposit
                            ? 'New INR Balance'
                            : 'Remaining INR Balance',
                        value:
                        '₹${(widget.isDeposit ? _currentBalance + _amount : _currentBalance - _amount).toStringAsFixed(2)}',
                        bold: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              SizedBox(
                height: 52,
                child:
                FilledButton.icon(
                  onPressed:
                  _isProcessing
                      ? null
                      : _submit,
                  icon: _isProcessing
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : Icon(
                    widget.isDeposit
                        ? Icons
                        .add_circle_outline
                        : Icons
                        .account_balance_outlined,
                  ),
                  label: Text(
                    _isProcessing
                        ? 'Processing...'
                        : buttonText,
                    style:
                    const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow
    extends StatelessWidget {
  final String title;
  final String value;
  final bool bold;

  const _SummaryRow({
    required this.title,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(
      BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title),
          ),
          Text(
            value,
            textAlign:
            TextAlign.end,
            style: TextStyle(
              fontWeight: bold
                  ? FontWeight.bold
                  : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}