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

    selectedPaymentMethod =
        widget.offer.paymentMethods.first;
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buy USDT',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected Seller',
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                            colorScheme.primaryContainer,
                            child: Icon(
                              Icons.person,
                              color: colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.offer.sellerName,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${widget.offer.sellerRating} • ${widget.offer.completedOrders} completed orders',
                                  style: TextStyle(
                                    color: colorScheme
                                        .onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 28),

                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Price',
                            ),
                          ),
                          Text(
                            '₹${widget.offer.price.toStringAsFixed(2)} / ${widget.asset}',
                            style: const TextStyle(
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Purchase Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller: amountController,
                keyboardType:
                const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText:
                  'Amount of ${widget.asset}',
                  hintText: 'Example: 100',
                  prefixIcon: const Icon(
                    Icons.currency_bitcoin,
                  ),
                  suffixText: widget.asset,
                  border: const OutlineInputBorder(),
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
                  double.tryParse(
                    value.trim(),
                  );

                  if (entered == null) {
                    return 'Enter a valid amount';
                  }

                  if (entered <= 0) {
                    return 'Amount must be greater than 0';
                  }

                  if (entered <
                      widget.offer.minAmount) {
                    return 'Minimum is ${widget.offer.minAmount.toStringAsFixed(0)} USDT';
                  }

                  if (entered >
                      widget.offer.maxAmount) {
                    return 'Maximum is ${widget.offer.maxAmount.toStringAsFixed(0)} USDT';
                  }

                  if (entered >
                      widget.offer.availableAmount) {
                    return 'Seller does not have enough USDT';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              DropdownButtonFormField<String>(
                initialValue: selectedPaymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Payment Method',
                  prefixIcon: Icon(
                    Icons.payment_outlined,
                  ),
                  border: OutlineInputBorder(),
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
                    selectedPaymentMethod =
                        value;
                  });
                },
                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return 'Please select payment method';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              Card(
                color: colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      const Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      _SummaryRow(
                        title: 'Asset',
                        value: widget.asset,
                      ),

                      _SummaryRow(
                        title: 'Seller',
                        value:
                        widget.offer.sellerName,
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
                        selectedPaymentMethod ??
                            '-',
                      ),

                      const Divider(
                        height: 24,
                      ),

                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            '₹${totalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight:
                              FontWeight.bold,
                              color:
                              colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: continueOrder,
                  icon: const Icon(
                    Icons.arrow_forward,
                  ),
                  label: const Text(
                    'Continue to Order',
                    style: TextStyle(
                      fontSize: 16,
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

class _SummaryRow extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(title),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}