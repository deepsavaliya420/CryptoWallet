import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> isAvailable() async {
    try {
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();

      debugPrint('canCheckBiometrics: $canCheckBiometrics');
      debugPrint('isDeviceSupported: $isDeviceSupported');

      if (!canCheckBiometrics && !isDeviceSupported) {
        return false;
      }

      final List<BiometricType> biometrics =
      await _auth.getAvailableBiometrics();

      debugPrint('Available biometrics: $biometrics');

      return biometrics.isNotEmpty;
    } catch (e) {
      debugPrint('Biometric availability error: $e');
      return false;
    }
  }

  static Future<bool> authenticate() async {
    try {
      final bool available = await isAvailable();

      if (!available) {
        debugPrint('Biometric authentication is not available.');
        return false;
      }

      debugPrint('Starting biometric authentication...');

      final bool authenticated = await _auth.authenticate(
        localizedReason:
        'Please authenticate with your fingerprint to access ChainVault',

      );

      debugPrint('Biometric authentication result: $authenticated');

      return authenticated;
    } catch (e) {
      debugPrint('Biometric authentication error: $e');
      return false;
    }
  }

  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Error getting biometrics: $e');
      return [];
    }
  }
}