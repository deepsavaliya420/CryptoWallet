import 'package:flutter/material.dart';

import '../models/bank_account.dart';
import '../services/bank_transfer_service.dart';
import '../services/wallet_service.dart';

class INRTransferScreen extends StatefulWidget {
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
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();

  double _currentBalance = 0.0;

  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    _loadBalance();
  }

  Future<void> _loadBalance() async {
    try {
      final balance =
      await WalletService.getINRBalance();

      if (!mounted) {
        return;
      }

      setState(() {
        _currentBalance = balance;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      _showError(_cleanError(error));
    }
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

  double get _resultingBalance {
    if (widget.isDeposit) {
      return _currentBalance + _amount;
    }

    return _currentBalance - _amount;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isProcessing = true;
    });

    try {
      if (widget.isDeposit) {
        await BankTransferService.depositINR(
          amount: _amount,
          bankAccount: widget.bankAccount,
        );
      } else {
        await BankTransferService.withdrawINR(
          amount: _amount,
          bankAccount: widget.bankAccount,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isProcessing = false;
      });

      _showError(_cleanError(error));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('Bad state: ', '');
  }

  String _maskedAccountNumber(String number) {
    if (number.length <= 4) {
      return number;
    }

    return '•••• ${number.substring(number.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final bool isDeposit = widget.isDeposit;

    final String title =
    isDeposit ? 'Deposit INR' : 'Withdraw INR';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
        ),
      )
          : SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              18,
              8,
              18,
              30,
            ),
            children: [
              _buildHeroSection(
                context,
                isDeposit,
              ),

              const SizedBox(height: 22),

              _buildBankCard(context),

              const SizedBox(height: 22),

              _buildAmountSection(context),

              const SizedBox(height: 18),

              _buildSummaryCard(context),

              const SizedBox(height: 20),

              _buildInfoCard(
                context,
                isDeposit,
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed:
                  _isProcessing
                      ? null
                      : _submit,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(17),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration:
                    const Duration(
                      milliseconds: 180,
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                      key: ValueKey(
                        'loading',
                      ),
                      width: 22,
                      height: 22,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color:
                        Colors.white,
                      ),
                    )
                        : Row(
                      key: const ValueKey(
                        'button',
                      ),
                      mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                      children: [
                        Icon(
                          isDeposit
                              ? Icons
                              .add_circle_outline_rounded
                              : Icons
                              .account_balance_outlined,
                        ),
                        const SizedBox(
                          width: 9,
                        ),
                        Text(
                          isDeposit
                              ? 'Deposit INR'
                              : 'Withdraw INR',
                          style:
                          const TextStyle(
                            fontSize: 15,
                            fontWeight:
                            FontWeight.w800,
                          ),
                        ),
                      ],
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

  Widget _buildHeroSection(
      BuildContext context,
      bool isDeposit,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final Color accent = isDeposit
        ? Colors.green.shade600
        : colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(
              alpha: 0.82,
            ),
            colorScheme.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(
              alpha: 0.20,
            ),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.16,
              ),
              borderRadius:
              BorderRadius.circular(16),
            ),
            child: Icon(
              isDeposit
                  ? Icons
                  .account_balance_wallet_outlined
                  : Icons
                  .account_balance_outlined,
              color: Colors.white,
              size: 27,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            isDeposit
                ? 'Add money to your wallet'
                : 'Transfer money to your bank',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            isDeposit
                ? 'Deposit INR directly into your ChainVault wallet.'
                : 'Withdraw INR from your wallet to your linked bank account.',
            style: TextStyle(
              color: Colors.white.withValues(
                alpha: 0.78,
              ),
              fontSize: 13,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 19),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.13,
              ),
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 17,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  'Available ₹${_currentBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankCard(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'Linked Bank Account',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 11),

        Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius:
            BorderRadius.circular(20),
            border: Border.all(
              color:
              colorScheme.outlineVariant
                  .withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.65),
                  borderRadius:
                  BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.account_balance_rounded,
                  color: colorScheme
                      .onPrimaryContainer,
                  size: 23,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.bankAccount.bankName,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '${widget.bankAccount.accountType} • ${_maskedAccountNumber(widget.bankAccount.accountNumber)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme
                            .onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      widget.bankAccount
                          .accountHolderName,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green
                      .withValues(alpha: 0.10),
                  borderRadius:
                  BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration:
                      const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Linked',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                        FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter Amount',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 11),

        TextFormField(
          controller: _amountController,
          keyboardType:
          const TextInputType.numberWithOptions(
            decimal: true,
          ),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            labelText: 'INR Amount',
            hintText: 'Enter amount',
            prefixIcon: const Icon(
              Icons.currency_rupee_rounded,
            ),
            suffixText: 'INR',
            suffixStyle: TextStyle(
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
            filled: true,
            fillColor:
            colorScheme.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(17),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(17),
              borderSide: BorderSide(
                color: colorScheme
                    .outlineVariant
                    .withValues(alpha: 0.35),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(17),
              borderSide: BorderSide(
                color: colorScheme.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(17),
              borderSide: const BorderSide(
                color: Colors.red,
              ),
            ),
            focusedErrorBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(17),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1.5,
              ),
            ),
          ),
          onChanged: (_) {
            setState(() {});
          },
          validator: (value) {
            final amount = double.tryParse(
              value?.trim() ?? '',
            );

            if (amount == null) {
              return 'Enter a valid amount';
            }

            if (amount <= 0) {
              return 'Amount must be greater than zero';
            }

            if (!widget.isDeposit &&
                amount > _currentBalance) {
              return 'Insufficient INR balance';
            }

            return null;
          },
        ),

        const SizedBox(height: 10),

        Text(
          widget.isDeposit
              ? 'The amount will be added to your INR wallet balance.'
              : 'The amount will be deducted from your INR wallet balance.',
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant
              .withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 19,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              const Text(
                'Transfer Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          _SummaryRow(
            title: 'Amount',
            value:
            '₹${_amount.toStringAsFixed(2)}',
          ),

          _SummaryRow(
            title: 'Bank',
            value:
            widget.bankAccount.bankName,
          ),

          _SummaryRow(
            title: 'Account',
            value: _maskedAccountNumber(
              widget.bankAccount.accountNumber,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
            ),
            child: Divider(
              color: colorScheme.outlineVariant
                  .withValues(alpha: 0.45),
            ),
          ),

          _SummaryRow(
            title: widget.isDeposit
                ? 'New INR Balance'
                : 'Remaining INR Balance',
            value:
            '₹${_resultingBalance.toStringAsFixed(2)}',
            bold: true,
            valueColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context,
      bool isDeposit,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer
            .withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: colorScheme
                .onPrimaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isDeposit
                  ? 'Your deposit will be recorded as an INR wallet transaction after it is processed.'
                  : 'Your withdrawal will be recorded as an INR wallet transaction after it is processed.',
              style: TextStyle(
                fontSize: 11.5,
                height: 1.45,
                color: colorScheme
                    .onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String title;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _SummaryRow({
    required this.title,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12.5,
                color:
                colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow:
              TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: bold
                    ? FontWeight.w800
                    : FontWeight.w600,
                color: valueColor ??
                    colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}