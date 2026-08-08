import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../utils/monster_visuals.dart';
import 'stage_selection_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clearedStages = ref.watch(clearedStageIdsProvider);
    final streakAsync = ref.watch(streakDaysProvider);
    final stages = ref.watch(stageRepositoryProvider).allStageSummaries();

    return Scaffold(
      appBar: AppBar(title: const Text('🏹 宿題ハンター')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFB74D), Color(0xFFFF7A3D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF7A3D).withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 34)),
                  const SizedBox(width: 12),
                  streakAsync.when(
                    data: (streak) => Text(
                      '連続$streak日プレイ中！',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    loading: () => const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                    error: (_, _) => const Text('ストリーク取得エラー', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: const Color(0xFFFFF1DA),
              child: const ListTile(
                leading: Text('📋', style: TextStyle(fontSize: 28)),
                title: Text('今日のミッション', style: TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text('漢字ゴブリンを倒そう！', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('⚔️ ステージ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            ...stages.map((stage) {
              final cleared = clearedStages.contains(stage.id);
              final color = subjectColor(stage.monsterType);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  elevation: 3,
                  shadowColor: color.withValues(alpha: 0.3),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => StageSelectionScreen(stageId: stage.id)),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: color.withValues(alpha: 0.25), width: 2),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset(monsterAssetPath(stage.monsterType), fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ステージ${stage.id}: ${stage.title}',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        subjectName(stage.monsterType),
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    if (cleared)
                                      const Text('クリア済み ⭐', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))
                                    else
                                      Text('未クリア', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                            child: const Icon(Icons.chevron_right, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
