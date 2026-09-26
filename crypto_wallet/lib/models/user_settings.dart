class UserSettings {
  bool biometricLogin;
  bool twoFactorAuthentication;

  bool transactionReceived;
  bool transactionSent;
  bool transactionFailed;

  bool loginAlerts;
  bool securityAlerts;

  bool priceAlerts;
  bool marketUpdates;
  bool emailNotifications;

  String walletName;
  String defaultNetwork;
  String displayCurrency;

  UserSettings({
    this.biometricLogin = false,
    this.twoFactorAuthentication = false,
    this.transactionReceived = true,
    this.transactionSent = true,
    this.transactionFailed = true,
    this.loginAlerts = true,
    this.securityAlerts = true,
    this.priceAlerts = false,
    this.marketUpdates = false,
    this.emailNotifications = true,
    this.walletName = 'My Main Wallet',
    this.defaultNetwork = 'Ethereum',
    this.displayCurrency = 'USD',
  });

  UserSettings copyWith({
    bool? biometricLogin,
    bool? twoFactorAuthentication,
    bool? transactionReceived,
    bool? transactionSent,
    bool? transactionFailed,
    bool? loginAlerts,
    bool? securityAlerts,
    bool? priceAlerts,
    bool? marketUpdates,
    bool? emailNotifications,
    String? walletName,
    String? defaultNetwork,
    String? displayCurrency,
  }) {
    return UserSettings(
      biometricLogin: biometricLogin ?? this.biometricLogin,
      twoFactorAuthentication:
      twoFactorAuthentication ?? this.twoFactorAuthentication,
      transactionReceived:
      transactionReceived ?? this.transactionReceived,
      transactionSent:
      transactionSent ?? this.transactionSent,
      transactionFailed:
      transactionFailed ?? this.transactionFailed,
      loginAlerts: loginAlerts ?? this.loginAlerts,
      securityAlerts: securityAlerts ?? this.securityAlerts,
      priceAlerts: priceAlerts ?? this.priceAlerts,
      marketUpdates: marketUpdates ?? this.marketUpdates,
      emailNotifications:
      emailNotifications ?? this.emailNotifications,
      walletName: walletName ?? this.walletName,
      defaultNetwork: defaultNetwork ?? this.defaultNetwork,
      displayCurrency: displayCurrency ?? this.displayCurrency,
    );
  }
}