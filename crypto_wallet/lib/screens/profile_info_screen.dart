import 'package:flutter/material.dart';

import 'customer_support_screen.dart';

class ProfileInfoScreen extends StatelessWidget {
  const ProfileInfoScreen({
    super.key,
  });

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

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor:
        const Color(0xFFF7F8FA),
        elevation: 0,
        centerTitle: true,

        title: const Text(
          'Profile Info',
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
            Navigator.of(context)
                .pop();
          },
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================

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
              // PROFILE
              // ==================================================

              _buildProfileCard(
                context,
              ),

              const SizedBox(
                height: 20,
              ),

              // ==================================================
              // CUSTOMER SUPPORT
              // ==================================================

              _buildCustomerSupportCard(
                context,
              ),

              const SizedBox(
                height: 20,
              ),

              // ==================================================
              // SECURITY
              // ==================================================

              _buildSecurityNotice(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE CARD
  // ============================================================

  Widget _buildProfileCard(
      BuildContext context,
      ) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(20),

      decoration:
      BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(
          20,
        ),

        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(
              0.04,
            ),
            blurRadius: 14,
            offset:
            const Offset(
              0,
              5,
            ),
          ),
        ],
      ),

      child: Row(
        children: [
          // ==================================================
          // PROFILE ICON
          // ==================================================

          Container(
            width: 58,
            height: 58,

            decoration:
            BoxDecoration(
              color:
              const Color(
                0xFFEEF2FF,
              ),

              borderRadius:
              BorderRadius.circular(
                18,
              ),
            ),

            child: const Icon(
              Icons.person_outline,
              size: 30,
              color:
              Color(0xFF4F46E5),
            ),
          ),

          const SizedBox(
            width: 15,
          ),

          // ==================================================
          // PROFILE TEXT
          // ==================================================

          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              children: [
                Text(
                  'Wallet Owner',
                  style:
                  TextStyle(
                    fontSize: 17,
                    fontWeight:
                    FontWeight.w700,
                    color:
                    Color(
                      0xFF111827,
                    ),
                  ),
                ),

                SizedBox(
                  height: 5,
                ),

                Text(
                  'Personal Wallet',
                  style:
                  TextStyle(
                    fontSize: 13,
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
  // CUSTOMER SUPPORT CARD
  // ============================================================

  Widget _buildCustomerSupportCard(
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
            color:
            Colors.black.withOpacity(
              0.04,
            ),
            blurRadius: 14,
            offset:
            const Offset(
              0,
              5,
            ),
          ),
        ],
      ),

      child: InkWell(
        borderRadius:
        BorderRadius.circular(
          20,
        ),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (BuildContext context) {
                return const CustomerSupportScreen();
              },
            ),
          );
        },

        child: Row(
          children: [
            // ==================================================
            // SUPPORT ICON
            // ==================================================

            Container(
              width: 50,
              height: 50,

              decoration:
              BoxDecoration(
                color:
                const Color(
                  0xFFEEF2FF,
                ),

                borderRadius:
                BorderRadius.circular(
                  15,
                ),
              ),

              child: const Icon(
                Icons
                    .support_agent_outlined,
                color:
                Color(0xFF4F46E5),
                size: 27,
              ),
            ),

            const SizedBox(
              width: 14,
            ),

            // ==================================================
            // SUPPORT TEXT
            // ==================================================

            const Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,

                children: [
                  Text(
                    'Customer Support',
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
                    height: 5,
                  ),

                  Text(
                    'Get help or contact our community',
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

            // ==================================================
            // ARROW
            // ==================================================

            const Icon(
              Icons.arrow_forward_ios,
              color:
              Color(0xFF9CA3AF),
              size: 17,
            ),
          ],
        ),
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
      const EdgeInsets.all(18),

      decoration:
      BoxDecoration(
        color:
        const Color(0xFFF0FDF4),

        borderRadius:
        BorderRadius.circular(
          18,
        ),

        border: Border.all(
          color:
          const Color(0xFFBBF7D0),
        ),
      ),

      child: const Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Icon(
            Icons
                .security_outlined,
            color:
            Color(0xFF16A34A),
            size: 24,
          ),

          SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              children: [
                Text(
                  'Keep your wallet secure',
                  style:
                  TextStyle(
                    fontSize: 14,
                    fontWeight:
                    FontWeight.w700,
                    color:
                    Color(
                      0xFF166534,
                    ),
                  ),
                ),

                SizedBox(
                  height: 6,
                ),

                Text(
                  'Never share your private key, recovery '
                      'phrase, password, or other sensitive '
                      'wallet information with anyone.',
                  style:
                  TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color:
                    Color(
                      0xFF166534,
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
}