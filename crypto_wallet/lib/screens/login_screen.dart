import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await AuthService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      } else {
        _showMessage(
          'Please enter a valid email and password.',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Login failed. Please try again.',
        isError: true,
      );
    }
  }

  void _showMessage(
      String message, {
        bool isError = false,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignupScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 32,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 450,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet,
                          size: 38,
                          color:
                          colorScheme.onPrimary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Title
                    Text(
                      'Welcome Back',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Sign in to access your ChainVault wallet',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(
                        color: theme
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Email
                    TextFormField(
                      controller: emailController,
                      keyboardType:
                      TextInputType.emailAddress,
                      textInputAction:
                      TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText:
                        'Enter your email address',
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter your email';
                        }

                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // Password
                    TextFormField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      textInputAction:
                      TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText:
                        'Enter your password',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword =
                              !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons
                                .visibility_off_outlined,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'Please enter your password';
                        }

                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // Forgot password
                    Align(
                      alignment:
                      Alignment.centerRight,
                      child: TextButton(
                        onPressed: () async {
                          final email =
                          emailController.text.trim();

                          if (email.isEmpty ||
                              !email.contains('@')) {
                            _showMessage(
                              'Enter your email first.',
                              isError: true,
                            );
                            return;
                          }

                          final success =
                          await AuthService
                              .resetPassword(
                            email: email,
                          );

                          if (!mounted) return;

                          if (success) {
                            _showMessage(
                              'Password reset request sent.',
                            );
                          }
                        },
                        child: const Text(
                          'Forgot Password?',
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Login button
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed:
                        _isLoading ? null : _login,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(),
                        ),
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          child: Text(
                            'OR',
                            style: theme
                                .textTheme
                                .bodySmall,
                          ),
                        ),
                        const Expanded(
                          child: Divider(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Signup
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: theme
                              .textTheme
                              .bodyMedium,
                        ),
                        TextButton(
                          onPressed: _openSignup,
                          child: const Text(
                            'Create Account',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}