import '../models/user_profile.dart';
import '../models/user_settings.dart';
import 'api_service.dart';

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
      try {
        final response = await ApiService.get('/user/profile');

        if (response['success'] == true &&
            response['user'] != null) {
          final userData = response['user'];

          _currentUser = UserProfile(
            userId: userData['userId'] ?? user.userId,
            fullName: userData['fullName'] ?? user.fullName,
            email: userData['email'] ?? user.email,
            location: userData['location'] ?? user.location,
            phone: userData['phone'] ?? user.phone,
            walletAddress:
            userData['walletAddress'] ?? user.walletAddress,
          );
        }
      } catch (e) {
        _currentUser = user;
      }
    }
  }

  static Future<UserProfile?> getProfile() async {
    try {
      final response = await ApiService.get('/user/profile');

      if (response['success'] == true &&
          response['user'] != null) {
        final userData = response['user'];

        _currentUser = UserProfile(
          userId: userData['userId'] ?? '',
          fullName: userData['fullName'] ?? '',
          email: userData['email'] ?? '',
          location: userData['location'] ?? 'India',
          phone: userData['phone'] ?? '',
          walletAddress: userData['walletAddress'] ?? '',
        );

        return _currentUser;
      }
    } catch (e) {
      return _currentUser;
    }

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

    final newFullName = fullName ?? oldUser.fullName;
    final newLocation = location ?? oldUser.location;
    final newPhone = phone ?? oldUser.phone;

    try {
      final response = await ApiService.put(
        '/user/profile',
        {
          'fullName': newFullName,
          'location': newLocation,
          'phone': newPhone,
        },
      );

      if (response['success'] == true &&
          response['user'] != null) {
        final userData = response['user'];

        _currentUser = UserProfile(
          userId: userData['userId'] ?? oldUser.userId,
          fullName: userData['fullName'] ?? newFullName,
          email: userData['email'] ?? oldUser.email,
          location: userData['location'] ?? newLocation,
          phone: userData['phone'] ?? newPhone,
          walletAddress:
          userData['walletAddress'] ?? oldUser.walletAddress,
        );
      }
    } catch (e) {
      _currentUser = oldUser.copyWith(
        fullName: fullName,
        email: email,
        location: location,
        phone: phone,
        walletAddress: walletAddress,
      );

      rethrow;
    }
  }

  static Future<void> updateWalletSettings({
    required String walletName,
    required String defaultNetwork,
    required String displayCurrency,
  }) async {
    _settings.walletName = walletName;
    _settings.defaultNetwork = defaultNetwork;
    _settings.displayCurrency = displayCurrency;
  }

  static Future<void> updateSettings(
      UserSettings newSettings,
      ) async {
    _settings = newSettings;
  }

  static Future<void> clearUser() async {
    _currentUser = null;
    _settings = UserSettings();
  }
}