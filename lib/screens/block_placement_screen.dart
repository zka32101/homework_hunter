import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/stage.dart';
import '../providers/app_providers.dart';
import '../utils/monster_visuals.dart';
import 'boss_battle_screen.dart';

class BlockPlacementScreen extends ConsumerStatefulWidget {
  const BlockPlacementScreen({super.key, required this.stageId, required this.difficulty});

  final int stageId;
  final Difficulty difficulty;

  @override
  ConsumerState<BlockPlacementScreen> createState() => _BlockPlacementScreenState();
}

class _BlockPlacementScreenState extends ConsumerState<BlockPlacementScreen> {
  final Set<String> _placed = {};

  String _key(int row, int col) => '$row,$col';

  @override
  Widget build(BuildContext context) {
    final stage = ref
        .read(stageRepositoryProvider)
        .stageByDifficulty(widget.stageId, widget.difficulty);
    final color = subjectColor(stage.monsterType);

    final nextTarget = stage.blocksRequired.firstWhere(
      (b) => !_placed.contains(_key(b.row, b.col)),
      orElse: () => stage.blocksRequired.first,
    );
    final allPlaced = _placed.length >= stage.blocksRequired.length;

    return Scaffold(
      appBar: AppBar(title: const Text('🧩 ブロックを置こう')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              AnimatedOpacity(
                opacity: allPlaced ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '次はここに置こう →',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: stage.gridSize,
                      ),
                      itemCount: stage.gridSize * stage.gridSize,
                      itemBuilder: (context, index) {
                        final row = index ~/ stage.gridSize;
                        final col = index % stage.gridSize;
                        final key = _key(row, col);
                        final required = stage.blocksRequired
                            .any((b) => b.row == row && b.col == col);
                        final isPlaced = _placed.contains(key);
                        final isNextHint = !allPlaced && nextTarget.row == row && nextTarget.col == col;

                        return GestureDetector(
                          onTap: !required || isPlaced
                              ? null
                              : () => setState(() => _placed.add(key)),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutBack,
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isPlaced
                                  ? color
                                  : (isNextHint ? Colors.amber.shade100 : const Color(0xFFF3EEE6)),
                              border: isNextHint
                                  ? Border.all(color: Colors.amber, width: 3)
                                  : Border.all(color: Colors.grey.shade300, width: 2),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: isPlaced
                                  ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 6, offset: const Offset(0, 3))]
                                  : null,
                            ),
                            child: isPlaced
                                ? const Icon(Icons.check_circle, color: Colors.white, size: 28)
                                : (isNextHint
                                    ? const Icon(Icons.arrow_downward, color: Colors.orange, size: 28)
                                    : null),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: allPlaced ? color : null, foregroundColor: Colors.white),
                  onPressed: allPlaced
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => BossBattleScreen(stage: stage)),
                          );
                        }
                      : null,
                  child: const Text('ボス戦へ 👹'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
