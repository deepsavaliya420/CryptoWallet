import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'services/biometric_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ChainVaultApp());
}

class ChainVaultApp extends StatelessWidget {
  const ChainVaultApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'ChainVault',

      theme: AppTheme.lightTheme,

      darkTheme: AppTheme.lightTheme,

      themeMode: ThemeMode.light,

      home: kIsWeb
          ? const LoginScreen()
          : const BiometricGate(),
    );
  }
}

class BiometricGate extends StatefulWidget {
  const BiometricGate({
    super.key,
  });

  @override
  State<BiometricGate> createState() => _BiometricGateState();
}

class _BiometricGateState extends State<BiometricGate> {
  bool _isChecking = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();

    _authenticate();
  }

  Future<void> _authenticate() async {
    final bool available =
    await BiometricService.isAvailable();

    if (!available) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isChecking = false;
        _isAuthenticated = false;
      });

      return;
    }

    final bool authenticated =
    await BiometricService.authenticate();

    if (!mounted) {
      return;
    }

    setState(() {
      _isChecking = false;
      _isAuthenticated = authenticated;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isAuthenticated) {
      return const LoginScreen();
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.fingerprint,
                size: 90,
              ),

              const SizedBox(height: 24),

              const Text(
                'Authentication Required',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Please authenticate with your fingerprint to access ChainVault.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: _authenticate,
                icon: const Icon(
                  Icons.fingerprint,
                ),
                label: const Text(
                  'Authenticate',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}