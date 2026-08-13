import 'package:flutter/material.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final locationController = TextEditingController();

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool agreeTerms = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    locationController.dispose();
    super.dispose();
  }

  void createAccount() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please accept the terms and conditions.',
          ),
        ),
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
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Account',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor:
                      colorScheme.primaryContainer,
                      child: Icon(
                        Icons.person_add_alt_1,
                        size: 40,
                        color:
                        colorScheme.onPrimaryContainer,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Join ChainVault',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Create your secure crypto wallet account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:
                        colorScheme.onSurfaceVariant,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // NAME
                    TextFormField(
                      controller: nameController,
                      textCapitalization:
                      TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        hintText: 'Enter your full name',
                        prefixIcon:
                        Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter your full name';
                        }

                        if (value.trim().length < 3) {
                          return 'Name must contain at least 3 characters';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // EMAIL
                    TextFormField(
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
                      validator: (value) {
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
                      },
                    ),

                    const SizedBox(height: 16),

                    // PASSWORD
                    TextFormField(
                      controller: passwordController,
                      obscureText: hidePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText:
                        'Enter at least 8 characters',
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
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'Please enter a password';
                        }

                        if (value.length < 8) {
                          return 'Password must contain at least 8 characters';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // CONFIRM PASSWORD
                    TextFormField(
                      controller:
                      confirmPasswordController,
                      obscureText: hideConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText:
                        'Re-enter your password',
                        prefixIcon:
                        const Icon(Icons.lock_reset),
                        border:
                        const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              hideConfirmPassword =
                              !hideConfirmPassword;
                            });
                          },
                          icon: Icon(
                            hideConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons
                                .visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'Please confirm your password';
                        }

                        if (value !=
                            passwordController.text) {
                          return 'Passwords do not match';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // LOCATION
                    TextFormField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        hintText:
                        'Enter your city or location',
                        prefixIcon: Icon(
                          Icons.location_on_outlined,
                        ),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter your location';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // LOCATION INFO
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme
                            .primaryContainer
                            .withValues(alpha: 0.4),
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'For now, enter your location manually. '
                                  'GPS location will be added later.',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // TERMS
                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: agreeTerms,
                          onChanged: (value) {
                            setState(() {
                              agreeTerms =
                                  value ?? false;
                            });
                          },
                        ),
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: 12,
                            ),
                            child: Text(
                              'I agree to the ChainVault '
                                  'terms and conditions and '
                                  'understand the risks of '
                                  'cryptocurrency transactions.',
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // CREATE ACCOUNT
                    SizedBox(
                      height: 54,
                      child: FilledButton.icon(
                        onPressed: createAccount,
                        icon: const Icon(
                          Icons.person_add,
                        ),
                        label: const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // LOGIN
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Login'),
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