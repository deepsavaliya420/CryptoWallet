import 'package:flutter/material.dart';

import '../services/swap_service.dart';
import '../services/transaction_service.dart';
import '../services/wallet_service.dart';

class SwapScreen extends StatefulWidget {
  const SwapScreen({
    super.key,
  });

  @override
  State<SwapScreen> createState() =>
      _SwapScreenState();
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

      if (!mounted) {
        return;
      }

      setState(() {
        _totalBalance = balance;
        _isLoading = false;
      });

      _calculatePreview();
    } catch (error) {
      if (!mounted) {
        return;
      }

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
      if (!mounted) {
        return;
      }

      setState(() {
        _receivedAmount = 0;
        _exchangeRate = 0;
        _fee = 0;
      });

      return;
    }

    try {
      final rate =
      SwapService.getExchangeRate(
        fromCurrency: _fromCurrency,
        toCurrency: _toCurrency,
      );

      final fee =
      SwapService.calculateFee(
        amount,
      );

      final received =
      SwapService.calculateReceivedAmount(
        fromAmount: amount,
        fromCurrency: _fromCurrency,
        toCurrency: _toCurrency,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _exchangeRate = rate;
        _fee = fee;
        _receivedAmount = received;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

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
      sourceUsdValue =
          SwapService.getUsdValue(
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

    /*
     * ----------------------------------------------------------
     * Check total wallet value.
     * ----------------------------------------------------------
     */

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

    /*
     * ----------------------------------------------------------
     * If source is not USD, also make sure the actual
     * source currency balance is enough.
     * ----------------------------------------------------------
     */

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

    final confirmed =
    await _showConfirmation(
      amount,
      sourceUsdValue,
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isSwapping = true;
    });

    try {
      /*
       * --------------------------------------------------------
       * STEP 1
       *
       * Remove source value.
       *
       * USD is special because the original wallet does not
       * have a separate USD balance. Its USD value represents
       * the total portfolio value.
       * --------------------------------------------------------
       */

      await WalletService.subtractCurrencyByUsdValue(
        currency: _fromCurrency,
        usdValue: sourceUsdValue,
      );

      /*
       * --------------------------------------------------------
       * STEP 2
       *
       * Add destination currency.
       * --------------------------------------------------------
       */

      await WalletService.addCurrency(
        currency: _toCurrency,
        amount: _receivedAmount,
      );

      /*
       * --------------------------------------------------------
       * STEP 3
       *
       * Save swap history.
       * --------------------------------------------------------
       */

      final swap =
      await SwapService.createSwap(
        fromCurrency: _fromCurrency,
        fromNetwork: _fromNetwork,
        toCurrency: _toCurrency,
        toNetwork: _toNetwork,
        fromAmount: amount,
      );

      /*
       * --------------------------------------------------------
       * STEP 4
       *
       * Add Swap to Recent Transactions.
       * --------------------------------------------------------
       */

      await TransactionService.createSwapTransaction(
        fromCurrency: swap.fromCurrency,
        fromNetwork: swap.fromNetwork,
        fromAmount: swap.fromAmount,
        toCurrency: swap.toCurrency,
        toNetwork: swap.toNetwork,
        toAmount: swap.toAmount,
        exchangeRate: swap.exchangeRate,
      );

      /*
       * --------------------------------------------------------
       * STEP 5
       *
       * Refresh total wallet value.
       * --------------------------------------------------------
       */

      final newBalance =
      await WalletService.getTotalBalance();

      if (!mounted) {
        return;
      }

      setState(() {
        _totalBalance = newBalance;
      });

      /*
       * --------------------------------------------------------
       * STEP 6
       *
       * Show completed dialog.
       * --------------------------------------------------------
       */

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

      if (!mounted) {
        return;
      }

      /*
       * Returning true tells Home to refresh.
       */

      Navigator.pop(
        context,
        true,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

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
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Confirm Swap',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              _dialogRow(
                'You swap',
                '${_formatNumber(amount)} '
                    '$_fromCurrency',
              ),

              const SizedBox(
                height: 10,
              ),

              _dialogRow(
                'You receive',
                '${_formatNumber(_receivedAmount)} '
                    '$_toCurrency',
              ),

              const SizedBox(
                height: 10,
              ),

              _dialogRow(
                'Rate',
                '1 $_fromCurrency = '
                    '${_formatNumber(_exchangeRate)} '
                    '$_toCurrency',
              ),

              const SizedBox(
                height: 10,
              ),

              _dialogRow(
                'Network',
                '$_fromNetwork → $_toNetwork',
              ),

              const SizedBox(
                height: 10,
              ),

              _dialogRow(
                'USD value',
                '\$${usdValue.toStringAsFixed(2)}',
              ),

              const SizedBox(
                height: 10,
              ),

              _dialogRow(
                'Fee',
                '${_formatNumber(_fee)} '
                    '$_fromCurrency',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Confirm Swap',
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
      String title,
      String value,
      ) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        const SizedBox(
          width: 12,
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
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
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Swap Completed',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                size: 60,
              ),

              const SizedBox(
                height: 16,
              ),

              Text(
                '${_formatNumber(fromAmount)} '
                    '$fromCurrency',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 4,
              ),

              Text(
                fromNetwork,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              const Icon(
                Icons.keyboard_arrow_down,
              ),

              const SizedBox(
                height: 10,
              ),

              Text(
                '${_formatNumber(toAmount)} '
                    '$toCurrency',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 4,
              ),

              Text(
                toNetwork,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              Text(
                'Rate: 1 $fromCurrency = '
                    '${_formatNumber(rate)} '
                    '$toCurrency',
                textAlign: TextAlign.center,
              ),

              const SizedBox(
                height: 10,
              ),

              Text(
                id,
                style: const TextStyle(
                  fontSize: 11,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              child: const Text(
                'Done',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // CURRENCY DROPDOWN
  // ============================================================

  Widget _currencyDropdown({
    required String value,
    required ValueChanged<String?>
    onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Currency',
        border: OutlineInputBorder(),
      ),
      items: SwapService.currencies
          .map(
            (currency) =>
            DropdownMenuItem<String>(
              value: currency,
              child: Text(
                currency,
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
    required ValueChanged<String?>
    onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Network',
        border: OutlineInputBorder(),
      ),
      items: SwapService.networks
          .map(
            (network) =>
            DropdownMenuItem<String>(
              value: network,
              child: Text(
                network,
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
      final oldCurrency =
          _fromCurrency;

      final oldNetwork =
          _fromNetwork;

      _fromCurrency =
          _toCurrency;

      _toCurrency =
          oldCurrency;

      _fromNetwork =
          _toNetwork;

      _toNetwork =
          oldNetwork;
    });

    _calculatePreview();
  }

  // ============================================================
  // ERROR
  // ============================================================

  String _cleanError(
      Object error,
      ) {
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
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
        backgroundColor:
        isError ? Colors.red : null,
        behavior:
        SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // NUMBER FORMAT
  // ============================================================

  String _formatNumber(
      double value,
      ) {
    if (value.abs() >= 1000) {
      return value.toStringAsFixed(2);
    }

    if (value.abs() >= 1) {
      return value.toStringAsFixed(4);
    }

    return value.toStringAsFixed(8);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Swap',
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Swap',
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding:
          const EdgeInsets.all(20),
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            const Icon(
              Icons.swap_horiz_rounded,
              size: 54,
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              'Exchange Currency',
              textAlign:
              TextAlign.center,
              style:
              Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              'Exchange assets internally in your wallet.',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                color:
                Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            // ==================================================
            // TOTAL BALANCE
            // ==================================================

            Card(
              child: Padding(
                padding:
                const EdgeInsets.all(
                  16,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons
                          .account_balance_wallet_outlined,
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    const Expanded(
                      child: Text(
                        'Total wallet value',
                      ),
                    ),

                    Text(
                      '\$${_totalBalance.toStringAsFixed(2)}',
                      style:
                      const TextStyle(
                        fontSize: 17,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // ==================================================
            // FROM
            // ==================================================

            Text(
              'From',
              style:
              Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            _currencyDropdown(
              value:
              _fromCurrency,
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _fromCurrency =
                      value;
                });

                _calculatePreview();
              },
            ),

            const SizedBox(
              height: 12,
            ),

            _networkDropdown(
              value:
              _fromNetwork,
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _fromNetwork =
                      value;
                });
              },
            ),

            const SizedBox(
              height: 12,
            ),

            TextField(
              controller:
              _amountController,
              onChanged:
              _onAmountChanged,
              keyboardType:
              const TextInputType
                  .numberWithOptions(
                decimal: true,
              ),
              decoration:
              InputDecoration(
                labelText:
                'Amount',
                hintText:
                'Enter amount',
                suffixText:
                _fromCurrency,
                border:
                const OutlineInputBorder(),
                suffixIcon:
                TextButton(
                  onPressed:
                  _useMaximum,
                  child:
                  const Text(
                    'MAX',
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // ==================================================
            // REVERSE
            // ==================================================

            Center(
              child:
              IconButton.filledTonal(
                onPressed:
                _reverseCurrencies,
                tooltip:
                'Reverse currencies',
                icon: const Icon(
                  Icons.swap_vert,
                ),
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // ==================================================
            // TO
            // ==================================================

            Text(
              'To',
              style:
              Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            _currencyDropdown(
              value:
              _toCurrency,
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _toCurrency =
                      value;
                });

                _calculatePreview();
              },
            ),

            const SizedBox(
              height: 12,
            ),

            _networkDropdown(
              value:
              _toNetwork,
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _toNetwork =
                      value;
                });
              },
            ),

            const SizedBox(
              height: 24,
            ),

            // ==================================================
            // PREVIEW
            // ==================================================

            Card(
              child: Padding(
                padding:
                const EdgeInsets.all(
                  18,
                ),
                child: Column(
                  children: [
                    _previewRow(
                      'Exchange rate',
                      _exchangeRate == 0
                          ? '-'
                          : '1 $_fromCurrency = '
                          '${_formatNumber(_exchangeRate)} '
                          '$_toCurrency',
                    ),

                    const Divider(
                      height: 24,
                    ),

                    _previewRow(
                      'You send',
                      _amountController
                          .text
                          .isEmpty
                          ? '0 $_fromCurrency'
                          : '${_amountController.text} '
                          '$_fromCurrency',
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    _previewRow(
                      'You receive',
                      '${_formatNumber(_receivedAmount)} '
                          '$_toCurrency',
                      bold: true,
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    _previewRow(
                      'Fee',
                      '${_formatNumber(_fee)} '
                          '$_fromCurrency',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // ==================================================
            // INFORMATION
            // ==================================================

            Card(
              child: Padding(
                padding:
                const EdgeInsets.all(
                  16,
                ),
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Expanded(
                      child: Text(
                        'This is an internal wallet exchange. '
                            'No external blockchain transaction '
                            'is created.',
                        style: TextStyle(
                          color:
                          Theme.of(
                            context,
                          )
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            // ==================================================
            // SWAP BUTTON
            // ==================================================

            SizedBox(
              height: 54,
              child: FilledButton(
                onPressed:
                _isSwapping
                    ? null
                    : _performSwap,
                child: _isSwapping
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Swap Now',
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),
          ],
        ),
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
      }) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        const SizedBox(
          width: 12,
        ),
        Flexible(
          child: Text(
            value,
            textAlign:
            TextAlign.end,
            style: TextStyle(
              fontWeight: bold
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}