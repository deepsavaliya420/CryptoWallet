import 'package:flutter/material.dart';

import '../models/bank_account.dart';
import '../services/bank_service.dart';

class BankDetailsScreen extends StatefulWidget {
  const BankDetailsScreen({
    super.key,
  });

  @override
  State<BankDetailsScreen> createState() =>
      _BankDetailsScreenState();
}

class _BankDetailsScreenState
    extends State<BankDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _holderController =
  TextEditingController();

  final _bankController =
  TextEditingController();

  final _accountController =
  TextEditingController();

  final _ifscController =
  TextEditingController();

  String _accountType = 'Savings';

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _loadBankDetails();
  }

  Future<void> _loadBankDetails() async {
    final account =
    await BankService.getBankAccount();

    if (!mounted) return;

    if (account != null) {
      _holderController.text =
          account.accountHolderName;

      _bankController.text =
          account.bankName;

      _accountController.text =
          account.accountNumber;

      _ifscController.text =
          account.ifscCode;

      _accountType =
          account.accountType;
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _holderController.dispose();
    _bankController.dispose();
    _accountController.dispose();
    _ifscController.dispose();

    super.dispose();
  }

  Future<void> _saveDetails() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final account = BankAccount(
        accountHolderName:
        _holderController.text.trim(),
        bankName:
        _bankController.text.trim(),
        accountNumber:
        _accountController.text.trim(),
        ifscCode:
        _ifscController.text
            .trim()
            .toUpperCase(),
        accountType: _accountType,
      );

      await BankService.saveBankAccount(
        account,
      );

      if (!mounted) return;

      Navigator.pop(
        context,
        true,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
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

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bank Details',
          style: TextStyle(
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
              Container(
                padding:
                const EdgeInsets.all(16),
                decoration:
                BoxDecoration(
                  color: Theme.of(
                    context,
                  )
                      .colorScheme
                      .primaryContainer,
                  borderRadius:
                  BorderRadius.circular(
                    16,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons
                          .account_balance_outlined,
                      color: Theme.of(
                        context,
                      )
                          .colorScheme
                          .onPrimaryContainer,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: Text(
                        'Add your bank account once. The same account can be used for INR deposits and withdrawals.',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          )
                              .colorScheme
                              .onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              TextFormField(
                controller:
                _holderController,
                textCapitalization:
                TextCapitalization
                    .words,
                decoration:
                const InputDecoration(
                  labelText:
                  'Account Holder Name',
                  prefixIcon: Icon(
                    Icons.person_outline,
                  ),
                  border:
                  OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value
                          .trim()
                          .isEmpty) {
                    return 'Enter account holder name';
                  }

                  if (value.trim().length <
                      3) {
                    return 'Enter a valid name';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 16,
              ),

              TextFormField(
                controller:
                _bankController,
                textCapitalization:
                TextCapitalization
                    .words,
                decoration:
                const InputDecoration(
                  labelText: 'Bank Name',
                  prefixIcon: Icon(
                    Icons.account_balance,
                  ),
                  border:
                  OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value
                          .trim()
                          .isEmpty) {
                    return 'Enter bank name';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 16,
              ),

              TextFormField(
                controller:
                _accountController,
                keyboardType:
                TextInputType.number,
                decoration:
                const InputDecoration(
                  labelText:
                  'Account Number',
                  prefixIcon: Icon(
                    Icons.numbers,
                  ),
                  border:
                  OutlineInputBorder(),
                ),
                validator: (value) {
                  final text =
                      value?.trim() ??
                          '';

                  if (text.isEmpty) {
                    return 'Enter account number';
                  }

                  if (!RegExp(
                    r'^\d{9,18}$',
                  ).hasMatch(text)) {
                    return 'Account number must contain 9 to 18 digits';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 16,
              ),

              TextFormField(
                controller:
                _ifscController,
                textCapitalization:
                TextCapitalization
                    .characters,
                maxLength: 11,
                decoration:
                const InputDecoration(
                  labelText:
                  'IFSC Code',
                  prefixIcon: Icon(
                    Icons.code,
                  ),
                  border:
                  OutlineInputBorder(),
                  counterText: '',
                ),
                validator: (value) {
                  final text =
                      value
                          ?.trim()
                          .toUpperCase() ??
                          '';

                  if (text.isEmpty) {
                    return 'Enter IFSC code';
                  }

                  if (!RegExp(
                    r'^[A-Z]{4}0[A-Z0-9]{6}$',
                  ).hasMatch(text)) {
                    return 'Enter a valid 11-character IFSC code';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 16,
              ),

              DropdownButtonFormField<
                  String>(
                initialValue:
                _accountType,
                decoration:
                const InputDecoration(
                  labelText:
                  'Account Type',
                  prefixIcon: Icon(
                    Icons.credit_card,
                  ),
                  border:
                  OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Savings',
                    child:
                    Text('Savings'),
                  ),
                  DropdownMenuItem(
                    value: 'Current',
                    child:
                    Text('Current'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _accountType =
                        value;
                  });
                },
              ),

              const SizedBox(
                height: 26,
              ),

              SizedBox(
                height: 52,
                child:
                FilledButton.icon(
                  onPressed:
                  _isSaving
                      ? null
                      : _saveDetails,
                  icon: _isSaving
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(
                    Icons
                        .save_outlined,
                  ),
                  label: Text(
                    _isSaving
                        ? 'Saving...'
                        : 'Save Bank Details',
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