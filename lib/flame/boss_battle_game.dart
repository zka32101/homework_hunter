import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../models/stage.dart';
import '../utils/monster_visuals.dart';

class BossBattleGame extends FlameGame with TapCallbacks {
  BossBattleGame({
    required this.monsterType,
    required this.maxHp,
    required this.maxPlayerHp,
    required this.onHpChanged,
    required this.onPlayerHpChanged,
    required this.onDefeated,
    required this.onPlayerDefeated,
    this.tapDamage = 4,
    this.bossAttackDamage = 1,
    this.bossAttackInterval = const Duration(seconds: 4),
  })  : hp = maxHp,
        playerHp = maxPlayerHp;

  final MonsterType monsterType;
  final int maxHp;
  final int maxPlayerHp;
  int hp;
  int playerHp;
  final int tapDamage;
  final int bossAttackDamage;
  final Duration bossAttackInterval;
  final void Function(int hp) onHpChanged;
  final void Function(int hp) onPlayerHpChanged;
  final VoidCallback onDefeated;
  final VoidCallback onPlayerDefeated;

  final _rng = Random();
  _GradientBackground? _background;
  _BossSprite? _boss;
  bool _battleOver = false;

  @override
  Future<void> onLoad() async {
    final background = _GradientBackground()..size = size;
    _background = background;
    add(background);

    final image = await images.load(monsterFlameFileName(monsterType));
    final boss = _BossSprite(image)..position = size / 2;
    _boss = boss;
    add(boss);

    add(TimerComponent(
      period: bossAttackInterval.inMilliseconds / 1000,
      repeat: true,
      onTick: _telegraphAttack,
    ));
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _background?.size = size;
    _boss?.position = size / 2;
  }

  /// タイムアウトや画面破棄など、ゲーム外の理由で戦闘を終了させる。
  /// 以降 `_battleOver` を見ているタップ処理・ボス攻撃・その遅延コールバックは全て無視される。
  void endBattle() {
    if (_battleOver) return;
    _battleOver = true;
    pauseEngine();
  }

  void _telegraphAttack() {
    if (_battleOver) return;
    final warning = TextComponent(
      text: '!',
      anchor: Anchor.center,
      position: _boss!.position - Vector2(0, 130),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: Color(0xFFD32F2F),
        ),
      ),
    );
    add(warning);
    warning.add(
      SequenceEffect([
        ScaleEffect.by(Vector2.all(1.4), EffectController(duration: 0.5, alternate: true)),
        RemoveEffect(),
      ]),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      warning.removeFromParent();
      _dealBossDamage();
    });
  }

  void _dealBossDamage() {
    if (_battleOver) return;
    playerHp = (playerHp - bossAttackDamage).clamp(0, maxPlayerHp);
    onPlayerHpChanged(playerHp);

    _boss!.flashAngry();
    _boss!.add(
      SequenceEffect([
        MoveByEffect(Vector2(-10, 0), EffectController(duration: 0.05)),
        MoveByEffect(Vector2(20, 0), EffectController(duration: 0.08, alternate: true)),
        MoveByEffect(Vector2(-10, 0), EffectController(duration: 0.05)),
      ]),
    );

    if (playerHp <= 0) {
      _battleOver = true;
      pauseEngine();
      onPlayerDefeated();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_battleOver) return;
    hp = (hp - tapDamage).clamp(0, maxHp);
    onHpChanged(hp);

    _boss!.flashHit();
    _boss!.add(
      ScaleEffect.by(Vector2.all(0.88), EffectController(duration: 0.06, alternate: true)),
    );

    _spawnDamageNumber(event.localPosition);

    if (hp <= 0) {
      _battleOver = true;
      _boss!.add(
        RotateEffect.by(pi * 2, EffectController(duration: 0.5, curve: Curves.easeIn)),
      );
      _boss!.add(ScaleEffect.by(Vector2.all(0.01), EffectController(duration: 0.5, curve: Curves.easeIn)));
      // 撃破演出を見せてからエンジンを止める（即pauseEngineすると回転・縮小が止まってしまう）
      Future.delayed(const Duration(milliseconds: 500), pauseEngine);
      onDefeated();
    }
  }

  void _spawnDamageNumber(Vector2 at) {
    final jitter = Vector2((_rng.nextDouble() - 0.5) * 30, 0);
    final label = TextComponent(
      text: '-$tapDamage',
      anchor: Anchor.center,
      position: at + jitter,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFF7043),
          shadows: [Shadow(color: Colors.black26, blurRadius: 2, offset: Offset(1, 1))],
        ),
      ),
    );
    add(label);
    label.add(
      SequenceEffect([
        MoveByEffect(Vector2(0, -50), EffectController(duration: 0.6, curve: Curves.easeOut)),
        RemoveEffect(),
      ]),
    );
    label.add(OpacityEffect.to(0, EffectController(duration: 0.6, curve: Curves.easeIn)));
  }
}

class _GradientBackground extends PositionComponent {
  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        rect.center,
        size.x * 0.75,
        const [Color(0xFFFFF3E0), Color(0xFFB3E5FC)],
      );
    canvas.drawRect(rect, paint);
  }
}

/// AI生成したモンスターイラストを表示するボス本体。
/// 被弾/反撃時の色フラッシュは SpriteComponent の paint に colorFilter を
/// 一時適用することで表現する（画像自体は差し替えない）。
class _BossSprite extends SpriteComponent {
  _BossSprite(ui.Image image)
      : super(sprite: Sprite(image), size: Vector2(220, 220), anchor: Anchor.center);

  void flashHit() {
    paint.colorFilter = const ColorFilter.mode(Colors.white, BlendMode.srcATop);
    Future.delayed(const Duration(milliseconds: 70), () {
      paint.colorFilter = null;
    });
  }

  void flashAngry() {
    paint.colorFilter = const ColorFilter.mode(Color(0xFFD32F2F), BlendMode.srcATop);
    Future.delayed(const Duration(milliseconds: 200), () {
      paint.colorFilter = null;
    });
  }
}
