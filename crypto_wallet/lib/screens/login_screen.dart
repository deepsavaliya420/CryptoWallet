import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() {
    if (emailController.text.trim().isEmpty) {
      showMessage('Please enter your email.');
      return;
    }

    if (passwordController.text.isEmpty) {
      showMessage('Please enter your password.');
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
          (route) => false,
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 450,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.stretch,
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor:
                    colorScheme.primaryContainer,
                    child: Icon(
                      Icons.account_balance_wallet,
                      size: 42,
                      color:
                      colorScheme.onPrimaryContainer,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Login to your ChainVault wallet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                      colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 35),

                  TextField(
                    controller: emailController,
                    keyboardType:
                    TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon:
                      Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 18),

                  TextField(
                    controller: passwordController,
                    obscureText: hidePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon:
                      const Icon(Icons.lock_outline),
                      border:
                      const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            hidePassword =
                            !hidePassword;
                          });
                        },
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility_outlined
                              : Icons
                              .visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        showMessage(
                          'Password recovery coming soon',
                        );
                      },
                      child: const Text(
                        'Forgot Password?',
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: login,
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: colorScheme.outline,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        child: Text('OR'),
                      ),
                      Expanded(
                        child: Divider(
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  OutlinedButton.icon(
                    onPressed: () {
                      showMessage(
                        'Biometric login coming soon',
                      );
                    },
                    icon: const Icon(
                      Icons.fingerprint,
                    ),
                    label: const Text(
                      'Login with Biometrics',
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const SignupScreen(),
                            ),
                          );
                        },
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}