import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/analytics_service.dart';
import '../services/progress_store.dart';
import '../services/stage_repository.dart';

final analyticsServiceProvider = Provider((ref) => AnalyticsService());
final stageRepositoryProvider = Provider((ref) => StageRepository());
final progressStoreProvider = Provider((ref) => ProgressStore());

final clearedStageIdsProvider =
    StateNotifierProvider<ClearedStagesNotifier, Set<int>>((ref) {
  return ClearedStagesNotifier(ref.watch(progressStoreProvider));
});

class ClearedStagesNotifier extends StateNotifier<Set<int>> {
  ClearedStagesNotifier(this._store) : super({}) {
    _load();
  }

  final ProgressStore _store;

  Future<void> _load() async {
    state = await _store.loadClearedStageIds();
  }

  Future<void> markCleared(int stageId) async {
    await _store.markCleared(stageId);
    state = {...state, stageId};
  }
}

final streakDaysProvider = FutureProvider<int>((ref) async {
  final store = ref.watch(progressStoreProvider);
  await store.touchLoginStreak();
  return store.loadStreakDays();
});
