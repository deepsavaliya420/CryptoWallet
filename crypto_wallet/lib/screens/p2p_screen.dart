import 'package:flutter/material.dart';

import '../data/p2p_offers.dart';
import '../models/p2p_offer.dart';
import 'p2p_buy_screen.dart';

class P2PScreen extends StatefulWidget {
  const P2PScreen({super.key});

  @override
  State<P2PScreen> createState() => _P2PScreenState();
}

class _P2PScreenState extends State<P2PScreen> {
  String selectedAsset = 'USDT';
  String selectedCurrency = 'INR';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'P2P Marketplace',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'P2P Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Buy crypto directly from other users using supported payment methods.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Got it'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            icon: const Icon(
              Icons.info_outline,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                12,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedAsset,
                          decoration: const InputDecoration(
                            labelText: 'Asset',
                            prefixIcon: Icon(
                              Icons.currency_bitcoin,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'USDT',
                              child: Text('USDT'),
                            ),
                            DropdownMenuItem(
                              value: 'USDC',
                              child: Text('USDC'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              selectedAsset = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedCurrency,
                          decoration: const InputDecoration(
                            labelText: 'Currency',
                            prefixIcon: Icon(
                              Icons.currency_rupee,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'INR',
                              child: Text('INR'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              selectedCurrency = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Choose a seller based on price, rating, limits and payment methods.',
                            style: TextStyle(
                              color:
                              colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Buy USDT',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${p2pOffers.length} offers',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  4,
                  16,
                  20,
                ),
                itemCount: p2pOffers.length,
                itemBuilder: (context, index) {
                  final offer = p2pOffers[index];

                  return _P2POfferCard(
                    offer: offer,
                    onBuy: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              P2PBuyScreen(
                                offer: offer,
                                asset: selectedAsset,
                                currency: selectedCurrency,
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _P2POfferCard extends StatelessWidget {
  final P2POffer offer;
  final VoidCallback onBuy;

  const _P2POfferCard({
    required this.offer,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                  colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    color:
                    colorScheme.onPrimaryContainer,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.sellerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${offer.sellerRating} • ${offer.completedOrders} orders',
                        style: TextStyle(
                          color:
                          colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${offer.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const Text(
                      'per USDT',
                      style: TextStyle(
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    title: 'Available',
                    value:
                    '${offer.availableAmount.toStringAsFixed(0)} USDT',
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    title: 'Limits',
                    value:
                    '₹${offer.minAmount.toStringAsFixed(0)} - ₹${offer.maxAmount.toStringAsFixed(0)}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: offer.paymentMethods
                  .map(
                    (method) => Chip(
                  avatar: const Icon(
                    Icons.payment,
                    size: 16,
                  ),
                  label: Text(method),
                ),
              )
                  .toList(),
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton(
                onPressed: onBuy,
                child: const Text(
                  'Buy USDT',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String title;
  final String value;

  const _InfoItem({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}