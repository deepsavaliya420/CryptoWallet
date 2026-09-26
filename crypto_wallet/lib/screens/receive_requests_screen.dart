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
      await WalletService.addUSDT(
        request.amount,
      );

      await TransactionService.createTransaction(
        type: 'Received',
        asset: request.asset,
        network: request.network,
        amount: request.amount,
        value: request.amount,
        from: request.requestedFrom,
        to: request.requestedTo,
      );

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

  Future<bool?> _confirmReceived(
      ReceiveRequest request,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Confirm Receipt',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
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
                  dialogContext,
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
                  dialogContext,
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

  Future<void> _cancelRequest(
      ReceiveRequest request,
      ) async {
    final colorScheme =
        Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Cancel Request?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
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
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Keep',
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
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

  Future<bool?> _confirmDelete(
      ReceiveRequest request,
      ) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colorScheme =
            Theme.of(dialogContext).colorScheme;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Delete Request?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'This will permanently remove this '
                'receive request from your account.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
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

  void _showMessage(
      String message, {
        bool isError = false,
      }) {
    if (!mounted) return;

    final colorScheme =
        Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
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
        isError ? colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _cleanError(Object error) {
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

  Color _statusColor(
      BuildContext context,
      String status,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;

      case 'cancelled':
        return colorScheme.error;

      default:
        return Colors.orange;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_rounded;

      case 'cancelled':
        return Icons.close_rounded;

      default:
        return Icons.schedule_rounded;
    }
  }

  String _formatDate(DateTime date) {
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

  String _shortAddress(String address) {
    if (address.length <= 18) {
      return address;
    }

    return '${address.substring(0, 8)}...'
        '${address.substring(address.length - 6)}';
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final pendingCount = _requests
        .where(
          (request) =>
      request.status.toLowerCase() ==
          'pending',
    )
        .length;

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
            color: colorScheme.primary.withValues(
              alpha: 0.18,
            ),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.15,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.call_received_rounded,
              color: Colors.white,
              size: 29,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Receive Requests',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pendingCount == 0
                      ? 'No pending requests'
                      : '$pendingCount pending request'
                      '${pendingCount == 1 ? '' : 's'}',
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

          if (pendingCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.15,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$pendingCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(
          alpha: 0.38,
        ),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: colorScheme.primary.withValues(
            alpha: 0.12,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Only mark a request as received after '
                  'you have actually received the funds.',
              style: TextStyle(
                fontSize: 11,
                height: 1.45,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(
      BuildContext context,
      ReceiveRequest request,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final status =
    request.status.toLowerCase();

    final statusColor =
    _statusColor(context, status);

    return Container(
      margin: const EdgeInsets.only(
        bottom: 13,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(
            alpha: 0.4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(
              alpha: 0.035,
            ),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 47,
                  height: 47,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _statusIcon(status),
                    color: statusColor,
                    size: 23,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Receive Request',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request.id,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          color:
                          colorScheme
                              .onSurfaceVariant,
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
                    color: statusColor.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                  child: Text(
                    request.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 17),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color:
                colorScheme.surfaceContainerLow,
                borderRadius:
                BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.currency_exchange_rounded,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Requested Amount',
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${request.amount.toStringAsFixed(2)} '
                              '${request.asset}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            _buildAddressRow(
              context,
              icon: Icons.person_outline_rounded,
              title: 'Requested From',
              address: request.requestedFrom,
            ),

            const SizedBox(height: 11),

            _buildAddressRow(
              context,
              icon:
              Icons.account_balance_wallet_outlined,
              title: 'Receive Into',
              address: request.requestedTo,
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Icon(
                  Icons.lan_outlined,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  request.network,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.schedule_outlined,
                  size: 15,
                  color:
                  colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 5),
                Text(
                  _formatDate(request.createdAt),
                  style: TextStyle(
                    fontSize: 10.5,
                    color:
                    colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            if (status == 'pending') ...[
              const SizedBox(height: 17),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _cancelRequest(request),
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                      ),
                      label: const Text(
                        'Cancel',
                      ),
                      style:
                      OutlinedButton.styleFrom(
                        minimumSize:
                        const Size(0, 47),
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
                            14,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () =>
                          _completeRequest(request),
                      icon: const Icon(
                        Icons.check_rounded,
                        size: 18,
                      ),
                      label: const Text(
                        'Received',
                      ),
                      style:
                      FilledButton.styleFrom(
                        minimumSize:
                        const Size(0, 47),
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
                            14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (status != 'pending') ...[
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: 'Delete request',
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
                  style: IconButton.styleFrom(
                    backgroundColor:
                    colorScheme.errorContainer
                        .withValues(alpha: 0.55),
                  ),
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color:
                    colorScheme
                        .onErrorContainer,
                    size: 20,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddressRow(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String address,
      }) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow
            .withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 9.5,
                    color:
                    colorScheme
                        .onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 3),
                SelectableText(
                  address,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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

    return ListView(
      physics:
      const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
      ),
      children: [
        const SizedBox(height: 90),

        Container(
          width: 90,
          height: 90,
          margin: const EdgeInsets.symmetric(
            horizontal: 100,
          ),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.call_received_rounded,
            size: 42,
            color: colorScheme.primary,
          ),
        ),

        const SizedBox(height: 20),

        const Center(
          child: Text(
            'No Receive Requests',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        const SizedBox(height: 7),

        Text(
          'Receive requests created by you will '
              'appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.5,
            height: 1.45,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Receive Requests',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: _loadRequests,
        child: _requests.isEmpty
            ? _buildEmptyState(context)
            : ListView(
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

            const SizedBox(height: 15),

            _buildInfoBanner(context),

            const SizedBox(height: 20),

            Text(
              '${_requests.length} '
                  '${_requests.length == 1 ? 'request' : 'requests'}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color:
                Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 10),

            ..._requests.map(
                  (request) =>
                  _buildRequestCard(
                    context,
                    request,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}