class AppUser {
  const AppUser({
    required this.uid,
    required this.progress,
    required this.purchased,
    required this.streakDays,
    required this.lastLogin,
  });

  final String uid;
  final int progress;
  final bool purchased;
  final int streakDays;
  final DateTime lastLogin;

  AppUser copyWith({int? progress, bool? purchased, int? streakDays, DateTime? lastLogin}) {
    return AppUser(
      uid: uid,
      progress: progress ?? this.progress,
      purchased: purchased ?? this.purchased,
      streakDays: streakDays ?? this.streakDays,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
