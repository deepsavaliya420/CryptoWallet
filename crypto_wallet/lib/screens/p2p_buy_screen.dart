import 'package:flutter/material.dart';

import '../models/p2p_offer.dart';
import 'p2p_order_success_screen.dart';

class P2PBuyScreen extends StatefulWidget {
  final P2POffer offer;
  final String asset;
  final String currency;

  const P2PBuyScreen({
    required this.offer,
    required this.asset,
    required this.currency,
    super.key,
  });

  @override
  State<P2PBuyScreen> createState() =>
      _P2PBuyScreenState();
}

class _P2PBuyScreenState
    extends State<P2PBuyScreen> {
  final formKey = GlobalKey<FormState>();

  final amountController =
  TextEditingController();

  String? selectedPaymentMethod;

  double get amount {
    return double.tryParse(
      amountController.text.trim(),
    ) ??
        0;
  }

  double get totalPrice {
    return amount * widget.offer.price;
  }

  @override
  void initState() {
    super.initState();

    if (widget.offer.paymentMethods.isNotEmpty) {
      selectedPaymentMethod =
          widget.offer.paymentMethods.first;
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  void continueOrder() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedPaymentMethod == null) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            P2POrderSuccessScreen(
              offer: widget.offer,
              asset: widget.asset,
              currency: widget.currency,
              amount: amount,
              totalPrice: totalPrice,
              paymentMethod:
              selectedPaymentMethod!,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buy USDT',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              18,
              8,
              18,
              30,
            ),
            children: [
              _buildTopHeader(context),

              const SizedBox(height: 20),

              _buildSellerCard(context),

              const SizedBox(height: 22),

              _buildSectionTitle(
                context,
                'Purchase Details',
                'Enter the amount and choose your payment method.',
              ),

              const SizedBox(height: 12),

              _buildAmountField(context),

              const SizedBox(height: 15),

              _buildPaymentDropdown(context),

              const SizedBox(height: 22),

              _buildOrderSummary(context),

              const SizedBox(height: 22),

              _buildContinueButton(context),

              const SizedBox(height: 14),

              _buildSafetyNote(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
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
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.15,
              ),
              borderRadius:
              BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.currency_exchange_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Buy ${widget.asset}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Complete your P2P purchase securely.',
                  style: TextStyle(
                    color: Colors.white.withValues(
                      alpha: 0.78,
                    ),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerCard(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: colorScheme.outlineVariant
              .withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow
                .withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.storefront_outlined,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              const Text(
                'Selected Seller',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Container(
                width: 51,
                height: 51,
                decoration: BoxDecoration(
                  color:
                  colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: colorScheme
                      .onPrimaryContainer,
                  size: 26,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.offer.sellerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.offer.sellerRating} • ${widget.offer.completedOrders} completed orders',
                      style: TextStyle(
                        color: colorScheme
                            .onSurfaceVariant,
                        fontSize: 11,
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
                child: const Row(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 14,
                      color: Colors.green,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Verified',
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

          const SizedBox(height: 17),

          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: colorScheme
                  .surfaceContainerLow,
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Price',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  '₹${widget.offer.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '/ ${widget.asset}',
                  style: TextStyle(
                    fontSize: 11,
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
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color:
            colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountField(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return TextFormField(
      controller: amountController,
      keyboardType:
      const TextInputType.numberWithOptions(
        decimal: true,
      ),
      decoration: InputDecoration(
        labelText: 'Amount of ${widget.asset}',
        hintText: 'Example: 100',
        prefixIcon: const Icon(
          Icons.currency_bitcoin_rounded,
        ),
        suffixText: widget.asset,
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
            color: colorScheme.outlineVariant
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
      ),
      onChanged: (_) {
        setState(() {});
      },
      validator: (value) {
        if (value == null ||
            value.trim().isEmpty) {
          return 'Please enter amount';
        }

        final entered =
        double.tryParse(value.trim());

        if (entered == null) {
          return 'Enter a valid amount';
        }

        if (entered <= 0) {
          return 'Amount must be greater than 0';
        }

        if (entered < widget.offer.minAmount) {
          return 'Minimum is ${widget.offer.minAmount.toStringAsFixed(0)} ${widget.asset}';
        }

        if (entered > widget.offer.maxAmount) {
          return 'Maximum is ${widget.offer.maxAmount.toStringAsFixed(0)} ${widget.asset}';
        }

        if (entered >
            widget.offer.availableAmount) {
          return 'Seller does not have enough ${widget.asset}';
        }

        return null;
      },
    );
  }

  Widget _buildPaymentDropdown(
      BuildContext context,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return DropdownButtonFormField<String>(
      initialValue: selectedPaymentMethod,
      decoration: InputDecoration(
        labelText: 'Payment Method',
        prefixIcon: const Icon(
          Icons.account_balance_outlined,
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
            color: colorScheme.outlineVariant
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
      ),
      items: widget.offer.paymentMethods
          .map(
            (method) =>
            DropdownMenuItem<String>(
              value: method,
              child: Text(method),
            ),
      )
          .toList(),
      onChanged: (value) {
        setState(() {
          selectedPaymentMethod = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select payment method';
        }

        return null;
      },
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: colorScheme.outlineVariant
              .withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow
                .withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colorScheme
                      .primaryContainer,
                  borderRadius:
                  BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  size: 20,
                  color: colorScheme
                      .onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 11),
              const Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          _SummaryRow(
            title: 'Asset',
            value: widget.asset,
          ),

          _SummaryRow(
            title: 'Seller',
            value: widget.offer.sellerName,
          ),

          _SummaryRow(
            title: 'Price',
            value:
            '₹${widget.offer.price.toStringAsFixed(2)}',
          ),

          _SummaryRow(
            title: 'Amount',
            value:
            '${amount.toStringAsFixed(2)} ${widget.asset}',
          ),

          _SummaryRow(
            title: 'Payment',
            value:
            selectedPaymentMethod ?? '-',
          ),

          const SizedBox(height: 10),

          Divider(
            color: colorScheme.outlineVariant
                .withValues(alpha: 0.5),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '₹${totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(
      BuildContext context,
      ) {
    return SizedBox(
      height: 54,
      child: FilledButton.icon(
        onPressed: continueOrder,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(17),
          ),
        ),
        icon: const Icon(
          Icons.arrow_forward_rounded,
        ),
        label: const Text(
          'Continue to Order',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildSafetyNote(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer
            .withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            size: 19,
            color: colorScheme
                .onPrimaryContainer,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'Review the seller, amount and payment method carefully before continuing with the order.',
              style: TextStyle(
                fontSize: 10.5,
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

  const _SummaryRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
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
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}