import 'package:flutter/material.dart';

import '../services/user_service.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({
    super.key,
  });

  @override
  State<SecurityScreen> createState() =>
      _SecurityScreenState();
}

class _SecurityScreenState
    extends State<SecurityScreen> {
  void showMessage(
      String message, {
        bool isError = false,
      }) {
    if (!mounted) {
      return;
    }

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

  void showChangePasswordDialog() {
    final passwordController =
    TextEditingController();

    final confirmController =
    TextEditingController();

    bool obscurePassword = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        final colorScheme =
            Theme.of(dialogContext).colorScheme;

        return StatefulBuilder(
          builder: (
              context,
              setDialogState,
              ) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(23),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.lock_reset_rounded,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Change Password',
                    style: TextStyle(
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Text(
                    'Create a strong password for your ChainVault account.',
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.4,
                      color: colorScheme
                          .onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 17),

                  TextField(
                    controller:
                    passwordController,
                    obscureText:
                    obscurePassword,
                    decoration:
                    InputDecoration(
                      labelText:
                      'New Password',
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                      ),
                      suffixIcon:
                      IconButton(
                        onPressed: () {
                          setDialogState(() {
                            obscurePassword =
                            !obscurePassword;
                          });
                        },
                        icon: Icon(
                          obscurePassword
                              ? Icons
                              .visibility_outlined
                              : Icons
                              .visibility_off_outlined,
                        ),
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
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller:
                    confirmController,
                    obscureText:
                    obscureConfirm,
                    decoration:
                    InputDecoration(
                      labelText:
                      'Confirm Password',
                      prefixIcon: const Icon(
                        Icons.verified_user_outlined,
                      ),
                      suffixIcon:
                      IconButton(
                        onPressed: () {
                          setDialogState(() {
                            obscureConfirm =
                            !obscureConfirm;
                          });
                        },
                        icon: Icon(
                          obscureConfirm
                              ? Icons
                              .visibility_outlined
                              : Icons
                              .visibility_off_outlined,
                        ),
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
                    ),
                  ),

                  const SizedBox(height: 13),

                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color:
                        colorScheme.primary,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          'Password must contain at least 8 characters.',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
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
                  child: const Text(
                    'Cancel',
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {
                    final password =
                        passwordController
                            .text;

                    final confirm =
                        confirmController
                            .text;

                    if (password.length < 8) {
                      showMessage(
                        'Password must contain at least 8 characters.',
                        isError: true,
                      );
                      return;
                    }

                    if (password != confirm) {
                      showMessage(
                        'Passwords do not match.',
                        isError: true,
                      );
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                    );

                    showMessage(
                      'Password change will be connected to authentication.',
                    );
                  },
                  icon: const Icon(
                    Icons.check_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'Update',
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      passwordController.dispose();
      confirmController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings =
        UserService.settings;

    final colorScheme =
        Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Security',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            18,
            8,
            18,
            30,
          ),
          children: [
            _buildSecurityHeader(context),

            const SizedBox(height: 23),

            _buildSectionTitle(
              context,
              'Account Protection',
              'Manage how your ChainVault account is secured.',
            ),

            const SizedBox(height: 13),

            _buildSecurityOptions(
              context,
              settings,
            ),

            const SizedBox(height: 23),

            _buildSecurityStatus(
              context,
              settings,
            ),

            const SizedBox(height: 16),

            _buildWarningCard(
              context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityHeader(
      BuildContext context,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
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
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.15,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: 31,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account Security',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Protect your wallet and keep your account secure.',
                  style: TextStyle(
                    color: Colors.white
                        .withValues(alpha: 0.78),
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      BuildContext context,
      String title,
      String subtitle,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight:
            FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: colorScheme
                .onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityOptions(
      BuildContext context,
      dynamic settings,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
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
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPasswordOption(
            context,
          ),

          _buildDivider(context),

          _buildSwitchOption(
            context: context,
            icon:
            Icons.fingerprint_rounded,
            title: 'Biometric Login',
            subtitle:
            'Use fingerprint or Face ID',
            value:
            settings.biometricLogin,
            onChanged: (value) {
              setState(() {
                settings.biometricLogin =
                    value;
              });

              showMessage(
                value
                    ? 'Biometric login enabled.'
                    : 'Biometric login disabled.',
              );
            },
          ),

          _buildDivider(context),

          _buildSwitchOption(
            context: context,
            icon:
            Icons.verified_user_outlined,
            title:
            'Two-Factor Authentication',
            subtitle:
            'Add an additional security layer',
            value: settings
                .twoFactorAuthentication,
            onChanged: (value) {
              setState(() {
                settings
                    .twoFactorAuthentication =
                    value;
              });

              showMessage(
                value
                    ? 'Two-factor authentication enabled.'
                    : 'Two-factor authentication disabled.',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordOption(
      BuildContext context,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
        const BorderRadius.vertical(
          top: Radius.circular(21),
        ),
        onTap: showChangePasswordDialog,
        child: Padding(
          padding:
          const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color:
                  colorScheme.primaryContainer,
                  borderRadius:
                  BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  color: colorScheme
                      .onPrimaryContainer,
                  size: 22,
                ),
              ),

              const SizedBox(width: 13),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Update your account password',
                      style: TextStyle(
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: colorScheme
                    .onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),
      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color:
              colorScheme.primaryContainer,
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: colorScheme
                  .onPrimaryContainer,
              size: 22,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: colorScheme
                        .onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          Switch.adaptive(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(
      BuildContext context,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Divider(
      height: 1,
      indent: 75,
      color: colorScheme
          .outlineVariant
          .withValues(alpha: 0.38),
    );
  }

  Widget _buildSecurityStatus(
      BuildContext context,
      dynamic settings,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final biometricEnabled =
        settings.biometricLogin;

    final twoFactorEnabled =
        settings.twoFactorAuthentication;

    final enabledCount =
        (biometricEnabled ? 1 : 0) +
            (twoFactorEnabled ? 1 : 0);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme
              .outlineVariant
              .withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: enabledCount == 2
                  ? Colors.green
                  .withValues(alpha: 0.10)
                  : colorScheme
                  .primaryContainer,
              borderRadius:
              BorderRadius.circular(13),
            ),
            child: Icon(
              enabledCount == 2
                  ? Icons.verified_user_rounded
                  : Icons.shield_outlined,
              color: enabledCount == 2
                  ? Colors.green
                  : colorScheme.primary,
              size: 21,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  enabledCount == 2
                      ? 'Enhanced Protection'
                      : 'Security Protection',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  enabledCount == 0
                      ? 'Enable biometric or 2FA for additional protection.'
                      : '$enabledCount of 2 additional security features enabled.',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: colorScheme
                        .onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard(
      BuildContext context,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme
            .errorContainer
            .withValues(alpha: 0.38),
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.error
              .withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.error
                  .withValues(alpha: 0.10),
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: colorScheme.error,
              size: 21,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Security Warning',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight:
                    FontWeight.w800,
                    color: colorScheme
                        .onErrorContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Never share your password, recovery phrase, '
                      'or private key with anyone. ChainVault will '
                      'never ask you to send these details.',
                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.5,
                    color: colorScheme
                        .onErrorContainer,
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