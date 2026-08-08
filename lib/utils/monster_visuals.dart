import 'package:flutter/material.dart';

import '../models/stage.dart';

/// モンスターごとの絵文字・教科カラー（小学コレ！の教科カラーを踏襲）
String monsterEmoji(MonsterType type) => switch (type) {
      MonsterType.kanjiGoblin => '👹',
      MonsterType.kukuSlime => '🟥',
      MonsterType.prefectureDragon => '🐲',
      MonsterType.experimentGhost => '👻',
    };

String subjectName(MonsterType type) => switch (type) {
      MonsterType.kanjiGoblin => '国語',
      MonsterType.kukuSlime => '算数',
      MonsterType.prefectureDragon => '社会',
      MonsterType.experimentGhost => '理科',
    };

Color subjectColor(MonsterType type) => switch (type) {
      MonsterType.kanjiGoblin => Colors.orange,
      MonsterType.kukuSlime => Colors.red,
      MonsterType.prefectureDragon => Colors.green,
      MonsterType.experimentGhost => Colors.blue,
    };

/// AI生成したモンスターイラストのファイル名（拡張子なし）
String _monsterImageId(MonsterType type) => switch (type) {
      MonsterType.kanjiGoblin => 'kanji_goblin',
      MonsterType.kukuSlime => 'kuku_slime',
      MonsterType.prefectureDragon => 'prefecture_dragon',
      MonsterType.experimentGhost => 'experiment_ghost',
    };

/// Flutter側 (Image.asset) 用の完全パス
String monsterAssetPath(MonsterType type) => 'assets/images/monsters/${_monsterImageId(type)}.png';

/// Flame側 (images.load) 用の assets/images/ からの相対パス
String monsterFlameFileName(MonsterType type) => 'monsters/${_monsterImageId(type)}.png';
