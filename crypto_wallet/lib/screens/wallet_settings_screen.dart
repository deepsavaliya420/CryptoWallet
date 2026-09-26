import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/user_service.dart';

class WalletSettingsScreen extends StatefulWidget {
  const WalletSettingsScreen({
    super.key,
  });

  @override
  State<WalletSettingsScreen> createState() =>
      _WalletSettingsScreenState();
}

class _WalletSettingsScreenState
    extends State<WalletSettingsScreen> {
  late final TextEditingController walletNameController;

  @override
  void initState() {
    super.initState();

    walletNameController =
        TextEditingController(
          text: UserService.settings.walletName,
        );
  }

  @override
  void dispose() {
    walletNameController.dispose();
    super.dispose();
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void showMessage(
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
  // SAVE SETTINGS
  // ============================================================

  void saveSettings() {
    UserService.updateWalletSettings(
      walletName:
      walletNameController.text.trim().isEmpty
          ? 'My Main Wallet'
          : walletNameController.text.trim(),
      defaultNetwork:
      UserService.settings.defaultNetwork,
      displayCurrency:
      UserService.settings.displayCurrency,
    );

    showMessage(
      'Wallet settings updated.',
    );
  }

  // ============================================================
  // COPY ADDRESS
  // ============================================================

  Future<void> copyAddress() async {
    final String address =
        UserService.currentUser?.walletAddress.trim() ?? '';

    if (address.isEmpty) {
      showMessage(
        'Wallet address is not available.',
        isError: true,
      );
      return;
    }

    try {
      await Clipboard.setData(
        ClipboardData(
          text: address,
        ),
      );

      if (!mounted) return;

      showMessage(
        'Wallet address copied.',
      );
    } catch (e) {
      if (!mounted) return;

      showMessage(
        'Failed to copy wallet address.',
        isError: true,
      );
    }
  }

  // ============================================================
  // NETWORK OPTION
  // ============================================================

  Widget _networkOption({
    required BuildContext context,
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
  }) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final settings =
        UserService.settings;

    final selected =
        settings.defaultNetwork == value;

    return InkWell(
      borderRadius:
      BorderRadius.circular(15),
      onTap: () {
        setState(() {
          settings.defaultNetwork =
              value;
        });
      },
      child: AnimatedContainer(
        duration:
        const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme
              .primaryContainer
              .withValues(alpha: 0.55)
              : colorScheme.surface,
          borderRadius:
          BorderRadius.circular(15),
          border: Border.all(
            color: selected
                ? colorScheme.primary
                : colorScheme.outlineVariant
                .withValues(alpha: 0.4),
            width: selected ? 1.3 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? colorScheme.primary
                    : colorScheme
                    .surfaceContainerHighest,
                borderRadius:
                BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: selected
                    ? colorScheme.onPrimary
                    : colorScheme
                    .onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                      FontWeight.w700,
                      color: selected
                          ? colorScheme
                          .onPrimaryContainer
                          : null,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AnimatedContainer(
              duration:
              const Duration(milliseconds: 180),
              width: 21,
              height: 21,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? colorScheme.primary
                      : colorScheme
                      .outlineVariant,
                  width: 2,
                ),
                color: selected
                    ? colorScheme.primary
                    : Colors.transparent,
              ),
              child: selected
                  ? Icon(
                Icons.check_rounded,
                size: 14,
                color:
                colorScheme.onPrimary,
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DISPLAY CURRENCY
  // ============================================================

  Widget _currencyDropdown(
      BuildContext context,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final settings =
        UserService.settings;

    return DropdownButtonFormField<String>(
      initialValue:
      settings.displayCurrency,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Display Currency',
        prefixIcon: Icon(
          Icons.currency_exchange_rounded,
          color: colorScheme.primary,
        ),
        filled: true,
        fillColor:
        colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(15),
          borderSide: BorderSide(
            color: colorScheme
                .outlineVariant
                .withValues(alpha: 0.45),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(15),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1.5,
          ),
        ),
      ),
      items: const [
        DropdownMenuItem(
          value: 'USD',
          child: Text(
            'USD - US Dollar',
          ),
        ),
        DropdownMenuItem(
          value: 'EUR',
          child: Text(
            'EUR - Euro',
          ),
        ),
        DropdownMenuItem(
          value: 'INR',
          child: Text(
            'INR - Indian Rupee',
          ),
        ),
        DropdownMenuItem(
          value: 'GBP',
          child: Text(
            'GBP - British Pound',
          ),
        ),
      ],
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          settings.displayCurrency =
              value;
        });
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final user = UserService.currentUser;
    final settings = UserService.settings;
    final colorScheme =
        Theme.of(context).colorScheme;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Wallet Settings',
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons
                      .account_balance_wallet_outlined,
                  size: 55,
                  color: colorScheme
                      .onSurfaceVariant,
                ),
                const SizedBox(height: 15),
                const Text(
                  'No user is currently logged in.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wallet Settings',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding:
          const EdgeInsets.fromLTRB(
            18,
            8,
            18,
            30,
          ),
          children: [
            // ==================================================
            // HERO
            // ==================================================

            Container(
              padding:
              const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin:
                  Alignment.topLeft,
                  end:
                  Alignment.bottomRight,
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
                    offset:
                    const Offset(0, 9),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 57,
                    height: 57,
                    decoration:
                    BoxDecoration(
                      color: Colors.white
                          .withValues(
                        alpha: 0.15,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons
                          .account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Text(
                          'Wallet Preferences',
                          style: TextStyle(
                            color:
                            Colors.white,
                            fontSize: 18,
                            fontWeight:
                            FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Personalize how your wallet looks and works',
                          style: TextStyle(
                            color:
                            Colors.white70,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // WALLET PROFILE
            // ==================================================

            _sectionTitle(
              context,
              'Wallet Profile',
              Icons.person_outline_rounded,
            ),

            const SizedBox(height: 10),

            Container(
              padding:
              const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius:
                BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wallet Name',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller:
                    walletNameController,
                    textCapitalization:
                    TextCapitalization.words,
                    decoration:
                    InputDecoration(
                      hintText:
                      'My Main Wallet',
                      prefixIcon: Icon(
                        Icons
                            .account_balance_wallet_outlined,
                        color: colorScheme
                            .primary,
                      ),
                      filled: true,
                      fillColor: colorScheme
                          .surfaceContainerLow,
                      border:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(
                          15,
                        ),
                        borderSide:
                        BorderSide.none,
                      ),
                      enabledBorder:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(
                          15,
                        ),
                        borderSide: BorderSide(
                          color: colorScheme
                              .outlineVariant
                              .withValues(
                            alpha: 0.45,
                          ),
                        ),
                      ),
                      focusedBorder:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(
                          15,
                        ),
                        borderSide: BorderSide(
                          color: colorScheme
                              .primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ==================================================
            // WALLET ADDRESS
            // ==================================================

            _sectionTitle(
              context,
              'Wallet Address',
              Icons.link_rounded,
            ),

            const SizedBox(height: 10),

            Container(
              padding:
              const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius:
                BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration:
                        BoxDecoration(
                          color: colorScheme
                              .primaryContainer,
                          borderRadius:
                          BorderRadius.circular(
                            12,
                          ),
                        ),
                        child: Icon(
                          Icons
                              .account_balance_wallet_outlined,
                          color: colorScheme
                              .onPrimaryContainer,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Your wallet address',
                          style: TextStyle(
                            fontWeight:
                            FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.verified_outlined,
                        size: 19,
                        color:
                        colorScheme.primary,
                      ),
                    ],
                  ),

                  const SizedBox(height: 13),

                  Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme
                          .surfaceContainerLow,
                      borderRadius:
                      BorderRadius.circular(
                        13,
                      ),
                    ),
                    child: SelectableText(
                      user.walletAddress.isEmpty
                          ? 'Wallet address not available'
                          : user.walletAddress,
                      style: TextStyle(
                        fontSize: 10.5,
                        height: 1.4,
                        color: colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed:
                      user.walletAddress.isEmpty
                          ? null
                          : copyAddress,
                      icon: const Icon(
                        Icons.copy_outlined,
                        size: 18,
                      ),
                      label: const Text(
                        'Copy Address',
                      ),
                      style: OutlinedButton
                          .styleFrom(
                        minimumSize:
                        const Size(
                          double.infinity,
                          46,
                        ),
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
            ),

            const SizedBox(height: 22),

            // ==================================================
            // NETWORK
            // ==================================================

            _sectionTitle(
              context,
              'Default Network',
              Icons.lan_outlined,
            ),

            const SizedBox(height: 5),

            Text(
              'Choose the network you prefer to use by default.',
              style: TextStyle(
                fontSize: 10.5,
                color:
                colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              padding:
              const EdgeInsets.symmetric(
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius:
                BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                children: [
                  _networkOption(
                    context: context,
                    title: 'Ethereum',
                    subtitle: 'ERC-20',
                    value: 'Ethereum',
                    icon:
                    Icons.currency_bitcoin_rounded,
                  ),
                  _networkOption(
                    context: context,
                    title: 'BNB Chain',
                    subtitle: 'BEP-20',
                    value: 'BNB Chain',
                    icon:
                    Icons.account_tree_outlined,
                  ),
                  _networkOption(
                    context: context,
                    title: 'Solana',
                    value: 'Solana',
                    icon:
                    Icons.bolt_rounded,
                  ),
                  _networkOption(
                    context: context,
                    title: 'TRON',
                    subtitle: 'TRC-20',
                    value: 'TRON',
                    icon:
                    Icons.link_rounded,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ==================================================
            // DISPLAY CURRENCY
            // ==================================================

            _sectionTitle(
              context,
              'Display Currency',
              Icons.currency_exchange_rounded,
            ),

            const SizedBox(height: 5),

            Text(
              'Choose the currency used to display wallet values.',
              style: TextStyle(
                fontSize: 10.5,
                color:
                colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 10),

            _currencyDropdown(context),

            const SizedBox(height: 22),

            // ==================================================
            // SECURITY NOTICE
            // ==================================================

            Container(
              padding:
              const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: colorScheme
                    .surfaceContainerLow,
                borderRadius:
                BorderRadius.circular(17),
                border: Border.all(
                  color: colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons
                        .security_outlined,
                    size: 20,
                    color:
                    colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        const Text(
                          'Wallet Security',
                          style: TextStyle(
                            fontWeight:
                            FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(
                            height: 4),
                        Text(
                          'Never share your wallet address together '
                              'with private keys or recovery information.',
                          style: TextStyle(
                            fontSize: 10,
                            height: 1.4,
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

            const SizedBox(height: 18),

            // ==================================================
            // SAVE
            // ==================================================

            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: saveSettings,
                icon: const Icon(
                  Icons.save_outlined,
                ),
                label: const Text(
                  'Save Wallet Settings',
                  style: TextStyle(
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            // ==================================================
            // EXPORT WALLET
            // ==================================================

            _sectionTitle(
              context,
              'Advanced',
              Icons.tune_rounded,
            ),

            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius:
                BorderRadius.circular(19),
                border: Border.all(
                  color: colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.4),
                ),
              ),
              child: ListTile(
                contentPadding:
                const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 6,
                ),
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colorScheme
                        .errorContainer,
                    borderRadius:
                    BorderRadius.circular(13),
                  ),
                  child: Icon(
                    Icons
                        .file_download_outlined,
                    color: colorScheme
                        .onErrorContainer,
                  ),
                ),
                title: const Text(
                  'Export Wallet',
                  style: TextStyle(
                    fontWeight:
                    FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                subtitle: const Padding(
                  padding:
                  EdgeInsets.only(top: 3),
                  child: Text(
                    'Secure wallet export is not available yet.',
                    style: TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                ),
                onTap: () {
                  showMessage(
                    'Secure wallet export is not available yet.',
                  );
                },
              ),
            ),

            const SizedBox(height: 15),

            Center(
              child: Text(
                'Wallet settings are stored for your account.',
                style: TextStyle(
                  fontSize: 9.5,
                  color: colorScheme
                      .onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
      BuildContext context,
      String title,
      IconData icon,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 19,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ],
    );
  }
}