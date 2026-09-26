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

  void _showP2PInformation() {
    final colorScheme =
        Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: colorScheme.surface,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              4,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color:
                    colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.handshake_outlined,
                    color: colorScheme
                        .onPrimaryContainer,
                    size: 28,
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  'P2P Marketplace',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Buy crypto directly from other users using supported payment methods. Compare price, seller rating, limits and payment options before placing an order.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: colorScheme
                        .onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Got it',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final filteredOffers = p2pOffers
        .where(
          (offer) =>
      offer.asset.toUpperCase() ==
          selectedAsset.toUpperCase(),
    )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'P2P Marketplace',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'P2P Information',
            onPressed: _showP2PInformation,
            icon: const Icon(
              Icons.info_outline_rounded,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
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
              _buildHeader(context),

              const SizedBox(height: 18),

              _buildFilters(context),

              const SizedBox(height: 18),

              _buildSafetyBanner(context),

              const SizedBox(height: 22),

              Row(
                crossAxisAlignment:
                CrossAxisAlignment.end,
                children: [
                  const Expanded(
                    child: Text(
                      'Available Offers',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    '${filteredOffers.length} ${filteredOffers.length == 1 ? 'offer' : 'offers'}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (filteredOffers.isEmpty)
                _buildEmptyState(context)
              else
                ...filteredOffers.map(
                      (offer) => Padding(
                    padding:
                    const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: _P2POfferCard(
                      offer: offer,
                      selectedAsset:
                      selectedAsset,
                      onBuy: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                P2PBuyScreen(
                                  offer: offer,
                                  asset: selectedAsset,
                                  currency:
                                  selectedCurrency,
                                ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            width: 53,
            height: 53,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.15,
              ),
              borderRadius:
              BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.handshake_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Trade Peer-to-Peer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Buy crypto directly from verified sellers.',
                  style: TextStyle(
                    color: Colors.white70,
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

  Widget _buildFilters(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(15),
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
          const Row(
            children: [
              Icon(
                Icons.tune_rounded,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Trade Preferences',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child:
                DropdownButtonFormField<String>(
                  initialValue: selectedAsset,
                  decoration: InputDecoration(
                    labelText: 'Asset',
                    prefixIcon: const Icon(
                      Icons.currency_bitcoin_rounded,
                    ),
                    filled: true,
                    fillColor: colorScheme
                        .surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: colorScheme
                            .outlineVariant
                            .withValues(alpha: 0.35),
                      ),
                    ),
                    focusedBorder:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 1.4,
                      ),
                    ),
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
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      selectedAsset = value;
                    });
                  },
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child:
                DropdownButtonFormField<String>(
                  initialValue: selectedCurrency,
                  decoration: InputDecoration(
                    labelText: 'Currency',
                    prefixIcon: const Icon(
                      Icons.currency_rupee_rounded,
                    ),
                    filled: true,
                    fillColor: colorScheme
                        .surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: colorScheme
                            .outlineVariant
                            .withValues(alpha: 0.35),
                      ),
                    ),
                    focusedBorder:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 1.4,
                      ),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'INR',
                      child: Text('INR'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      selectedCurrency = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyBanner(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer
            .withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: colorScheme
                  .surface
                  .withValues(alpha: 0.65),
              borderRadius:
              BorderRadius.circular(11),
            ),
            child: Icon(
              Icons.shield_outlined,
              size: 20,
              color: colorScheme
                  .onPrimaryContainer,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Trade Smart',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: colorScheme
                        .onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Compare price, seller rating, limits and payment methods before placing an order.',
                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.4,
                    color: colorScheme
                        .onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: colorScheme.outlineVariant
              .withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color:
              colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.storefront_outlined,
              size: 37,
              color: colorScheme
                  .onPrimaryContainer,
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            'No Offers Available',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'There are currently no offers for $selectedAsset.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              height: 1.4,
              color:
              colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _P2POfferCard extends StatelessWidget {
  final P2POffer offer;
  final String selectedAsset;
  final VoidCallback onBuy;

  const _P2POfferCard({
    required this.offer,
    required this.selectedAsset,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
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
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme
                      .primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: colorScheme
                      .onPrimaryContainer,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            offer.sellerName,
                            overflow:
                            TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight:
                              FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified_rounded,
                          size: 14,
                          color: Colors.green,
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${offer.sellerRating} • ${offer.completedOrders} orders',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Column(
                crossAxisAlignment:
                CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${offer.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.primary,
                    ),
                  ),
                  Text(
                    'per $selectedAsset',
                    style: TextStyle(
                      fontSize: 9.5,
                      color: colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 17),

          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 11,
            ),
            decoration: BoxDecoration(
              color:
              colorScheme.surfaceContainerLow,
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons
                        .account_balance_wallet_outlined,
                    title: 'Available',
                    value:
                    '${offer.availableAmount.toStringAsFixed(0)} $selectedAsset',
                  ),
                ),
                Container(
                  width: 1,
                  height: 34,
                  color: colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.5),
                ),
                Expanded(
                  child: Padding(
                    padding:
                    const EdgeInsets.only(
                      left: 12,
                    ),
                    child: _InfoItem(
                      icon: Icons
                          .swap_vert_rounded,
                      title: 'Limits',
                      value:
                      '₹${offer.minAmount.toStringAsFixed(0)} - ₹${offer.maxAmount.toStringAsFixed(0)}',
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 13),

          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: offer.paymentMethods
                  .map(
                    (method) => Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme
                        .secondaryContainer
                        .withValues(alpha: 0.55),
                    borderRadius:
                    BorderRadius.circular(9),
                  ),
                  child: Row(
                    mainAxisSize:
                    MainAxisSize.min,
                    children: [
                      Icon(
                        Icons
                            .account_balance_outlined,
                        size: 13,
                        color: colorScheme
                            .onSecondaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        method,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight:
                          FontWeight.w600,
                          color: colorScheme
                              .onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .toList(),
            ),
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: onBuy,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(15),
                ),
              ),
              icon: const Icon(
                Icons.shopping_cart_outlined,
                size: 19,
              ),
              label: Text(
                'Buy $selectedAsset',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 9.5,
                  color: colorScheme
                      .onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}