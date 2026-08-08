import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../flame/boss_battle_game.dart';
import '../models/stage.dart';
import 'clear_screen.dart';

class BossBattleScreen extends StatefulWidget {
  const BossBattleScreen({super.key, required this.stage});

  final Stage stage;

  @override
  State<BossBattleScreen> createState() => _BossBattleScreenState();
}

class _BossBattleScreenState extends State<BossBattleScreen> {
  static const _maxPlayerHp = 3;

  late final BossBattleGame _game;
  late int _hp;
  int _playerHp = _maxPlayerHp;
  int _secondsLeft = 30;
  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch()..start();

  @override
  void initState() {
    super.initState();
    _hp = widget.stage.bossHp;
    _game = BossBattleGame(
      monsterType: widget.stage.monsterType,
      maxHp: widget.stage.bossHp,
      maxPlayerHp: _maxPlayerHp,
      onHpChanged: (hp) {
        if (!mounted) return;
        setState(() => _hp = hp);
      },
      onPlayerHpChanged: (hp) {
        if (!mounted) return;
        setState(() => _playerHp = hp);
      },
      onDefeated: _onDefeated,
      onPlayerDefeated: _onPlayerDefeated,
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        _onTimeUp();
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    // 破棄後に発火する可能性のある Future.delayed（テレグラフ攻撃等）を無効化する
    _game.endBattle();
    super.dispose();
  }

  void _onDefeated() {
    if (!mounted) return;
    _timer?.cancel();
    _stopwatch.stop();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ClearScreen(
          stage: widget.stage,
          timeSeconds: _stopwatch.elapsed.inSeconds,
        ),
      ),
    );
  }

  void _onTimeUp() {
    // タイムアップ後もボスの反撃タイマーが動き続けて二重ダイアログを招かないよう先に止める
    _game.endBattle();
    _showRetryDialog('時間切れ！');
  }

  void _onPlayerDefeated() {
    if (!mounted) return;
    _timer?.cancel();
    _showRetryDialog('やられた！');
  }

  void _showRetryDialog(String title) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: const Text('もう一度挑戦しよう'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context)
              ..pop()
              ..pop(),
            child: const Text('もどる'),
          ),
        ],
      ),
    );
  }

  Color _hpBarColor(double ratio) {
    if (ratio > 0.5) return Colors.lightGreen;
    if (ratio > 0.2) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final ratio = _hp / widget.stage.bossHp;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF6FF),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.timer, color: Colors.deepOrange),
                  const SizedBox(width: 4),
                  Text('$_secondsLeft秒', style: const TextStyle(fontSize: 18)),
                  const Spacer(),
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: 16,
                        color: Colors.grey.shade300,
                        alignment: Alignment.centerLeft,
                        child: AnimatedFractionallySizedBox(
                          duration: const Duration(milliseconds: 200),
                          widthFactor: ratio.clamp(0, 1),
                          alignment: Alignment.centerLeft,
                          child: Container(color: _hpBarColor(ratio)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('$_hp HP', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_maxPlayerHp, (i) {
                final filled = i < _playerHp;
                return Icon(
                  filled ? Icons.favorite : Icons.favorite_border,
                  color: Colors.pinkAccent,
                );
              }),
            ),
            Expanded(child: GameWidget(game: _game)),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('タップしてダメージを与えよう！ボスの反撃に気をつけて', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
