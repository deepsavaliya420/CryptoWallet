import 'package:flutter/material.dart';

import '../models/receive_request.dart';
import '../services/receive_request_service.dart';
import '../services/transaction_service.dart';
import '../services/wallet_service.dart';

class ReceiveRequestsScreen extends StatefulWidget {
  const ReceiveRequestsScreen({
    super.key,
  });

  @override
  State<ReceiveRequestsScreen> createState() =>
      _ReceiveRequestsScreenState();
}

class _ReceiveRequestsScreenState
    extends State<ReceiveRequestsScreen> {
  List<ReceiveRequest> _requests = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final requests =
      await ReceiveRequestService.getRequests();

      if (!mounted) return;

      setState(() {
        _requests = requests;
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
  // MARK RECEIVED
  // ============================================================

  Future<void> _completeRequest(
      ReceiveRequest request,
      ) async {
    if (request.status.toLowerCase() != 'pending') {
      _showMessage(
        'This request is no longer pending.',
        isError: true,
      );
      return;
    }

    final confirmed =
    await _confirmReceived(request);

    if (confirmed != true) {
      return;
    }

    try {
      /*
       * IMPORTANT:
       *
       * The wallet is credited first.
       * If crediting fails, the request remains pending.
       */

      await WalletService.addUSDT(
        request.amount,
      );

      /*
       * Create the Received transaction.
       *
       * requestedFrom = wallet that sent the funds
       * requestedTo   = our wallet
       */

      await TransactionService.createTransaction(
        type: 'Received',
        asset: request.asset,
        network: request.network,
        amount: request.amount,
        value: request.amount,
        from: request.requestedFrom,
        to: request.requestedTo,
      );

      /*
       * Only after the wallet and transaction
       * have been successfully updated do we
       * mark the request as completed.
       */

      await ReceiveRequestService.completeRequest(
        request.id,
      );

      await _loadRequests();

      if (!mounted) return;

      _showMessage(
        '${request.amount.toStringAsFixed(2)} '
            '${request.asset} received successfully.',
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
  // CONFIRM RECEIVED
  // ============================================================

  Future<bool?> _confirmReceived(
      ReceiveRequest request,
      ) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Confirm Receipt',
          ),
          content: Text(
            'Confirm that you actually received '
                '${request.amount.toStringAsFixed(2)} '
                '${request.asset} from '
                '${_shortAddress(request.requestedFrom)}?',
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
                'Not Yet',
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
                'I Received It',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // CANCEL
  // ============================================================

  Future<void> _cancelRequest(
      ReceiveRequest request,
      ) async {
    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Cancel Request?',
          ),
          content: Text(
            'Cancel the request for '
                '${request.amount.toStringAsFixed(2)} '
                '${request.asset}?',
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
                'Keep',
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
                'Cancel Request',
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
      await ReceiveRequestService.cancelRequest(
        request.id,
      );

      await _loadRequests();

      if (!mounted) return;

      _showMessage(
        'Receive request cancelled.',
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
  // DELETE
  // ============================================================

  Future<void> _deleteRequest(
      ReceiveRequest request,
      ) async {
    try {
      await ReceiveRequestService.deleteRequest(
        request.id,
      );

      await _loadRequests();

      if (!mounted) return;

      _showMessage(
        'Request deleted.',
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
  // CONFIRM DELETE
  // ============================================================

  Future<bool?> _confirmDelete(
      ReceiveRequest request,
      ) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Request?',
          ),
          content: const Text(
            'This only removes the request '
                'from this device.',
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
                'Delete',
              ),
            ),
          ],
        );
      },
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
        content: Text(message),
        backgroundColor:
        isError ? Colors.red : null,
        behavior:
        SnackBarBehavior.floating,
      ),
    );
  }

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
  // STATUS
  // ============================================================

  Color _statusColor(
      String status,
      ) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;

      case 'cancelled':
        return Colors.red;

      default:
        return Colors.orange;
    }
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatDate(
      DateTime date,
      ) {
    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    final year =
    date.year.toString();

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

    return '$day/$month/$year '
        '$hour:$minute $period';
  }

  // ============================================================
  // SHORT ADDRESS
  // ============================================================

  String _shortAddress(
      String address,
      ) {
    if (address.length <= 18) {
      return address;
    }

    return '${address.substring(0, 8)}...'
        '${address.substring(address.length - 6)}';
  }

  // ============================================================
  // REQUEST CARD
  // ============================================================

  Widget _buildRequestCard(
      ReceiveRequest request,
      ) {
    final status =
    request.status.toLowerCase();

    final statusColor =
    _statusColor(status);

    return Card(
      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Icon(
                    status == 'completed'
                        ? Icons.check
                        : status == 'cancelled'
                        ? Icons.close
                        : Icons
                        .hourglass_top,
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
                        'Receive Request',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        request.id,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                          Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
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
                  decoration:
                  BoxDecoration(
                    color:
                    statusColor.withValues(
                      alpha: 0.12,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Text(
                    request.status
                        .toUpperCase(),
                    style: TextStyle(
                      color:
                      statusColor,
                      fontSize: 11,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 18,
            ),

            Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,
              children: [
                const Text(
                  'Requested',
                ),
                Text(
                  '${request.amount.toStringAsFixed(2)} '
                      '${request.asset}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 14,
            ),

            Text(
              'Requested from',
              style: TextStyle(
                fontSize: 12,
                color:
                Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            SelectableText(
              request.requestedFrom,
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              'Receive into',
              style: TextStyle(
                fontSize: 12,
                color:
                Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            SelectableText(
              request.requestedTo,
            ),

            const SizedBox(
              height: 12,
            ),

            Row(
              children: [
                const Icon(
                  Icons.lan_outlined,
                  size: 16,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  request.network,
                ),
                const Spacer(),
                Text(
                  _formatDate(
                    request.createdAt,
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color:
                    Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                ),
              ],
            ),

            // ==================================================
            // PENDING ACTIONS
            // ==================================================

            if (status == 'pending') ...[
              const SizedBox(
                height: 16,
              ),

              Row(
                children: [
                  Expanded(
                    child:
                    OutlinedButton(
                      onPressed: () =>
                          _cancelRequest(
                            request,
                          ),
                      child: const Text(
                        'Cancel',
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child:
                    FilledButton(
                      onPressed: () =>
                          _completeRequest(
                            request,
                          ),
                      child: const Text(
                        'I Received It',
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // ==================================================
            // COMPLETED / CANCELLED
            // ==================================================

            if (status != 'pending') ...[
              const SizedBox(
                height: 12,
              ),

              Align(
                alignment:
                Alignment.centerRight,
                child: IconButton(
                  tooltip:
                  'Delete request',
                  onPressed: () async {
                    final confirmed =
                    await _confirmDelete(
                      request,
                    );

                    if (confirmed == true) {
                      await _deleteRequest(
                        request,
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Receive Requests',
        ),
      ),

      body: _isLoading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh:
        _loadRequests,
        child: _requests.isEmpty
            ? ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(
              height: 180,
            ),
            Center(
              child: Icon(
                Icons
                    .request_quote_outlined,
                size: 52,
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Center(
              child: Text(
                'No receive requests',
              ),
            ),
          ],
        )
            : ListView.builder(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding:
          const EdgeInsets.all(
            16,
          ),
          itemCount:
          _requests.length,
          itemBuilder:
              (context, index) {
            return _buildRequestCard(
              _requests[index],
            );
          },
        ),
      ),
    );
  }
}