import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';
import 'api_service.dart';
import 'user_service.dart';
import 'wallet_service.dart';

class AuthService {
  static UserProfile? get currentUser =>
      UserService.currentUser;

  static bool get isLoggedIn =>
      UserService.currentUser != null;

  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      return false;
    }

    if (password.length < 8) {
      return false;
    }

    try {
      final response = await ApiService.post(
        '/auth/login',
        {
          'email': email.trim(),
          'password': password,
        },
      );

      if (response['success'] != true) {
        return false;
      }

      final token = response['token'];
      final userData = response['user'];

      if (token == null || userData == null) {
        return false;
      }

      final prefs =
      await SharedPreferences.getInstance();

      await prefs.setString(
        'auth_token',
        token.toString(),
      );

      // Clear the previous user's in-memory wallet
      // before starting the new user's session.
      WalletService.resetSession();

      final user = UserProfile(
        userId: userData['userId'] ?? '',
        fullName: userData['fullName'] ?? '',
        email: userData['email'] ?? '',
        location:
        userData['location'] ?? 'India',
        phone: userData['phone'] ?? '',
        walletAddress:
        userData['walletAddress'] ?? '',
      );

      await UserService.initializeUser(
        user,
        loadSavedProfile: true,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> signup({
    required String fullName,
    required String email,
    required String password,
    String location = 'India',
  }) async {
    if (fullName.trim().isEmpty ||
        email.trim().isEmpty ||
        password.isEmpty) {
      return false;
    }

    if (password.length < 8) {
      return false;
    }

    try {
      final response = await ApiService.post(
        '/auth/register',
        {
          'fullName': fullName.trim(),
          'email': email.trim(),
          'password': password,
          'location': location.trim().isEmpty
              ? 'India'
              : location.trim(),
          'phone': '',
        },
      );

      if (response['success'] != true) {
        return false;
      }

      final token = response['token'];
      final userData = response['user'];

      if (token == null || userData == null) {
        return false;
      }

      final prefs =
      await SharedPreferences.getInstance();

      await prefs.setString(
        'auth_token',
        token.toString(),
      );

      // Clear any previous user's in-memory wallet
      // before starting the newly registered user's session.
      WalletService.resetSession();

      final user = UserProfile(
        userId: userData['userId'] ?? '',
        fullName: userData['fullName'] ?? '',
        email: userData['email'] ?? '',
        location:
        userData['location'] ?? 'India',
        phone: userData['phone'] ?? '',
        walletAddress:
        userData['walletAddress'] ?? '',
      );

      await UserService.initializeUser(
        user,
        loadSavedProfile: false,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> logout() async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.remove('auth_token');

    // Clear the wallet data belonging to the
    // currently logged-in user from memory.
    WalletService.resetSession();

    await UserService.clearUser();
  }

  static Future<bool> resetPassword({
    required String email,
  }) async {
    if (email.trim().isEmpty) {
      return false;
    }

    return false;
  }
}