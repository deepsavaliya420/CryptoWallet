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
  final _formKey = GlobalKey<FormState>();

  final _addressController =
  TextEditingController();

  final _amountController =
  TextEditingController();

  bool _isProcessing = false;

  double _currentBalance = 0;

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
  // LOAD BALANCE
  // ============================================================

  Future<void> _loadBalance() async {
    final balance =
    await WalletService.getUSDTBalance();

    if (!mounted) {
      return;
    }

    setState(() {
      _currentBalance = balance;
    });
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final address =
    _addressController.text.trim();

    final amount =
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
  // SEND
  // ============================================================

  Future<void> _send({
    required String address,
    required double amount,
  }) async {
    if (amount > _currentBalance) {
      _showError(
        'Insufficient USDT balance. '
            'Available: ${_currentBalance.toStringAsFixed(2)} USDT',
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      /*
       * In this local implementation, the recipient
       * address represents the destination wallet.
       */

      const myWalletAddress =
          'MY_WALLET';

      await WalletService.subtractUSDT(
        amount,
      );

      await TransactionService.createTransaction(
        type: 'Sent',
        asset: 'USDT',
        network: 'TRC-20',
        amount: amount,
        value: amount,
        from: myWalletAddress,
        to: address,
      );

      if (!mounted) {
        return;
      }

      _showSuccess(
        'Sent ${amount.toStringAsFixed(2)} USDT successfully.',
      );

      /*
       * Return true to HomeScreen so it refreshes
       * balance and Recent Transactions.
       */
      Navigator.pop(
        context,
        true,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showError(
        error.toString().replaceFirst(
          'Bad state: ',
          '',
        ),
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
  // ============================================================

  Future<void> _createReceiveRequest({
    required String address,
    required double amount,
  }) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      const myWalletAddress =
          'MY_WALLET';

      /*
       * IMPORTANT:
       *
       * Creating a Receive request DOES NOT add money
       * to the wallet.
       *
       * The sender must actually send the requested
       * amount before the receiver balance changes.
       */

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
        error.toString().replaceFirst(
          'Bad state: ',
          '',
        ),
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
      builder: (context) {
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
                style:
                Theme.of(context)
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
  // ERROR
  // ============================================================

  void _showError(
      String message,
      ) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
        Colors.red,
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
  // VALIDATION
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

  String? _validateAmount(
      String? value,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Enter the amount.';
    }

    final amount =
    double.tryParse(
      value.trim(),
    );

    if (amount == null ||
        amount <= 0) {
      return 'Enter a valid amount.';
    }

    if (isSend &&
        amount > _currentBalance) {
      return 'Insufficient balance.';
    }

    return null;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final title = isSend
        ? 'Send USDT'
        : 'Receive USDT';

    final addressLabel = isSend
        ? 'Recipient Wallet Address'
        : 'Sender Wallet Address';

    final addressHint = isSend
        ? 'Enter wallet address to send to'
        : 'Enter wallet address to request from';

    final buttonText = isSend
        ? 'Send USDT'
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
              // HEADER
              // ==================================================

              Icon(
                isSend
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                size: 52,
              ),

              const SizedBox(
                height: 16,
              ),

              Text(
                title,
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
                height: 8,
              ),

              Text(
                isSend
                    ? 'Send USDT to another wallet.'
                    : 'Request USDT from another wallet.',
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
                height: 28,
              ),

              // ==================================================
              // BALANCE
              // ==================================================

              if (isSend)
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
                            'Available USDT',
                          ),
                        ),
                        Text(
                          '${_currentBalance.toStringAsFixed(2)} USDT',
                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.bold,
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
                keyboardType:
                TextInputType
                    .text,
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
                  'USDT',
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
                    Icons
                        .lan_outlined,
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
                    Icons
                        .check_circle,
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
                        ? 'The USDT amount will be deducted from your wallet after confirmation.'
                        : 'Creating a request does not add USDT to your balance. The sender must approve the request and send the funds.',
                    style:
                    TextStyle(
                      color:
                      Theme.of(context)
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