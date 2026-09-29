import 'package:flutter/material.dart';

import '../services/swap_service.dart';
import '../services/transaction_service.dart';
import '../services/wallet_service.dart';

class SwapScreen extends StatefulWidget {
  const SwapScreen({
    super.key,
  });

  @override
  State<SwapScreen> createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen> {
  final TextEditingController _amountController =
  TextEditingController();

  String _fromCurrency = 'USD';
  String _toCurrency = 'INR';

  String _fromNetwork = 'TRC-20';
  String _toNetwork = 'ERC-20';

  double _totalBalance = 0;
  double _receivedAmount = 0;
  double _exchangeRate = 0;
  double _fee = 0;

  bool _isLoading = true;
  bool _isSwapping = false;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD WALLET
  // ============================================================

  Future<void> _loadWallet() async {
    try {
      final balance =
      await WalletService.getTotalBalance();

      if (!mounted) return;

      setState(() {
        _totalBalance = balance;
        _isLoading = false;
      });

      _calculatePreview();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        _cleanError(error),
        isError: true,
      );
    }
  }

  // ============================================================
  // AMOUNT CHANGE
  // ============================================================

  void _onAmountChanged(String value) {
    _calculatePreview();
  }

  // ============================================================
  // CALCULATE PREVIEW
  // ============================================================

  void _calculatePreview() {
    final amount = double.tryParse(
      _amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      if (!mounted) return;

      setState(() {
        _receivedAmount = 0;
        _exchangeRate = 0;
        _fee = 0;
      });

      return;
    }

    try {
      final rate = SwapService.getExchangeRate(
        fromCurrency: _fromCurrency,
        toCurrency: _toCurrency,
      );

      final fee = SwapService.calculateFee(amount);

      final received =
      SwapService.calculateReceivedAmount(
        fromAmount: amount,
        fromCurrency: _fromCurrency,
        toCurrency: _toCurrency,
      );

      if (!mounted) return;

      setState(() {
        _exchangeRate = rate;
        _fee = fee;
        _receivedAmount = received;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _receivedAmount = 0;
        _exchangeRate = 0;
        _fee = 0;
      });
    }
  }

  // ============================================================
  // MAX
  // ============================================================

  Future<void> _useMaximum() async {
    try {
      if (_fromCurrency == 'USD') {
        _amountController.text =
            _totalBalance.toStringAsFixed(2);
      } else {
        final balance =
        await WalletService.getCurrencyBalance(
          _fromCurrency,
        );

        _amountController.text =
            _formatInputAmount(balance);
      }

      _calculatePreview();
    } catch (error) {
      _showMessage(
        _cleanError(error),
        isError: true,
      );
    }
  }

  String _formatInputAmount(double amount) {
    if (amount == 0) {
      return '0';
    }

    return amount
        .toStringAsFixed(8)
        .replaceFirst(
      RegExp(r'\.?0+$'),
      '',
    );
  }

  // ============================================================
  // PERFORM SWAP
  // ============================================================

  Future<void> _performSwap() async {
    // Prevent duplicate submission immediately.
    if (_isSwapping) {
      return;
    }

    final amount = double.tryParse(
      _amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      _showMessage(
        'Enter a valid amount.',
        isError: true,
      );
      return;
    }

    if (_fromCurrency == _toCurrency &&
        _fromNetwork == _toNetwork) {
      _showMessage(
        'Source and destination cannot be the same.',
        isError: true,
      );
      return;
    }

    double sourceUsdValue;

    try {
      sourceUsdValue = SwapService.getUsdValue(
        amount: amount,
        currency: _fromCurrency,
      );
    } catch (error) {
      _showMessage(
        _cleanError(error),
        isError: true,
      );
      return;
    }

    if (sourceUsdValue >
        _totalBalance + 0.00000001) {
      _showMessage(
        'Insufficient wallet balance. '
            'Available value: '
            '\$${_totalBalance.toStringAsFixed(2)}.',
        isError: true,
      );
      return;
    }

    if (_fromCurrency != 'USD') {
      final sourceBalance =
      await WalletService.getCurrencyBalance(
        _fromCurrency,
      );

      if (amount >
          sourceBalance + 0.00000001) {
        _showMessage(
          'Insufficient $_fromCurrency balance. '
              'Available: '
              '${_formatNumber(sourceBalance)} $_fromCurrency.',
          isError: true,
        );
        return;
      }
    }

    if (!mounted) return;

    // ==========================================================
    // IMPORTANT BUG FIX
    // Lock the swap BEFORE opening confirmation.
    // This prevents multiple confirmation/submission attempts.
    // ==========================================================

    setState(() {
      _isSwapping = true;
    });

    final confirmed = await _showConfirmation(
      amount,
      sourceUsdValue,
    );

    if (confirmed != true) {
      if (mounted) {
        setState(() {
          _isSwapping = false;
        });
      }

      return;
    }

    try {
      await WalletService.subtractCurrencyByUsdValue(
        currency: _fromCurrency,
        usdValue: sourceUsdValue,
      );

      await WalletService.addCurrency(
        currency: _toCurrency,
        amount: _receivedAmount,
      );

      final swap = await SwapService.createSwap(
        fromCurrency: _fromCurrency,
        fromNetwork: _fromNetwork,
        toCurrency: _toCurrency,
        toNetwork: _toNetwork,
        fromAmount: amount,
      );

      // Keep transaction creation.
      // This is used by the transaction/recent activity system.
      await TransactionService.createSwapTransaction(
        fromCurrency: swap.fromCurrency,
        fromNetwork: swap.fromNetwork,
        fromAmount: swap.fromAmount,
        toCurrency: swap.toCurrency,
        toNetwork: swap.toNetwork,
        toAmount: swap.toAmount,
        exchangeRate: swap.exchangeRate,
      );

      final newBalance =
      await WalletService.getTotalBalance();

      if (!mounted) return;

      setState(() {
        _totalBalance = newBalance;
      });

      await _showCompletedDialog(
        fromAmount: swap.fromAmount,
        fromCurrency: swap.fromCurrency,
        fromNetwork: swap.fromNetwork,
        toAmount: swap.toAmount,
        toCurrency: swap.toCurrency,
        toNetwork: swap.toNetwork,
        rate: swap.exchangeRate,
        id: swap.id,
      );

      if (!mounted) return;

      Navigator.pop(
        context,
        true,
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        _cleanError(error),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSwapping = false;
        });
      }
    }
  }

  // ============================================================
  // CONFIRMATION
  // ============================================================

  Future<bool?> _showConfirmation(
      double amount,
      double usdValue,
      ) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colorScheme =
            Theme.of(dialogContext).colorScheme;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.swap_horiz_rounded,
              ),
              SizedBox(width: 10),
              Text(
                'Confirm Swap',
                style: TextStyle(
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogRow(
                dialogContext,
                'You swap',
                '${_formatNumber(amount)} '
                    '$_fromCurrency',
              ),
              _dialogRow(
                dialogContext,
                'You receive',
                '${_formatNumber(_receivedAmount)} '
                    '$_toCurrency',
                valueColor:
                colorScheme.primary,
              ),
              _dialogRow(
                dialogContext,
                'Rate',
                '1 $_fromCurrency = '
                    '${_formatNumber(_exchangeRate)} '
                    '$_toCurrency',
              ),
              _dialogRow(
                dialogContext,
                'Network',
                '$_fromNetwork → $_toNetwork',
              ),
              _dialogRow(
                dialogContext,
                'USD value',
                '\$${usdValue.toStringAsFixed(2)}',
              ),
              _dialogRow(
                dialogContext,
                'Fee',
                '${_formatNumber(_fee)} '
                    '$_fromCurrency',
                isLast: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              icon: const Icon(
                Icons.check_rounded,
                size: 18,
              ),
              label: const Text(
                'Confirm',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // DIALOG ROW
  // ============================================================

  Widget _dialogRow(
      BuildContext context,
      String title,
      String value, {
        Color? valueColor,
        bool isLast = false,
      }) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 11,
      ),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
          bottom: BorderSide(
            color: colorScheme
                .outlineVariant
                .withValues(alpha: 0.35),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme
                    .onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight:
                FontWeight.w700,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMPLETED DIALOG
  // ============================================================

  Future<void> _showCompletedDialog({
    required double fromAmount,
    required String fromCurrency,
    required String fromNetwork,
    required double toAmount,
    required String toCurrency,
    required String toNetwork,
    required double rate,
    required String id,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final colorScheme =
            Theme.of(dialogContext).colorScheme;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(25),
          ),
          contentPadding:
          const EdgeInsets.fromLTRB(
            22,
            24,
            22,
            10,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.green
                      .withValues(alpha: 0.11),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Swap Completed',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your wallet exchange was completed successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme
                      .onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              _completedAmountCard(
                context: dialogContext,
                label: 'You Swapped',
                amount:
                '${_formatNumber(fromAmount)} '
                    '$fromCurrency',
                network: fromNetwork,
                icon:
                Icons.arrow_upward_rounded,
              ),
              const SizedBox(height: 8),
              Icon(
                Icons
                    .keyboard_double_arrow_down_rounded,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 8),
              _completedAmountCard(
                context: dialogContext,
                label: 'You Received',
                amount:
                '${_formatNumber(toAmount)} '
                    '$toCurrency',
                network: toNetwork,
                icon:
                Icons.arrow_downward_rounded,
                highlighted: true,
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme
                      .surfaceContainerLow,
                  borderRadius:
                  BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      'Exchange Rate',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '1 $fromCurrency = '
                          '${_formatNumber(rate)} '
                          '$toCurrency',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'ID: $id',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 8.5,
                  color: colorScheme
                      .onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                  );
                },
                child: const Text(
                  'Done',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // COMPLETED AMOUNT CARD
  // ============================================================

  Widget _completedAmountCard({
    required BuildContext context,
    required String label,
    required String amount,
    required String network,
    required IconData icon,
    bool highlighted = false,
  }) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: highlighted
            ? colorScheme.primaryContainer
            : colorScheme
            .surfaceContainerLow,
        borderRadius:
        BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: highlighted
                  ? colorScheme.primary
                  : colorScheme
                  .surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: highlighted
                  ? colorScheme.onPrimary
                  : colorScheme
                  .onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9.5,
                    color: colorScheme
                        .onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  network,
                  style: TextStyle(
                    fontSize: 9,
                    color: colorScheme
                        .onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CURRENCY DROPDOWN
  // ============================================================

  Widget _currencyDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Currency',
        prefixIcon: Icon(
          Icons.currency_exchange_rounded,
          color: colorScheme.primary,
        ),
        filled: true,
        fillColor:
        colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(15),
          borderSide: BorderSide(
            color: colorScheme
                .outlineVariant
                .withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(15),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1.5,
          ),
        ),
      ),
      items: SwapService.currencies
          .map(
            (currency) =>
            DropdownMenuItem<String>(
              value: currency,
              child: Text(
                currency,
                style: const TextStyle(
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),
      )
          .toList(),
      onChanged: onChanged,
    );
  }

  // ============================================================
  // NETWORK DROPDOWN
  // ============================================================

  Widget _networkDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Network',
        prefixIcon: Icon(
          Icons.lan_outlined,
          color: colorScheme.primary,
        ),
        filled: true,
        fillColor:
        colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(15),
          borderSide: BorderSide(
            color: colorScheme
                .outlineVariant
                .withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(15),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1.5,
          ),
        ),
      ),
      items: SwapService.networks
          .map(
            (network) =>
            DropdownMenuItem<String>(
              value: network,
              child: Text(
                network,
                style: const TextStyle(
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ),
      )
          .toList(),
      onChanged: onChanged,
    );
  }

  // ============================================================
  // REVERSE
  // ============================================================

  void _reverseCurrencies() {
    setState(() {
      final oldCurrency = _fromCurrency;
      final oldNetwork = _fromNetwork;

      _fromCurrency = _toCurrency;
      _toCurrency = oldCurrency;

      _fromNetwork = _toNetwork;
      _toNetwork = oldNetwork;
    });

    _calculatePreview();
  }

  // ============================================================
  // SOURCE CARD
  // ============================================================

  Widget _buildSourceCard() {
    final colorScheme =
        Theme.of(context).colorScheme;

    return _buildSwapSideCard(
      title: 'You Send',
      currency: _fromCurrency,
      network: _fromNetwork,
      currencyDropdown: _currencyDropdown(
        value: _fromCurrency,
        onChanged: (value) {
          if (value == null) return;

          setState(() {
            _fromCurrency = value;
          });

          _calculatePreview();
        },
      ),
      networkDropdown: _networkDropdown(
        value: _fromNetwork,
        onChanged: (value) {
          if (value == null) return;

          setState(() {
            _fromNetwork = value;
          });
        },
      ),
      child: TextField(
        controller: _amountController,
        onChanged: _onAmountChanged,
        keyboardType:
        const TextInputType.numberWithOptions(
          decimal: true,
        ),
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
        decoration: InputDecoration(
          hintText: '0.00',
          suffixText: _fromCurrency,
          suffixStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
          ),
          filled: true,
          fillColor:
          colorScheme.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(15),
            borderSide: BorderSide(
              color: colorScheme
                  .outlineVariant
                  .withValues(alpha: 0.45),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(15),
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 1.5,
            ),
          ),
          prefixIcon: const Icon(
            Icons.account_balance_wallet_outlined,
          ),
          suffixIcon: TextButton(
            onPressed: _useMaximum,
            child: const Text(
              'MAX',
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DESTINATION CARD
  // ============================================================

  Widget _buildDestinationCard() {
    return _buildSwapSideCard(
      title: 'You Receive',
      currency: _toCurrency,
      network: _toNetwork,
      currencyDropdown: _currencyDropdown(
        value: _toCurrency,
        onChanged: (value) {
          if (value == null) return;

          setState(() {
            _toCurrency = value;
          });

          _calculatePreview();
        },
      ),
      networkDropdown: _networkDropdown(
        value: _toNetwork,
        onChanged: (value) {
          if (value == null) return;

          setState(() {
            _toNetwork = value;
          });
        },
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .primaryContainer
              .withValues(alpha: 0.45),
          borderRadius:
          BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(
              Icons.savings_outlined,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _receivedAmount == 0
                    ? '0 $_toCurrency'
                    : '${_formatNumber(_receivedAmount)} '
                    '$_toCurrency',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SWAP SIDE CARD
  // ============================================================

  Widget _buildSwapSideCard({
    required String title,
    required String currency,
    required String network,
    required Widget currencyDropdown,
    required Widget networkDropdown,
    required Widget child,
  }) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius:
        BorderRadius.circular(21),
        border: Border.all(
          color: colorScheme
              .outlineVariant
              .withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow
                .withValues(alpha: 0.025),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme
                      .primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  title == 'You Send'
                      ? Icons
                      .arrow_upward_rounded
                      : Icons
                      .arrow_downward_rounded,
                  size: 18,
                  color: colorScheme
                      .onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ),
              Text(
                currency,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                  FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          currencyDropdown,
          const SizedBox(height: 10),
          networkDropdown,
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // ============================================================
  // PREVIEW
  // ============================================================

  Widget _buildPreviewCard() {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme
              .outlineVariant
              .withValues(alpha: 0.45),
        ),
      ),
      child: Column(
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
                'Swap Preview',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _previewRow(
            'Exchange rate',
            _exchangeRate == 0
                ? '-'
                : '1 $_fromCurrency = '
                '${_formatNumber(_exchangeRate)} '
                '$_toCurrency',
          ),
          const SizedBox(height: 10),
          _previewRow(
            'You send',
            _amountController.text.isEmpty
                ? '0 $_fromCurrency'
                : '${_amountController.text} '
                '$_fromCurrency',
          ),
          const SizedBox(height: 10),
          _previewRow(
            'You receive',
            '${_formatNumber(_receivedAmount)} '
                '$_toCurrency',
            bold: true,
            valueColor:
            colorScheme.primary,
          ),
          const SizedBox(height: 10),
          _previewRow(
            'Network',
            '$_fromNetwork → $_toNetwork',
          ),
          const SizedBox(height: 10),
          _previewRow(
            'Fee',
            '${_formatNumber(_fee)} '
                '$_fromCurrency',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PREVIEW ROW
  // ============================================================

  Widget _previewRow(
      String title,
      String value, {
        bool bold = false,
        Color? valueColor,
      }) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: colorScheme
                  .onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 11,
              fontWeight: bold
                  ? FontWeight.w800
                  : FontWeight.w600,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Swap',
          ),
        ),
        body: const Center(
          child:
          CircularProgressIndicator(),
        ),
      );
    }

    final colorScheme =
        Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Swap',
          style: TextStyle(
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            18,
            8,
            18,
            30,
          ),
          children: [
            // ==================================================
            // HERO
            // ==================================================

            Container(
              padding:
              const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin:
                  Alignment.topLeft,
                  end:
                  Alignment.bottomRight,
                  colors: [
                    colorScheme.primary,
                    colorScheme.secondary,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary
                        .withValues(alpha: 0.17),
                    blurRadius: 22,
                    offset:
                    const Offset(0, 9),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration:
                    BoxDecoration(
                      color: Colors.white
                          .withValues(
                        alpha: 0.15,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons
                          .swap_horiz_rounded,
                      color: Colors.white,
                      size: 31,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Text(
                          'Exchange Assets',
                          style: TextStyle(
                            color:
                            Colors.white,
                            fontSize: 18,
                            fontWeight:
                            FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Fast internal wallet exchange',
                          style: TextStyle(
                            color:
                            Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ==================================================
            // BALANCE
            // ==================================================

            Container(
              padding:
              const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius:
                BorderRadius.circular(19),
                border: Border.all(
                  color: colorScheme
                      .outlineVariant
                      .withValues(
                    alpha: 0.4,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration:
                    BoxDecoration(
                      color: colorScheme
                          .primaryContainer,
                      borderRadius:
                      BorderRadius.circular(
                        13,
                      ),
                    ),
                    child: Icon(
                      Icons
                          .account_balance_wallet_outlined,
                      color: colorScheme
                          .onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Text(
                          'Total Wallet Value',
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          '\$${_totalBalance.toStringAsFixed(2)}',
                          style:
                          const TextStyle(
                            fontSize: 18,
                            fontWeight:
                            FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons
                        .verified_outlined,
                    color:
                    colorScheme.primary,
                    size: 20,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ==================================================
            // SEND
            // ==================================================

            _buildSourceCard(),

            // ==================================================
            // REVERSE BUTTON
            // ==================================================

            Center(
              child: Container(
                margin:
                const EdgeInsets.symmetric(
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: colorScheme
                      .surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme
                        .outlineVariant
                        .withValues(
                      alpha: 0.5,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow
                          .withValues(
                        alpha: 0.06,
                      ),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child:
                IconButton(
                  tooltip:
                  'Reverse currencies',
                  onPressed:
                  _isSwapping
                      ? null
                      : _reverseCurrencies,
                  icon: const Icon(
                    Icons
                        .swap_vert_rounded,
                  ),
                ),
              ),
            ),

            // ==================================================
            // RECEIVE
            // ==================================================

            _buildDestinationCard(),

            const SizedBox(height: 18),

            // ==================================================
            // PREVIEW
            // ==================================================

            _buildPreviewCard(),

            const SizedBox(height: 14),

            // ==================================================
            // INFO
            // ==================================================

            Container(
              padding:
              const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme
                    .primaryContainer
                    .withValues(
                  alpha: 0.42,
                ),
                borderRadius:
                BorderRadius.circular(17),
              ),
              child: Row(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Icon(
                    Icons
                        .info_outline_rounded,
                    size: 19,
                    color: colorScheme
                        .primary,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'This is an internal wallet exchange. '
                          'No external blockchain transaction '
                          'is created.',
                      style: TextStyle(
                        fontSize: 10.5,
                        height: 1.4,
                        color: colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // SWAP BUTTON
            // ==================================================

            SizedBox(
              height: 55,
              child: FilledButton.icon(
                onPressed: _isSwapping
                    ? null
                    : _performSwap,
                icon: _isSwapping
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
                      .swap_horiz_rounded,
                ),
                label: Text(
                  _isSwapping
                      ? 'Processing Swap...'
                      : 'Swap Now',
                  style: const TextStyle(
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst(
      'Bad state: ',
      '',
    )
        .replaceFirst(
      'Exception: ',
      '',
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
      String message, {
        bool isError = false,
      }) {
    if (!mounted) return;

    final colorScheme =
        Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons
                  .error_outline_rounded
                  : Icons
                  .check_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor:
        isError
            ? colorScheme.error
            : null,
        behavior:
        SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // NUMBER FORMAT
  // ============================================================

  String _formatNumber(double value) {
    if (value.abs() >= 1000) {
      return value.toStringAsFixed(2);
    }

    if (value.abs() >= 1) {
      return value.toStringAsFixed(4);
    }

    return value.toStringAsFixed(8);
  }
}