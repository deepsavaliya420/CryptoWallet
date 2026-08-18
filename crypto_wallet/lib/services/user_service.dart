import '../models/user_profile.dart';
import '../models/user_settings.dart';

class UserService {
  static UserProfile? _currentUser;

  static UserSettings _settings = UserSettings();

  /// Current logged-in user's profile.
  static UserProfile? get currentUser => _currentUser;

  /// Current user settings.
  static UserSettings get settings => _settings;

  /// Initialize the user after login/signup.
  static void initializeUser(UserProfile user) {
    _currentUser = user;
    _settings = UserSettings();
  }

  /// Get current user profile.
  static Future<UserProfile?> getProfile() async {
    return _currentUser;
  }

  /// Update profile information.
  static Future<void> updateProfile({
    String? fullName,
    String? email,
    String? location,
    String? phone,
    String? walletAddress,
  }) async {
    if (_currentUser == null) {
      return;
    }

    _currentUser = _currentUser!.copyWith(
      fullName: fullName,
      email: email,
      location: location,
      phone: phone,
      walletAddress: walletAddress,
    );
  }

  /// Update wallet settings.
  static Future<void> updateWalletSettings({
    required String walletName,
    required String defaultNetwork,
    required String displayCurrency,
  }) async {
    _settings.walletName = walletName;
    _settings.defaultNetwork = defaultNetwork;
    _settings.displayCurrency = displayCurrency;
  }

  /// Update all user settings.
  static Future<void> updateSettings(
      UserSettings newSettings,
      ) async {
    _settings = newSettings;
  }

  /// Clear user information during logout.
  static Future<void> clearUser() async {
    _currentUser = null;
    _settings = UserSettings();
  }
}