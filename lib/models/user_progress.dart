class UserProgress {
  const UserProgress({
    required this.userId,
    required this.stageId,
    required this.cleared,
    required this.stars,
    required this.timeSeconds,
  });

  final String userId;
  final int stageId;
  final bool cleared;
  final int stars;
  final int timeSeconds;

  String get docId => '${userId}_$stageId';

  UserProgress copyWith({bool? cleared, int? stars, int? timeSeconds}) {
    return UserProgress(
      userId: userId,
      stageId: stageId,
      cleared: cleared ?? this.cleared,
      stars: stars ?? this.stars,
      timeSeconds: timeSeconds ?? this.timeSeconds,
    );
  }
}
