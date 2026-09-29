import 'package:flutter/material.dart';

import '../services/receive_request_service.dart';
import '../services/user_service.dart';
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

  final TextEditingController _addressController =
  TextEditingController();

  final TextEditingController _amountController =
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
  // LOAD BALANCE
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
  // ============================================================

  Future<void> _send({
    required String address,
    required double amount,
  }) async {
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
      final String myWalletAddress =
          UserService.currentUser?.walletAddress.trim() ?? '';

      if (myWalletAddress.isEmpty) {
        throw Exception(
          'Your wallet address is not available. Please refresh your profile and try again.',
        );
      }

      if (address == myWalletAddress) {
        throw Exception(
          'You cannot send USD to your own wallet.',
        );
      }

      // ========================================================
      // ACTUAL WALLET TRANSFER
      //
      // Backend will:
      // 1. Check recipient wallet
      // 2. Check sender balance
      // 3. Deduct amount from sender
      // 4. Add amount to recipient
      // 5. Create sender "Sent" transaction
      // 6. Create recipient "Received" transaction
      // ========================================================

      await WalletService.transferUsd(
        recipientAddress: address,
        amount: amount,
      );

      // Get updated sender balance from backend.
      final double newBalance =
      await WalletService.getTotalBalance();

      if (!mounted) {
        return;
      }

      setState(() {
        _currentBalance = newBalance;
      });

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
  // ============================================================

  Future<void> _createReceiveRequest({
    required String address,
    required double amount,
  }) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final String myWalletAddress =
          UserService.currentUser?.walletAddress.trim() ?? '';

      if (myWalletAddress.isEmpty) {
        throw Exception(
          'Your wallet address is not available. Please refresh your profile and try again.',
        );
      }

      if (address == myWalletAddress) {
        throw Exception(
          'You cannot create a receive request from your own wallet.',
        );
      }

      final request =
      await ReceiveRequestService.createRequest(
        // B = the person whose wallet will be charged
        requestedFrom: address,

        // A = the currently logged-in requester
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
                Icons.check_circle_outline_rounded,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Request Created',
                  style: TextStyle(
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize:
            MainAxisSize.min,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.55),
                  borderRadius:
                  BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons
                          .account_balance_wallet_outlined,
                      color: colorScheme
                          .onPrimaryContainer,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${amount.toStringAsFixed(2)} USDT requested',
                        style: TextStyle(
                          fontWeight:
                          FontWeight.w700,
                          color: colorScheme
                              .onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              Text(
                'The sender will receive a notification '
                    'and can approve or deny this request.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.45,
                  color: colorScheme
                      .onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                'Request ID',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                  FontWeight.w700,
                  color: colorScheme
                      .onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 6),

              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme
                      .surfaceContainerLow,
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: SelectableText(
                  requestId,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            FilledButton(
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

    final colorScheme =
        Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
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
        colorScheme.error,
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
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

    final String addressLabel = isSend
        ? 'Recipient Wallet Address'
        : 'Sender Wallet Address';

    final String addressHint = isSend
        ? 'Enter wallet address to send to'
        : 'Enter wallet address to request from';

    final String buttonText = isSend
        ? 'Send USD'
        : 'Create Receive Request';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding:
            const EdgeInsets.fromLTRB(
              18,
              8,
              18,
              30,
            ),
            children: [
              _buildHeroHeader(
                context,
                title,
              ),

              const SizedBox(height: 22),

              _buildBalanceCard(
                context,
              ),

              const SizedBox(height: 22),

              _buildSectionTitle(
                context,
                'Transfer Details',
                isSend
                    ? 'Enter the wallet address and amount you want to send.'
                    : 'Enter the wallet address and amount you want to request.',
              ),

              const SizedBox(height: 13),

              _buildFormCard(
                context,
                addressLabel,
                addressHint,
              ),

              const SizedBox(height: 14),

              _buildNetworkCard(
                context,
              ),

              const SizedBox(height: 14),

              _buildInfoCard(
                context,
              ),

              const SizedBox(height: 24),

              _buildSubmitButton(
                context,
                buttonText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHeroHeader(
      BuildContext context,
      String title,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(23),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary
                .withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.15,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSend
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  isSend
                      ? 'Transfer USD securely to another wallet.'
                      : 'Request USD from another wallet.',
                  style: TextStyle(
                    color: Colors.white
                        .withValues(alpha: 0.78),
                    fontSize: 11.5,
                    height: 1.35,
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
  // BALANCE
  // ============================================================

  Widget _buildBalanceCard(
      BuildContext context,
      ) {
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
              .withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow
                .withValues(alpha: 0.035),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color:
              colorScheme.primaryContainer,
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: Icon(
              Icons
                  .account_balance_wallet_outlined,
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
                  'Available Balance',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: colorScheme
                        .onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '\$${_currentBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.65),
              borderRadius:
              BorderRadius.circular(20),
            ),
            child: Text(
              'USD',
              style: TextStyle(
                color: colorScheme
                    .onPrimaryContainer,
                fontSize: 11,
                fontWeight:
                FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(
      BuildContext context,
      String title,
      String subtitle,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight:
            FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: colorScheme
                .onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FORM CARD
  // ============================================================

  Widget _buildFormCard(
      BuildContext context,
      String addressLabel,
      String addressHint,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius:
        BorderRadius.circular(21),
        border: Border.all(
          color: colorScheme
              .outlineVariant
              .withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow
                .withValues(alpha: 0.035),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          TextFormField(
            controller:
            _addressController,
            validator:
            _validateAddress,
            autocorrect: false,
            maxLines: 2,
            decoration:
            InputDecoration(
              labelText: addressLabel,
              hintText: addressHint,
              prefixIcon: const Padding(
                padding:
                EdgeInsets.only(
                  bottom: 22,
                ),
                child: Icon(
                  Icons
                      .account_balance_wallet_outlined,
                ),
              ),
              filled: true,
              fillColor: colorScheme
                  .surfaceContainerLow,
              border:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(
                  15,
                ),
                borderSide:
                BorderSide.none,
              ),
              enabledBorder:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(
                  15,
                ),
                borderSide:
                BorderSide(
                  color: colorScheme
                      .outlineVariant
                      .withValues(
                    alpha: 0.35,
                  ),
                ),
              ),
              focusedBorder:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(
                  15,
                ),
                borderSide:
                BorderSide(
                  color:
                  colorScheme.primary,
                  width: 1.4,
                ),
              ),
            ),
          ),

          const SizedBox(height: 13),

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
            InputDecoration(
              labelText: 'Amount (USD)',
              hintText: 'Enter amount',
              prefixIcon: const Icon(
                Icons.attach_money_rounded,
              ),
              suffixText: 'USD',
              filled: true,
              fillColor: colorScheme
                  .surfaceContainerLow,
              border:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(
                  15,
                ),
                borderSide:
                BorderSide.none,
              ),
              enabledBorder:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(
                  15,
                ),
                borderSide:
                BorderSide(
                  color: colorScheme
                      .outlineVariant
                      .withValues(
                    alpha: 0.35,
                  ),
                ),
              ),
              focusedBorder:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(
                  15,
                ),
                borderSide:
                BorderSide(
                  color:
                  colorScheme.primary,
                  width: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NETWORK
  // ============================================================

  Widget _buildNetworkCard(
      BuildContext context,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme
              .outlineVariant
              .withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color:
              colorScheme.primaryContainer,
              borderRadius:
              BorderRadius.circular(13),
            ),
            child: Icon(
              Icons.lan_outlined,
              color: colorScheme
                  .onPrimaryContainer,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Network',
                  style: TextStyle(
                    fontSize: 10.5,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'TRC-20',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.check_circle_rounded,
            color: Colors.green,
            size: 22,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO CARD
  // ============================================================

  Widget _buildInfoCard(
      BuildContext context,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colorScheme
            .primaryContainer
            .withValues(alpha: 0.42),
        borderRadius:
        BorderRadius.circular(17),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 19,
            color: colorScheme
                .onPrimaryContainer,
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              isSend
                  ? 'The USD value will be deducted from your wallet after confirmation. Your Home balance will update immediately.'
                  : 'Creating a request does not add funds immediately. The sender will receive a notification and can approve or deny the request.',
              style: TextStyle(
                fontSize: 10.5,
                height: 1.5,
                color: colorScheme
                    .onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUBMIT BUTTON
  // ============================================================

  Widget _buildSubmitButton(
      BuildContext context,
      String buttonText,
      ) {
    return SizedBox(
      height: 55,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed:
        _isProcessing ? null : _submit,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(17),
          ),
        ),
        icon: _isProcessing
            ? const SizedBox(
          width: 20,
          height: 20,
          child:
          CircularProgressIndicator(
            strokeWidth: 2.3,
            color: Colors.white,
          ),
        )
            : Icon(
          isSend
              ? Icons
              .arrow_upward_rounded
              : Icons
              .arrow_downward_rounded,
        ),
        label: Text(
          _isProcessing
              ? 'Processing...'
              : buttonText,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ),
    );
  }
}