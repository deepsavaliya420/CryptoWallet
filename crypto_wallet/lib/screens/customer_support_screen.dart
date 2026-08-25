import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomerSupportScreen extends StatelessWidget {
  const CustomerSupportScreen({
    super.key,
  });

  // ============================================================
  // SUPPORT NUMBERS
  //
  // Replace these with your real support numbers.
  // ============================================================

  static const String supportNumber1 =
      '+91 98765 43210';

  static const String supportNumber2 =
      '+91 87654 32109';

  static const String communityNumber =
      '+91 91234 56789';

  // ============================================================
  // COPY NUMBER
  // ============================================================

  Future<void> _copyNumber(
      BuildContext context,
      String number,
      ) async {
    await Clipboard.setData(
      ClipboardData(
        text: number,
      ),
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Contact number copied',
        ),
        behavior:
        SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // CONTACT DIALOG
  // ============================================================

  void _showContactDialog(
      BuildContext context,
      String number,
      ) {
    showDialog<void>(
      context: context,
      builder: (
          BuildContext dialogContext,
          ) {
        return AlertDialog(
          title: const Text(
            'Contact Support',
          ),
          content: Column(
            mainAxisSize:
            MainAxisSize.min,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                'Contact our support team using this number:',
              ),
              const SizedBox(
                height: 14,
              ),
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.all(
                  14,
                ),
                decoration:
                BoxDecoration(
                  color:
                  const Color(
                    0xFFF3F4F6,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),
                child: Text(
                  number,
                  style:
                  const TextStyle(
                    fontSize: 17,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child:
              const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );

                _copyNumber(
                  context,
                  number,
                );
              },
              icon: const Icon(
                Icons.copy_outlined,
                size: 18,
              ),
              label:
              const Text('Copy'),
            ),
          ],
        );
      },
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
      backgroundColor:
      const Color(0xFFF7F8FA),

      appBar: AppBar(
        backgroundColor:
        const Color(0xFFF7F8FA),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Customer Support',
          style: TextStyle(
            color:
            Color(0xFF111827),
            fontSize: 20,
            fontWeight:
            FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color:
            Color(0xFF111827),
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              _buildHeader(),

              const SizedBox(
                height: 24,
              ),

              // ==================================================
              // INTRODUCTION
              // ==================================================

              const Text(
                'How can we help?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.w700,
                  color:
                  Color(0xFF111827),
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              const Text(
                'Our customer support team is available to '
                    'help you with wallet transactions, Send, '
                    'Receive, Swap, Asset balance, and other '
                    'wallet-related questions.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.55,
                  color:
                  Color(0xFF6B7280),
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              // ==================================================
              // SUPPORT
              // ==================================================

              const Text(
                'Contact Support',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.w700,
                  color:
                  Color(0xFF111827),
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              _buildContactCard(
                context,
                'Support Team 1',
                supportNumber1,
              ),

              _buildContactCard(
                context,
                'Support Team 2',
                supportNumber2,
              ),

              const SizedBox(
                height: 24,
              ),

              // ==================================================
              // COMMUNITY
              // ==================================================

              const Text(
                'Community Support',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.w700,
                  color:
                  Color(0xFF111827),
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              _buildCommunityCard(
                context,
              ),

              const SizedBox(
                height: 24,
              ),

              // ==================================================
              // COMMON TOPICS
              // ==================================================

              const Text(
                'Common Support Topics',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.w700,
                  color:
                  Color(0xFF111827),
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              _buildHelpCard(
                icon:
                Icons.swap_horiz,
                title:
                'Swap Issue',
                description:
                'If a currency swap does not update '
                    'your balance correctly, contact support '
                    'with the transaction details.',
              ),

              _buildHelpCard(
                icon:
                Icons.send_outlined,
                title:
                'Send Issue',
                description:
                'If a Send transaction fails or the '
                    'wallet balance does not update, contact '
                    'our support team.',
              ),

              _buildHelpCard(
                icon:
                Icons.call_received_outlined,
                title:
                'Receive Issue',
                description:
                'For Receive Requests or received '
                    'balance problems, contact support.',
              ),

              _buildHelpCard(
                icon:
                Icons
                    .account_balance_wallet_outlined,
                title:
                'Asset or Balance Issue',
                description:
                'If your Home balance or Asset balance '
                    'looks incorrect after a transaction, '
                    'contact support.',
              ),

              _buildHelpCard(
                icon:
                Icons.security_outlined,
                title:
                'Security',
                description:
                'Never share your private key, recovery '
                    'phrase, password, or other sensitive '
                    'wallet credentials with anyone.',
              ),

              const SizedBox(
                height: 20,
              ),

              // ==================================================
              // SECURITY NOTICE
              // ==================================================

              _buildSecurityNotice(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(22),
      decoration:
      BoxDecoration(
        gradient:
        const LinearGradient(
          begin:
          Alignment.topLeft,
          end:
          Alignment.bottomRight,
          colors: [
            Color(0xFF4F46E5),
            Color(0xFF6366F1),
          ],
        ),
        borderRadius:
        BorderRadius.circular(
          20,
        ),
      ),
      child: const Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.support_agent_outlined,
            color: Colors.white,
            size: 42,
          ),

          SizedBox(
            height: 14,
          ),

          Text(
            'Customer Support',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight:
              FontWeight.w700,
            ),
          ),

          SizedBox(
            height: 7,
          ),

          Text(
            'We are here to help you with your wallet.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONTACT CARD
  // ============================================================

  Widget _buildContactCard(
      BuildContext context,
      String title,
      String number,
      ) {
    return Container(
      width: double.infinity,
      margin:
      const EdgeInsets.only(
        bottom: 10,
      ),
      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(
          17,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(
              0.04,
            ),
            blurRadius: 12,
            offset:
            const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),

        leading: Container(
          width: 46,
          height: 46,
          decoration:
          BoxDecoration(
            color:
            const Color(
              0xFFEEF2FF,
            ),
            borderRadius:
            BorderRadius.circular(
              14,
            ),
          ),
          child: const Icon(
            Icons.phone_outlined,
            color:
            Color(0xFF4F46E5),
          ),
        ),

        title: Text(
          title,
          style:
          const TextStyle(
            fontWeight:
            FontWeight.w700,
            color:
            Color(0xFF111827),
          ),
        ),

        subtitle: Padding(
          padding:
          const EdgeInsets.only(
            top: 4,
          ),
          child: Text(
            number,
            style:
            const TextStyle(
              color:
              Color(0xFF6B7280),
            ),
          ),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 17,
          color:
          Color(0xFF9CA3AF),
        ),

        onTap: () {
          _showContactDialog(
            context,
            number,
          );
        },
      ),
    );
  }

  // ============================================================
  // COMMUNITY CARD
  // ============================================================

  Widget _buildCommunityCard(
      BuildContext context,
      ) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(18),
      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(
          20,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(
              0.04,
            ),
            blurRadius: 14,
            offset:
            const Offset(0, 5),
          ),
        ],
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
                decoration:
                BoxDecoration(
                  color:
                  const Color(
                    0xFFEFFDF4,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),
                child: const Icon(
                  Icons.groups_outlined,
                  color:
                  Color(0xFF16A34A),
                  size: 27,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      'Wallet Community',
                      style:
                      TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.w700,
                        color:
                        Color(
                          0xFF111827,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      'Connect with other users',
                      style:
                      TextStyle(
                        fontSize: 12,
                        color:
                        Color(
                          0xFF6B7280,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 15,
          ),

          const Text(
            'Join our community to discuss wallet '
                'features, swaps, transactions, and get '
                'help from other users.',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color:
              Color(0xFF4B5563),
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          Container(
            width: double.infinity,
            padding:
            const EdgeInsets.all(
              14,
            ),
            decoration:
            BoxDecoration(
              color:
              const Color(
                0xFFF8FAFC,
              ),
              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.phone_outlined,
                  size: 20,
                  color:
                  Color(0xFF4F46E5),
                ),

                const SizedBox(
                  width: 10,
                ),

                const Expanded(
                  child: Text(
                    communityNumber,
                    style:
                    TextStyle(
                      fontWeight:
                      FontWeight.w600,
                      color:
                      Color(
                        0xFF111827,
                      ),
                    ),
                  ),
                ),

                IconButton(
                  tooltip:
                  'Copy community number',
                  onPressed: () {
                    _copyNumber(
                      context,
                      communityNumber,
                    );
                  },
                  icon:
                  const Icon(
                    Icons.copy_outlined,
                    size: 20,
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
  // HELP CARD
  // ============================================================

  Widget _buildHelpCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      margin:
      const EdgeInsets.only(
        bottom: 10,
      ),
      padding:
      const EdgeInsets.all(16),
      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(
          16,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(
              0.035,
            ),
            blurRadius: 10,
            offset:
            const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration:
            BoxDecoration(
              color:
              const Color(
                0xFFF3F4F6,
              ),
              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),
            child: Icon(
              icon,
              color:
              const Color(
                0xFF4F46E5,
              ),
              size: 22,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  title,
                  style:
                  const TextStyle(
                    fontSize: 14,
                    fontWeight:
                    FontWeight.w700,
                    color:
                    Color(
                      0xFF111827,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  description,
                  style:
                  const TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color:
                    Color(
                      0xFF6B7280,
                    ),
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
  // SECURITY NOTICE
  // ============================================================

  Widget _buildSecurityNotice() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(17),
      decoration:
      BoxDecoration(
        color:
        const Color(0xFFFFFBEB),
        borderRadius:
        BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color:
          const Color(0xFFFDE68A),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color:
            Color(0xFFD97706),
            size: 23,
          ),

          SizedBox(
            width: 11,
          ),

          Expanded(
            child: Text(
              'Official support will never ask for your '
                  'private key, recovery phrase, password, or '
                  'other sensitive wallet credentials. Never '
                  'send these credentials to anyone.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color:
                Color(0xFF92400E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}