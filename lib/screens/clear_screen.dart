import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/stage.dart';
import '../providers/app_providers.dart';
import '../utils/monster_visuals.dart';

class ClearScreen extends ConsumerStatefulWidget {
  const ClearScreen({super.key, required this.stage, required this.timeSeconds});

  final Stage stage;
  final int timeSeconds;

  @override
  ConsumerState<ClearScreen> createState() => _ClearScreenState();
}

class _ClearScreenState extends ConsumerState<ClearScreen> {
  final List<bool> _starVisible = [false, false, false];
  bool _badgeVisible = false;

  int get _stars {
    if (widget.timeSeconds <= 15) return 3;
    if (widget.timeSeconds <= 25) return 2;
    return 1;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onCleared());

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _badgeVisible = true);
    });
    for (var i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: 400 + i * 200), () {
        if (mounted) setState(() => _starVisible[i] = true);
      });
    }
  }

  Future<void> _onCleared() async {
    final analytics = ref.read(analyticsServiceProvider);
    final isFirstEverClear = ref.read(clearedStageIdsProvider).isEmpty;
    await ref.read(clearedStageIdsProvider.notifier).markCleared(widget.stage.id);

    await analytics.logEvent('boss_defeated', parameters: {
      'difficulty': widget.stage.difficulty.name,
      'time': widget.timeSeconds,
      'monster_type': widget.stage.monsterType.name,
    });
    await analytics.logEvent('stage_clear', parameters: {
      'stage_id': widget.stage.id,
      'stars': _stars,
    });

    // Aha Moment = プレイヤーにとって最初のステージクリア（どのステージから始めても計測する）
    if (isFirstEverClear) {
      await analytics.logEvent('aha_moment_reached', parameters: {'stage_id': widget.stage.id});
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = subjectColor(widget.stage.monsterType);
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: _badgeVisible ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.elasticOut,
                child: const Text('🎉', style: TextStyle(fontSize: 72)),
              ),
              const SizedBox(height: 8),
              const Text('ステージクリア！', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final filled = i < _stars;
                  return AnimatedScale(
                    scale: _starVisible[i] ? 1 : 0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.elasticOut,
                    child: Icon(
                      filled ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 48,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Card(
                color: color.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('✨ 宿題プリントが片付いた！', style: TextStyle(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      Text(widget.stage.trivia, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  child: const Text('次へ 👉'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('共有機能は準備中です')),
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('共有する'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
