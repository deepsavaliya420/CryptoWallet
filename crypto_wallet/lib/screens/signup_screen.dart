import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({
    super.key,
  });

  @override
  State<SignupScreen> createState() =>
      _SignupScreenState();
}

class _SignupScreenState
    extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  final TextEditingController nameController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  final TextEditingController
  confirmPasswordController =
  TextEditingController();

  final TextEditingController locationController =
  TextEditingController();

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool agreeTerms = false;
  bool isCreatingAccount = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    locationController.dispose();
    super.dispose();
  }

  Future<void> createAccount() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!agreeTerms) {
      _showMessage(
        'Please accept the terms and conditions.',
        isError: true,
      );
      return;
    }

    setState(() {
      isCreatingAccount = true;
    });

    try {
      final success = await AuthService.signup(
        fullName: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        location: locationController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      if (!success) {
        _showMessage(
          'Unable to create your account.',
          isError: true,
        );
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
            (route) => false,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        _cleanError(error),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isCreatingAccount = false;
        });
      }
    }
  }

  void _showMessage(
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

  String? _validateName(
      String? value,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Please enter your full name';
    }

    if (value.trim().length < 3) {
      return 'Name must contain at least 3 characters';
    }

    return null;
  }

  String? _validateEmail(
      String? value,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Please enter your email';
    }

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(
      value.trim(),
    )) {
      return 'Enter a valid email address';
    }

    return null;
  }

  String? _validatePassword(
      String? value,
      ) {
    if (value == null ||
        value.isEmpty) {
      return 'Please enter a password';
    }

    if (value.length < 8) {
      return 'Password must contain at least 8 characters';
    }

    return null;
  }

  String? _validateConfirmPassword(
      String? value,
      ) {
    if (value == null ||
        value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  String? _validateLocation(
      String? value,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Please enter your location';
    }

    return null;
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Account',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              18,
              8,
              18,
              30,
            ),
            children: [
              _buildHeader(context),

              const SizedBox(height: 22),

              _buildSectionTitle(
                context,
                'Personal Information',
                'Tell us a little about yourself.',
              ),

              const SizedBox(height: 13),

              _buildPersonalInfoCard(
                context,
              ),

              const SizedBox(height: 22),

              _buildSectionTitle(
                context,
                'Account Security',
                'Create secure credentials for your wallet.',
              ),

              const SizedBox(height: 13),

              _buildSecurityCard(
                context,
              ),

              const SizedBox(height: 15),

              _buildLocationInfo(
                context,
              ),

              const SizedBox(height: 20),

              _buildTermsCard(
                context,
              ),

              const SizedBox(height: 20),

              _buildCreateButton(
                context,
              ),

              const SizedBox(height: 18),

              _buildLoginSection(
                context,
              ),
            ],
          ),
        ),
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
      padding: const EdgeInsets.all(21),
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
              Icons.person_add_alt_1_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Join ChainVault',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Create your secure crypto wallet account.',
                  style: TextStyle(
                    color: Colors.white
                        .withValues(alpha: 0.78),
                    fontSize: 11.5,
                    height: 1.4,
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
  // SECTION TITLE
  // ============================================================

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

  // ============================================================
  // PERSONAL INFORMATION
  // ============================================================

  Widget _buildPersonalInfoCard(
      BuildContext context,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return _buildCard(
      context,
      child: Column(
        children: [
          TextFormField(
            controller: nameController,
            textCapitalization:
            TextCapitalization.words,
            validator: _validateName,
            decoration:
            _inputDecoration(
              context,
              label: 'Full Name',
              hint: 'Enter your full name',
              icon:
              Icons.person_outline_rounded,
            ),
          ),

          const SizedBox(height: 13),

          TextFormField(
            controller: emailController,
            keyboardType:
            TextInputType.emailAddress,
            validator: _validateEmail,
            autocorrect: false,
            decoration:
            _inputDecoration(
              context,
              label: 'Email',
              hint: 'Enter your email',
              icon:
              Icons.email_outlined,
            ),
          ),

          const SizedBox(height: 13),

          TextFormField(
            controller:
            locationController,
            validator:
            _validateLocation,
            decoration:
            _inputDecoration(
              context,
              label: 'Location',
              hint:
              'Enter your city or location',
              icon: Icons
                  .location_on_outlined,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECURITY
  // ============================================================

  Widget _buildSecurityCard(
      BuildContext context,
      ) {
    return _buildCard(
      context,
      child: Column(
        children: [
          TextFormField(
            controller:
            passwordController,
            obscureText:
            hidePassword,
            validator:
            _validatePassword,
            decoration:
            _inputDecoration(
              context,
              label: 'Password',
              hint:
              'Enter at least 8 characters',
              icon:
              Icons.lock_outline_rounded,
              suffixIcon:
              IconButton(
                onPressed: () {
                  setState(() {
                    hidePassword =
                    !hidePassword;
                  });
                },
                icon: Icon(
                  hidePassword
                      ? Icons
                      .visibility_outlined
                      : Icons
                      .visibility_off_outlined,
                ),
              ),
            ),
          ),

          const SizedBox(height: 13),

          TextFormField(
            controller:
            confirmPasswordController,
            obscureText:
            hideConfirmPassword,
            validator:
            _validateConfirmPassword,
            decoration:
            _inputDecoration(
              context,
              label: 'Confirm Password',
              hint:
              'Re-enter your password',
              icon:
              Icons.lock_reset_rounded,
              suffixIcon:
              IconButton(
                onPressed: () {
                  setState(() {
                    hideConfirmPassword =
                    !hideConfirmPassword;
                  });
                },
                icon: Icon(
                  hideConfirmPassword
                      ? Icons
                      .visibility_outlined
                      : Icons
                      .visibility_off_outlined,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          _buildPasswordHint(
            context,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PASSWORD HINT
  // ============================================================

  Widget _buildPasswordHint(
      BuildContext context,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 17,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            'Use at least 8 characters and avoid sharing your password with anyone.',
            style: TextStyle(
              fontSize: 10.5,
              height: 1.4,
              color: colorScheme
                  .onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LOCATION INFO
  // ============================================================

  Widget _buildLocationInfo(
      BuildContext context,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme
            .primaryContainer
            .withValues(alpha: 0.42),
        borderRadius:
        BorderRadius.circular(17),
        border: Border.all(
          color: colorScheme.primary
              .withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: colorScheme
                .onPrimaryContainer,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'For now, enter your location manually. '
                  'GPS location can be added later.',
              style: TextStyle(
                fontSize: 10.5,
                height: 1.5,
                color: colorScheme
                    .onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TERMS
  // ============================================================

  Widget _buildTermsCard(
      BuildContext context,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius:
        BorderRadius.circular(17),
        border: Border.all(
          color: agreeTerms
              ? colorScheme.primary
              .withValues(alpha: 0.35)
              : colorScheme
              .outlineVariant
              .withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Checkbox.adaptive(
            value: agreeTerms,
            onChanged: (value) {
              setState(() {
                agreeTerms =
                    value ?? false;
              });
            },
          ),

          Expanded(
            child: Padding(
              padding:
              const EdgeInsets.only(
                top: 10,
                right: 5,
              ),
              child: Text(
                'I agree to the ChainVault terms and conditions and understand the risks of cryptocurrency transactions.',
                style: TextStyle(
                  fontSize: 10.5,
                  height: 1.45,
                  color: colorScheme
                      .onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CREATE BUTTON
  // ============================================================

  Widget _buildCreateButton(
      BuildContext context,
      ) {
    return SizedBox(
      height: 55,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: isCreatingAccount
            ? null
            : createAccount,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(17),
          ),
        ),
        icon: isCreatingAccount
            ? const SizedBox(
          width: 20,
          height: 20,
          child:
          CircularProgressIndicator(
            strokeWidth: 2.3,
            color: Colors.white,
          ),
        )
            : const Icon(
          Icons.person_add_rounded,
        ),
        label: Text(
          isCreatingAccount
              ? 'Creating Account...'
              : 'Create Account',
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Widget _buildLoginSection(
      BuildContext context,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account?',
          style: TextStyle(
            fontSize: 11.5,
            color: colorScheme
                .onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: isCreatingAccount
              ? null
              : () {
            Navigator.pop(context);
          },
          child: const Text(
            'Login',
            style: TextStyle(
              fontWeight:
              FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // COMMON CARD
  // ============================================================

  Widget _buildCard(
      BuildContext context, {
        required Widget child,
      }) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(15),
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
      child: child,
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration(
      BuildContext context, {
        required String label,
        required String hint,
        required IconData icon,
        Widget? suffixIcon,
      }) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor:
      colorScheme.surfaceContainerLow,
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
      errorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(15),
        borderSide: BorderSide(
          color: colorScheme.error,
        ),
      ),
      focusedErrorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(15),
        borderSide: BorderSide(
          color: colorScheme.error,
          width: 1.4,
        ),
      ),
    );
  }
}