import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/stage.dart';
import '../providers/app_providers.dart';
import '../utils/monster_visuals.dart';
import 'block_placement_screen.dart';

class StageSelectionScreen extends ConsumerStatefulWidget {
  const StageSelectionScreen({super.key, required this.stageId});

  final int stageId;

  @override
  ConsumerState<StageSelectionScreen> createState() => _StageSelectionScreenState();
}

class _StageSelectionScreenState extends ConsumerState<StageSelectionScreen> {
  // ステージごとに独立させるため画面ローカルで保持する（グローバルProviderだと
  // 前のステージで選んだ難易度が次のステージ選択時に残ってしまう）
  Difficulty _selected = Difficulty.easy;

  String _label(Difficulty d) => switch (d) {
        Difficulty.easy => 'かんたん',
        Difficulty.normal => 'ふつう',
        Difficulty.hard => 'むずかしい',
      };

  String _emoji(Difficulty d) => switch (d) {
        Difficulty.easy => '🌱',
        Difficulty.normal => '🔥',
        Difficulty.hard => '💀',
      };

  @override
  Widget build(BuildContext context) {
    final stage = ref
        .read(stageRepositoryProvider)
        .stageByDifficulty(widget.stageId, Difficulty.easy);
    final color = subjectColor(stage.monsterType);

    return Scaffold(
      appBar: AppBar(title: const Text('難易度を選ぼう')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                padding: const EdgeInsets.all(12),
                child: Image.asset(monsterAssetPath(stage.monsterType), fit: BoxFit.contain),
              ),
              const SizedBox(height: 16),
              Text(
                stage.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                subjectName(stage.monsterType),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: Difficulty.values.map(
                  (d) => ChoiceChip(
                    label: Text('${_emoji(d)} ${_label(d)}'),
                    selected: _selected == d,
                    onSelected: (_) => setState(() => _selected = d),
                    selectedColor: color,
                    labelStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _selected == d ? Colors.white : null,
                    ),
                  ),
                ).toList(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlockPlacementScreen(stageId: widget.stageId, difficulty: _selected),
                      ),
                    );
                  },
                  child: const Text('つよそう！スタート 🚀'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
