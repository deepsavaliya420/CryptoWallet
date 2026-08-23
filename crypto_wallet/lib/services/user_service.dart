import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';
import '../models/user_settings.dart';

class UserService {
  static UserProfile? _currentUser;

  static UserSettings _settings = UserSettings();

  static UserProfile? get currentUser => _currentUser;

  static UserSettings get settings => _settings;

  static Future<void> initializeUser(
      UserProfile user, {
        bool loadSavedProfile = true,
      }) async {
    _currentUser = user;

    if (loadSavedProfile) {
      final savedProfile = await _loadProfile(
        user.email,
      );

      if (savedProfile != null) {
        _currentUser = savedProfile;
      }
    }
  }

  static Future<UserProfile?> getProfile() async {
    return _currentUser;
  }

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

    final oldUser = _currentUser!;

    _currentUser = oldUser.copyWith(
      fullName: fullName,
      email: email,
      location: location,
      phone: phone,
      walletAddress: walletAddress,
    );

    await _saveProfile(_currentUser!);
  }

  static Future<void> updateWalletSettings({
    required String walletName,
    required String defaultNetwork,
    required String displayCurrency,
  }) async {
    _settings.walletName = walletName;
    _settings.defaultNetwork = defaultNetwork;
    _settings.displayCurrency = displayCurrency;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'wallet_name',
      walletName,
    );

    await prefs.setString(
      'default_network',
      defaultNetwork,
    );

    await prefs.setString(
      'display_currency',
      displayCurrency,
    );
  }

  static Future<void> updateSettings(
      UserSettings newSettings,
      ) async {
    _settings = newSettings;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'wallet_name',
      newSettings.walletName,
    );

    await prefs.setString(
      'default_network',
      newSettings.defaultNetwork,
    );

    await prefs.setString(
      'display_currency',
      newSettings.displayCurrency,
    );
  }

  static Future<void> clearUser() async {
    _currentUser = null;
    _settings = UserSettings();
  }

  static Future<void> _saveProfile(
      UserProfile user,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    final emailKey = _emailKey(user.email);

    await prefs.setString(
      '${emailKey}_userId',
      user.userId,
    );

    await prefs.setString(
      '${emailKey}_fullName',
      user.fullName,
    );

    await prefs.setString(
      '${emailKey}_email',
      user.email,
    );

    await prefs.setString(
      '${emailKey}_location',
      user.location,
    );

    await prefs.setString(
      '${emailKey}_phone',
      user.phone,
    );

    await prefs.setString(
      '${emailKey}_walletAddress',
      user.walletAddress,
    );
  }

  static Future<UserProfile?> _loadProfile(
      String email,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    final emailKey = _emailKey(email);

    final userId = prefs.getString(
      '${emailKey}_userId',
    );

    final fullName = prefs.getString(
      '${emailKey}_fullName',
    );

    final savedEmail = prefs.getString(
      '${emailKey}_email',
    );

    final location = prefs.getString(
      '${emailKey}_location',
    );

    final phone = prefs.getString(
      '${emailKey}_phone',
    );

    final walletAddress = prefs.getString(
      '${emailKey}_walletAddress',
    );

    if (userId == null ||
        fullName == null ||
        savedEmail == null ||
        location == null ||
        phone == null ||
        walletAddress == null) {
      return null;
    }

    return UserProfile(
      userId: userId,
      fullName: fullName,
      email: savedEmail,
      location: location,
      phone: phone,
      walletAddress: walletAddress,
    );
  }

  static String _emailKey(String email) {
    return 'profile_${email.trim().toLowerCase().replaceAll(
      RegExp(r'[^a-zA-Z0-9]'),
      '_',
    )}';
  }
}