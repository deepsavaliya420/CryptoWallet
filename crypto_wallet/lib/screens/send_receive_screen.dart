import 'package:flutter/material.dart';

import '../services/receive_request_service.dart';
import '../services/transaction_service.dart';
import '../services/wallet_service.dart';

enum TransferMode {
  send,
  receive,
}

class SendReceiveScreen extends StatefulWidget {
  final TransferMode mode;

  const SendReceiveScreen({
    super.key,
    required this.mode,
  });

  @override
  State<SendReceiveScreen> createState() =>
      _SendReceiveScreenState();
}

class _SendReceiveScreenState
    extends State<SendReceiveScreen> {
  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  final TextEditingController
  _addressController =
  TextEditingController();

  final TextEditingController
  _amountController =
  TextEditingController();

  bool _isProcessing = false;

  double _currentBalance = 0.0;

  bool get isSend =>
      widget.mode == TransferMode.send;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD TOTAL USD BALANCE
  // ============================================================

  Future<void> _loadBalance() async {
    try {
      final double balance =
      await WalletService.getTotalBalance();

      if (!mounted) {
        return;
      }

      setState(() {
        _currentBalance = balance;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showError(
        _cleanError(error),
      );
    }
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String address =
    _addressController.text.trim();

    final double? amount =
    double.tryParse(
      _amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      _showError(
        'Enter a valid amount.',
      );
      return;
    }

    if (isSend) {
      await _send(
        address: address,
        amount: amount,
      );
    } else {
      await _createReceiveRequest(
        address: address,
        amount: amount,
      );
    }
  }

  // ============================================================
  // SEND USD
  //
  // THIS IS THE IMPORTANT FIX.
  //
  // We check the TOTAL USD wallet balance,
  // not just USDT.
  //
  // Then WalletService.sendUsd() actually
  // removes the USD value from the wallet.
  // ============================================================

  Future<void> _send({
    required String address,
    required double amount,
  }) async {
    // Always get the latest balance immediately
    // before sending.
    final double latestBalance =
    await WalletService.getTotalBalance();

    if (!mounted) {
      return;
    }

    setState(() {
      _currentBalance = latestBalance;
    });

    if (amount >
        latestBalance + 0.00000001) {
      _showError(
        'Insufficient wallet balance. '
            'Available: \$${latestBalance.toStringAsFixed(2)}',
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      const String myWalletAddress =
          'MY_WALLET';

      // --------------------------------------------------------
      // 1. ACTUALLY REMOVE USD VALUE FROM WALLET
      // --------------------------------------------------------

      await WalletService.sendUsd(
        amount,
      );

      // --------------------------------------------------------
      // 2. CREATE TRANSACTION
      // --------------------------------------------------------

      await TransactionService.createTransaction(
        type: 'Sent',
        asset: 'USD',
        network: 'TRC-20',
        amount: amount,
        value: amount,
        from: myWalletAddress,
        to: address,
      );

      // --------------------------------------------------------
      // 3. GET NEW BALANCE
      // --------------------------------------------------------

      final double newBalance =
      await WalletService.getTotalBalance();

      if (!mounted) {
        return;
      }

      setState(() {
        _currentBalance = newBalance;
      });

      // --------------------------------------------------------
      // 4. RETURN TO HOME
      //
      // true tells HomeScreen to reload its
      // balance and recent transactions.
      // --------------------------------------------------------

      Navigator.pop(
        context,
        true,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showError(
        _cleanError(error),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // ============================================================
  // RECEIVE REQUEST
  //
  // Creating a request does NOT add balance.
  // Balance is added when the request is actually
  // completed/paid.
  // ============================================================

  Future<void> _createReceiveRequest({
    required String address,
    required double amount,
  }) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      const String myWalletAddress =
          'MY_WALLET';

      final request =
      await ReceiveRequestService.createRequest(
        requestedFrom: address,
        requestedTo: myWalletAddress,
        asset: 'USDT',
        network: 'TRC-20',
        amount: amount,
      );

      if (!mounted) {
        return;
      }

      await _showRequestCreatedDialog(
        request.id,
        amount,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(
        context,
        false,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showError(
        _cleanError(error),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // ============================================================
  // REQUEST CREATED DIALOG
  // ============================================================

  Future<void> _showRequestCreatedDialog(
      String requestId,
      double amount,
      ) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Receive Request Created',
          ),
          content: Column(
            mainAxisSize:
            MainAxisSize.min,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Requesting '
                    '${amount.toStringAsFixed(2)} USDT.',
              ),
              const SizedBox(
                height: 12,
              ),
              const Text(
                'The sender must approve the '
                    'request and send the USDT.',
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                'Request ID:',
                style: Theme.of(
                  dialogContext,
                )
                    .textTheme
                    .labelLarge,
              ),
              const SizedBox(
                height: 4,
              ),
              SelectableText(
                requestId,
                style:
                const TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
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
  // ERROR
  // ============================================================

  void _showError(
      String message,
      ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior:
        SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // SUCCESS
  // ============================================================

  void _showSuccess(
      String message,
      ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
        SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // ERROR CLEANER
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
  // ADDRESS VALIDATION
  // ============================================================

  String? _validateAddress(
      String? value,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return isSend
          ? 'Enter the recipient wallet address.'
          : 'Enter the sender wallet address.';
    }

    if (value.trim().length < 8) {
      return 'Enter a valid wallet address.';
    }

    return null;
  }

  // ============================================================
  // AMOUNT VALIDATION
  // ============================================================

  String? _validateAmount(
      String? value,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Enter the amount.';
    }

    final double? amount =
    double.tryParse(
      value.trim(),
    );

    if (amount == null ||
        amount <= 0) {
      return 'Enter a valid amount.';
    }

    // IMPORTANT:
    // Compare against TOTAL USD balance.
    if (isSend &&
        amount >
            _currentBalance +
                0.00000001) {
      return 'Insufficient wallet balance.';
    }

    return null;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final String title = isSend
        ? 'Send USD'
        : 'Receive USD';

    final String addressLabel =
    isSend
        ? 'Recipient Wallet Address'
        : 'Sender Wallet Address';

    final String addressHint =
    isSend
        ? 'Enter wallet address to send to'
        : 'Enter wallet address to request from';

    final String buttonText =
    isSend
        ? 'Send USD'
        : 'Create Receive Request';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding:
            const EdgeInsets.all(20),
            children: [
              // ==================================================
              // ICON
              // ==================================================

              Icon(
                isSend
                    ? Icons
                    .arrow_upward_rounded
                    : Icons
                    .arrow_downward_rounded,
                size: 52,
              ),

              const SizedBox(
                height: 16,
              ),

              // ==================================================
              // TITLE
              // ==================================================

              Text(
                title,
                textAlign:
                TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              Text(
                isSend
                    ? 'Send USD to another wallet.'
                    : 'Request USD from another wallet.',
                textAlign:
                TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              // ==================================================
              // CURRENT BALANCE
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
                          'Available Balance',
                        ),
                      ),
                      Text(
                        '\$${_currentBalance.toStringAsFixed(2)}',
                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              // ==================================================
              // ADDRESS
              // ==================================================

              TextFormField(
                controller:
                _addressController,
                validator:
                _validateAddress,
                autocorrect: false,
                decoration:
                InputDecoration(
                  labelText:
                  addressLabel,
                  hintText:
                  addressHint,
                  prefixIcon:
                  const Icon(
                    Icons
                        .account_balance_wallet_outlined,
                  ),
                  border:
                  const OutlineInputBorder(),
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              // ==================================================
              // AMOUNT
              // ==================================================

              TextFormField(
                controller:
                _amountController,
                validator:
                _validateAmount,
                keyboardType:
                const TextInputType
                    .numberWithOptions(
                  decimal: true,
                ),
                decoration:
                const InputDecoration(
                  labelText:
                  'Amount (USD)',
                  hintText:
                  'Enter amount',
                  prefixIcon:
                  Icon(
                    Icons
                        .attach_money,
                  ),
                  suffixText:
                  'USD',
                  border:
                  OutlineInputBorder(),
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              // ==================================================
              // NETWORK
              // ==================================================

              Card(
                child: ListTile(
                  leading:
                  const Icon(
                    Icons.lan_outlined,
                  ),
                  title:
                  const Text(
                    'Network',
                  ),
                  subtitle:
                  const Text(
                    'TRC-20',
                  ),
                  trailing:
                  const Icon(
                    Icons.check_circle,
                  ),
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              // ==================================================
              // INFO
              // ==================================================

              Card(
                child: Padding(
                  padding:
                  const EdgeInsets.all(
                    16,
                  ),
                  child: Text(
                    isSend
                        ? 'The USD value will be deducted from your wallet after confirmation. Your Home balance will update immediately.'
                        : 'Creating a request does not add funds immediately. The sender must approve the request and complete the transfer.',
                    style:
                    TextStyle(
                      color: Theme.of(
                        context,
                      )
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              // ==================================================
              // SUBMIT
              // ==================================================

              SizedBox(
                height: 54,
                child:
                FilledButton(
                  onPressed:
                  _isProcessing
                      ? null
                      : _submit,
                  child:
                  _isProcessing
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child:
                    CircularProgressIndicator(
                      strokeWidth:
                      2,
                    ),
                  )
                      : Text(
                    buttonText,
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