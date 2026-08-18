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
}