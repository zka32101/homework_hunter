import 'package:shared_preferences/shared_preferences.dart';

/// Firestore 未接続のため、現状は SharedPreferences にローカル保存する。
/// Phase 3 で Firestore の user_progress コレクションに差し替える。
class ProgressStore {
  static const _clearedKey = 'cleared_stage_ids';
  static const _streakKey = 'streak_days';
  static const _lastLoginKey = 'last_login_epoch_days';

  Future<Set<int>> loadClearedStageIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_clearedKey) ?? const [];
    return list.map(int.parse).toSet();
  }

  Future<void> markCleared(int stageId) async {
    final prefs = await SharedPreferences.getInstance();
    final cleared = await loadClearedStageIds();
    cleared.add(stageId);
    await prefs.setStringList(_clearedKey, cleared.map((e) => e.toString()).toList());
  }

  Future<int> loadStreakDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  Future<void> touchLoginStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toUtc();
    final todayEpochDays = today.millisecondsSinceEpoch ~/ (1000 * 60 * 60 * 24);
    final lastEpochDays = prefs.getInt(_lastLoginKey);
    var streak = prefs.getInt(_streakKey) ?? 0;

    if (lastEpochDays == null) {
      streak = 1;
    } else if (todayEpochDays == lastEpochDays) {
      // 同日ログインは変化なし
    } else if (todayEpochDays == lastEpochDays + 1) {
      streak += 1;
    } else {
      streak = 1;
    }

    await prefs.setInt(_lastLoginKey, todayEpochDays);
    await prefs.setInt(_streakKey, streak);
  }
}
