import '../models/user_profile.dart';
import 'user_service.dart';

class AuthService {
  static UserProfile? get currentUser =>
      UserService.currentUser;

  static bool get isLoggedIn =>
      UserService.currentUser != null;

  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty ||
        password.isEmpty) {
      return false;
    }

    if (password.length < 8) {
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

    await UserService.initializeUser(
      user,
      loadSavedProfile: true,
    );

    return true;
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

    final user = UserProfile(
      userId:
      'CV-${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName.trim(),
      email: email.trim(),
      location: location.trim().isEmpty
          ? 'India'
          : location.trim(),
      phone: '',
      walletAddress:
      '0x71C7656EC7ab88b098defB751B7401B5f6d8976F',
    );

    await UserService.initializeUser(
      user,
      loadSavedProfile: false,
    );

    await UserService.updateProfile(
      fullName: user.fullName,
      email: user.email,
      location: user.location,
      phone: user.phone,
      walletAddress: user.walletAddress,
    );

    return true;
  }

  static Future<void> logout() async {
    await UserService.clearUser();
  }

  static Future<bool> resetPassword({
    required String email,
  }) async {
    if (email.trim().isEmpty) {
      return false;
    }

    return true;
  }
}