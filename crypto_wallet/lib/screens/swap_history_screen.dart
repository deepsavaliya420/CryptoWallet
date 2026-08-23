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
      final swaps = await SwapService.getSwaps();

      if (!mounted) return;

      setState(() {
        _swaps = List<SwapTransaction>.from(swaps);
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

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Clear Swap History?',
          ),
          content: const Text(
            'This removes saved swap history from this device. '
                'Your wallet balances will not be changed.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text(
                'Clear',
              ),
            ),
          ],
        );
      },
    );

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
  // DETAILS
  // ============================================================

  void _showSwapDetails(
      SwapTransaction swap,
      ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              30,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Swap Details',
                  style: Theme.of(sheetContext)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                _detailRow(
                  'Status',
                  swap.status.toUpperCase(),
                ),

                _detailRow(
                  'From',
                  '${_formatNumber(swap.fromAmount)} '
                      '${swap.fromCurrency}',
                ),

                _detailRow(
                  'From Network',
                  swap.fromNetwork,
                ),

                _detailRow(
                  'To',
                  '${_formatNumber(swap.toAmount)} '
                      '${swap.toCurrency}',
                ),

                _detailRow(
                  'To Network',
                  swap.toNetwork,
                ),

                _detailRow(
                  'Exchange Rate',
                  '1 ${swap.fromCurrency} = '
                      '${_formatNumber(swap.exchangeRate)} '
                      '${swap.toCurrency}',
                ),

                _detailRow(
                  'Fee',
                  '${_formatNumber(swap.fee)} '
                      '${swap.fromCurrency}',
                ),

                _detailRow(
                  'Date',
                  _formatDateTime(
                    swap.timestamp,
                  ),
                ),

                _detailRow(
                  'Transaction ID',
                  swap.id,
                ),

                const SizedBox(
                  height: 12,
                ),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                    },
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
  // DETAIL ROW
  // ============================================================

  Widget _detailRow(
      String title,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
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

    final bool completed =
        swap.status.toLowerCase() ==
            'completed';

    final Color statusColor =
    completed
        ? Colors.green
        : colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          _showSwapDetails(swap);
        },
        child: Padding(
          padding: const EdgeInsets.all(
            16,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                    colorScheme
                        .primaryContainer,
                    child: Icon(
                      Icons.swap_horiz_rounded,
                      color: colorScheme
                          .onPrimaryContainer,
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Swap',
                          style: TextStyle(
                            fontWeight:
                            FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        Text(
                          '${swap.fromCurrency} → '
                              '${swap.toCurrency}',
                          style: TextStyle(
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
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration:
                    BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(
                        20,
                      ),
                      color: statusColor
                          .withValues(
                        alpha: 0.12,
                      ),
                    ),
                    child: Text(
                      swap.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight:
                        FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 16,
              ),

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

                  const Padding(
                    padding:
                    EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 20,
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

              const SizedBox(
                height: 14,
              ),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${swap.fromNetwork} → '
                          '${swap.toNetwork}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Text(
                    _formatDateTime(
                      swap.timestamp,
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
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
      padding: const EdgeInsets.all(
        12,
      ),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(10),
        color: colorScheme
            .surfaceContainerHighest,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme
                  .onSurfaceVariant,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            amount,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 2,
          ),

          Text(
            currency,
            style: const TextStyle(
              fontSize: 12,
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

    return Center(
      child: Padding(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 80,
        ),
        child: Column(
          children: [
            Icon(
              Icons.swap_horizontal_circle_outlined,
              size: 70,
              color: colorScheme
                  .onSurfaceVariant,
            ),

            const SizedBox(
              height: 18,
            ),

            Text(
              'No swaps yet',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'Your completed currency exchanges '
                  'will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme
                    .onSurfaceVariant,
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.swap_horiz,
              ),
              label: const Text(
                'Start a Swap',
              ),
            ),
          ],
        ),
      ),
    );
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

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
        isError ? Colors.red : null,
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
        ),
        actions: [
          if (_swaps.isNotEmpty)
            IconButton(
              tooltip: 'Clear history',
              onPressed: _clearHistory,
              icon: const Icon(
                Icons.delete_outline,
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
            ? ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          children: [
            _emptyState(),
          ],
        )
            : ListView.builder(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding:
          const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            24,
          ),
          itemCount:
          _swaps.length,
          itemBuilder:
              (context, index) {
            return _swapCard(
              _swaps[index],
            );
          },
        ),
      ),
    );
  }
}