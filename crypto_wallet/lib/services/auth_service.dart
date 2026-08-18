import '../models/user_profile.dart';
import 'user_service.dart';

class AuthService {
  static UserProfile? get currentUser =>
      UserService.currentUser;

  static bool get isLoggedIn =>
      UserService.currentUser != null;

  /// Login user.
  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      return false;
    }

    final user = UserProfile(
      userId: 'CV-${email.hashCode.abs()}',
      fullName: 'ChainVault User',
      email: email.trim(),
      location: 'India',
      phone: '',
      walletAddress:
      '0x71C7656EC7ab88b098defB751B7401B5f6d8976F',
    );

    UserService.initializeUser(user);

    return true;
  }

  /// Create a new user account.
  static Future<bool> signup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    if (fullName.trim().isEmpty ||
        email.trim().isEmpty ||
        password.isEmpty) {
      return false;
    }

    if (password.length < 8) {
      return false;
    }

    final user = UserProfile(
      userId:
      'CV-${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName.trim(),
      email: email.trim(),
      location: 'India',
      phone: '',
      walletAddress:
      '0x71C7656EC7ab88b098defB751B7401B5f6d8976F',
    );

    UserService.initializeUser(user);

    return true;
  }

  /// Logout current user.
  static Future<void> logout() async {
    await UserService.clearUser();
  }

  /// Password reset.
  static Future<bool> resetPassword({
    required String email,
  }) async {
    if (email.trim().isEmpty) {
      return false;
    }

    // Firebase password reset will be added later.

    return true;
  }
}