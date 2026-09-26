import 'package:flutter/material.dart';

import '../models/swap_transaction.dart';
import '../services/swap_service.dart';

class SwapHistoryScreen extends StatefulWidget {
  const SwapHistoryScreen({
    super.key,
  });

  @override
  State<SwapHistoryScreen> createState() =>
      _SwapHistoryScreenState();
}

class _SwapHistoryScreenState
    extends State<SwapHistoryScreen> {
  List<SwapTransaction> _swaps = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSwaps();
  }

  // ============================================================
  // LOAD SWAPS
  // ============================================================

  Future<void> _loadSwaps() async {
    try {
      final swaps =
      await SwapService.getSwaps();

      if (!mounted) return;

      setState(() {
        _swaps =
        List<SwapTransaction>.from(swaps);
        _isLoading = false;
      });
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
  // CLEAR HISTORY
  // ============================================================

  Future<void> _clearHistory() async {
    if (_swaps.isEmpty) {
      return;
    }

    final confirmed =
    await _showClearConfirmation();

    if (confirmed != true) {
      return;
    }

    try {
      await SwapService.clearHistory();

      if (!mounted) return;

      setState(() {
        _swaps.clear();
      });

      _showMessage(
        'Swap history cleared.',
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        _cleanError(error),
        isError: true,
      );
    }
  }

  // ============================================================
  // CLEAR CONFIRMATION
  // ============================================================

  Future<bool?> _showClearConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colorScheme =
            Theme.of(dialogContext).colorScheme;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(23),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.delete_sweep_outlined,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Clear Swap History?',
                  style: TextStyle(
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'This removes the saved swap history. '
                'Your wallet balances will not be changed.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor:
                colorScheme.error,
                foregroundColor:
                colorScheme.onError,
              ),
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'Clear History',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // DETAILS
  // ============================================================

  void _showSwapDetails(
      SwapTransaction swap,
      ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor:
      Theme.of(context).colorScheme.surface,
      builder: (sheetContext) {
        final colorScheme =
            Theme.of(sheetContext).colorScheme;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              5,
              20,
              30,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colorScheme
                            .primaryContainer,
                        borderRadius:
                        BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.swap_horiz_rounded,
                        color: colorScheme
                            .onPrimaryContainer,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Swap Details',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight:
                              FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Complete transaction information',
                            style: TextStyle(
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _buildDetailSection(
                  sheetContext,
                  children: [
                    _detailRow(
                      sheetContext,
                      'Status',
                      swap.status.toUpperCase(),
                      valueColor:
                      _statusColor(
                        sheetContext,
                        swap.status,
                      ),
                    ),
                    _detailRow(
                      sheetContext,
                      'From',
                      '${_formatNumber(swap.fromAmount)} '
                          '${swap.fromCurrency}',
                    ),
                    _detailRow(
                      sheetContext,
                      'From Network',
                      swap.fromNetwork.isEmpty
                          ? 'Not specified'
                          : swap.fromNetwork,
                    ),
                    _detailRow(
                      sheetContext,
                      'To',
                      '${_formatNumber(swap.toAmount)} '
                          '${swap.toCurrency}',
                    ),
                    _detailRow(
                      sheetContext,
                      'To Network',
                      swap.toNetwork.isEmpty
                          ? 'Not specified'
                          : swap.toNetwork,
                    ),
                    _detailRow(
                      sheetContext,
                      'Exchange Rate',
                      '1 ${swap.fromCurrency} = '
                          '${_formatNumber(swap.exchangeRate)} '
                          '${swap.toCurrency}',
                    ),
                    _detailRow(
                      sheetContext,
                      'Fee',
                      '${_formatNumber(swap.fee)} '
                          '${swap.fromCurrency}',
                    ),
                    _detailRow(
                      sheetContext,
                      'Date',
                      _formatDateTime(
                        swap.timestamp,
                      ),
                    ),
                    _detailRow(
                      sheetContext,
                      'Transaction ID',
                      swap.id,
                      isLast: true,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(
                        sheetContext,
                      ).pop();
                    },
                    style:
                    OutlinedButton.styleFrom(
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          15,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Close',
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

  // ============================================================
  // DETAIL SECTION
  // ============================================================

  Widget _buildDetailSection(
      BuildContext context, {
        required List<Widget> children,
      }) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius:
        BorderRadius.circular(19),
        border: Border.all(
          color: colorScheme
              .outlineVariant
              .withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _detailRow(
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
        vertical: 12,
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
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
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
          Expanded(
            flex: 3,
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
  // SWAP CARD
  // ============================================================

  Widget _swapCard(
      SwapTransaction swap,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final statusColor =
    _statusColor(
      context,
      swap.status,
    );

    return Container(
      margin: const EdgeInsets.only(
        bottom: 13,
      ),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius:
          BorderRadius.circular(21),
          onTap: () {
            _showSwapDetails(swap);
          },
          child: Padding(
            padding:
            const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 49,
                      height: 49,
                      decoration: BoxDecoration(
                        color: colorScheme
                            .primaryContainer,
                        borderRadius:
                        BorderRadius.circular(
                          14,
                        ),
                      ),
                      child: Icon(
                        Icons
                            .swap_horiz_rounded,
                        color: colorScheme
                            .onPrimaryContainer,
                        size: 25,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Asset Swap',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                              FontWeight.w800,
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            '${swap.fromCurrency} → '
                                '${swap.toCurrency}',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration:
                      BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(
                          10,
                        ),
                        color: statusColor
                            .withValues(
                          alpha: 0.10,
                        ),
                      ),
                      child: Text(
                        swap.status
                            .toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight:
                          FontWeight.w800,
                          fontSize: 9.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 17),

                Row(
                  children: [
                    Expanded(
                      child: _amountBox(
                        label: 'Sent',
                        amount:
                        _formatNumber(
                          swap.fromAmount,
                        ),
                        currency:
                        swap.fromCurrency,
                      ),
                    ),

                    Container(
                      width: 31,
                      height: 31,
                      margin:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme
                            .primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons
                            .arrow_forward_rounded,
                        size: 16,
                        color: colorScheme
                            .onPrimaryContainer,
                      ),
                    ),

                    Expanded(
                      child: _amountBox(
                        label: 'Received',
                        amount:
                        _formatNumber(
                          swap.toAmount,
                        ),
                        currency:
                        swap.toCurrency,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Container(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 11,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme
                        .surfaceContainerLow,
                    borderRadius:
                    BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lan_outlined,
                        size: 16,
                        color: colorScheme
                            .primary,
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Expanded(
                        child: Text(
                          _networkText(swap),
                          style: TextStyle(
                            fontSize: 10.5,
                            color: colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Icon(
                        Icons
                            .schedule_outlined,
                        size: 15,
                        color: colorScheme
                            .onSurfaceVariant,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        _formatDateTime(
                          swap.timestamp,
                        ),
                        style: TextStyle(
                          fontSize: 9.5,
                          color: colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // AMOUNT BOX
  // ============================================================

  Widget _amountBox({
    required String label,
    required String amount,
    required String currency,
  }) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(14),
        color: colorScheme
            .surfaceContainerLow,
      ),
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
          const SizedBox(height: 5),
          Text(
            amount,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight:
              FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            currency,
            style: TextStyle(
              fontSize: 10,
              fontWeight:
              FontWeight.w600,
              color: colorScheme
                  .onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(
      BuildContext context,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      margin:
      const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(19),
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
            width: 57,
            height: 57,
            decoration: BoxDecoration(
              color: Colors.white
                  .withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.swap_horizontal_circle_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Swap History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_swaps.length} '
                      '${_swaps.length == 1 ? 'swap' : 'swaps'} recorded',
                  style: TextStyle(
                    color: Colors.white
                        .withValues(alpha: 0.78),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          if (_swaps.isNotEmpty)
            Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: Colors.white
                    .withValues(alpha: 0.15),
                borderRadius:
                BorderRadius.circular(12),
              ),
              child: Text(
                '${_swaps.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight:
                  FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState() {
    final colorScheme =
        Theme.of(context).colorScheme;

    return ListView(
      physics:
      const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
      ),
      children: [
        const SizedBox(height: 75),

        Container(
          width: 92,
          height: 92,
          margin:
          const EdgeInsets.symmetric(
            horizontal: 100,
          ),
          decoration: BoxDecoration(
            color:
            colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons
                .swap_horizontal_circle_outlined,
            size: 45,
            color: colorScheme.primary,
          ),
        ),

        const SizedBox(height: 20),

        const Center(
          child: Text(
            'No Swaps Yet',
            style: TextStyle(
              fontSize: 19,
              fontWeight:
              FontWeight.w800,
            ),
          ),
        ),

        const SizedBox(height: 7),

        Text(
          'Your currency exchange history '
              'will appear here after you complete a swap.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.5,
            height: 1.45,
            color: colorScheme
                .onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 24),

        Center(
          child: FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.swap_horiz_rounded,
            ),
            label: const Text(
              'Start a Swap',
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color _statusColor(
      BuildContext context,
      String status,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;

      case 'failed':
        return colorScheme.error;

      case 'pending':
      case 'processing':
        return Colors.orange;

      default:
        return colorScheme.primary;
    }
  }

  // ============================================================
  // NETWORK TEXT
  // ============================================================

  String _networkText(
      SwapTransaction swap,
      ) {
    final fromNetwork =
    swap.fromNetwork.isEmpty
        ? 'Network'
        : swap.fromNetwork;

    final toNetwork =
    swap.toNetwork.isEmpty
        ? 'Network'
        : swap.toNetwork;

    return '$fromNetwork → $toNetwork';
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatDateTime(
      DateTime date,
      ) {
    final day =
    date.day.toString().padLeft(
      2,
      '0',
    );

    final month =
    date.month.toString().padLeft(
      2,
      '0',
    );

    final hour =
    date.hour % 12 == 0
        ? 12
        : date.hour % 12;

    final minute =
    date.minute.toString().padLeft(
      2,
      '0',
    );

    final period =
    date.hour >= 12
        ? 'PM'
        : 'AM';

    return '$day/$month/${date.year} '
        '$hour:$minute $period';
  }

  // ============================================================
  // NUMBER
  // ============================================================

  String _formatNumber(
      double value,
      ) {
    if (value == 0) {
      return '0';
    }

    if (value.abs() >= 1000) {
      return value.toStringAsFixed(2);
    }

    if (value.abs() >= 1) {
      return value.toStringAsFixed(4);
    }

    return value.toStringAsFixed(8);
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
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
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
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Swap History',
          style: TextStyle(
            fontWeight:
            FontWeight.w800,
          ),
        ),
        actions: [
          if (_swaps.isNotEmpty)
            IconButton(
              tooltip: 'Clear history',
              onPressed: _clearHistory,
              icon: const Icon(
                Icons.delete_outline_rounded,
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: _loadSwaps,
        child: _swaps.isEmpty
            ? _emptyState()
            : ListView.builder(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding:
          const EdgeInsets.fromLTRB(
            18,
            8,
            18,
            30,
          ),
          itemCount:
          _swaps.length + 1,
          itemBuilder:
              (context, index) {
            if (index == 0) {
              return _buildHeader(
                context,
              );
            }

            return _swapCard(
              _swaps[index - 1],
            );
          },
        ),
      ),
    );
  }
}