class UserProfile {
  final String userId;
  final String fullName;
  final String email;
  final String location;
  final String phone;
  final String walletAddress;

  const UserProfile({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.location,
    required this.phone,
    required this.walletAddress,
  });

  UserProfile copyWith({
    String? userId,
    String? fullName,
    String? email,
    String? location,
    String? phone,
    String? walletAddress,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      walletAddress: walletAddress ?? this.walletAddress,
    );
  }
}