import '../models/stage.dart';

class _StageTemplate {
  const _StageTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.monsterType,
    required this.trivia,
  });

  final int id;
  final String title;
  final String description;
  final MonsterType monsterType;
  final String trivia;
}

/// Firestore 未接続のため、現状はローカル固定データを返す。
/// Phase 3 で Firestore の stages コレクションに差し替える。
class StageRepository {
  static const _templates = [
    _StageTemplate(
      id: 1,
      title: '漢字ゴブリンの罠',
      description: '書き取りドリルが化けた漢字ゴブリンを、ブロックの罠にはめよう',
      monsterType: MonsterType.kanjiGoblin,
      trivia: '「様」の右側は「羊」ではなく「永」に近い形だよ。',
    ),
    _StageTemplate(
      id: 2,
      title: '九九スライムの罠',
      description: '計算ドリルが化けた九九スライムを、ブロックの罠にはめよう',
      monsterType: MonsterType.kukuSlime,
      trivia: '7の段でつまずきやすいのは「7×7=49」。しちしちしじゅうく、と唱えて覚えよう。',
    ),
    _StageTemplate(
      id: 3,
      title: '都道府県ドラゴンの罠',
      description: '暗記ドリルが化けた都道府県ドラゴンを、ブロックの罠にはめよう',
      monsterType: MonsterType.prefectureDragon,
      trivia: '都道府県で面積が一番小さいのは香川県だよ。',
    ),
    _StageTemplate(
      id: 4,
      title: '実験オバケの罠',
      description: '観察ドリルが化けた実験オバケを、ブロックの罠にはめよう',
      monsterType: MonsterType.experimentGhost,
      trivia: '水は0℃で凍り、100℃で沸騰するよ。',
    ),
  ];

  static final List<Stage> _stages = _templates
      .expand((t) => [
            Stage(
              id: t.id,
              title: t.title,
              description: t.description,
              difficulty: Difficulty.easy,
              monsterType: t.monsterType,
              bossHp: 20,
              gridSize: 3,
              blocksRequired: const [
                BlockPosition(type: 'wall', row: 0, col: 1),
                BlockPosition(type: 'wall', row: 1, col: 0),
                BlockPosition(type: 'wall', row: 1, col: 2),
              ],
              tier: t.id,
              trivia: t.trivia,
            ),
            Stage(
              id: t.id,
              title: t.title,
              description: t.description,
              difficulty: Difficulty.normal,
              monsterType: t.monsterType,
              bossHp: 35,
              gridSize: 3,
              blocksRequired: const [
                BlockPosition(type: 'wall', row: 0, col: 0),
                BlockPosition(type: 'wall', row: 0, col: 2),
                BlockPosition(type: 'wall', row: 1, col: 0),
                BlockPosition(type: 'wall', row: 1, col: 2),
                BlockPosition(type: 'trap', row: 2, col: 1),
              ],
              tier: t.id,
              trivia: t.trivia,
            ),
            Stage(
              id: t.id,
              title: t.title,
              description: t.description,
              difficulty: Difficulty.hard,
              monsterType: t.monsterType,
              bossHp: 50,
              gridSize: 4,
              blocksRequired: const [
                BlockPosition(type: 'wall', row: 0, col: 1),
                BlockPosition(type: 'wall', row: 0, col: 2),
                BlockPosition(type: 'wall', row: 1, col: 0),
                BlockPosition(type: 'wall', row: 1, col: 3),
                BlockPosition(type: 'wall', row: 2, col: 0),
                BlockPosition(type: 'wall', row: 2, col: 3),
                BlockPosition(type: 'trap', row: 3, col: 1),
              ],
              tier: t.id,
              trivia: t.trivia,
            ),
          ])
      .toList(growable: false)
    ..forEach(_assertValidStage);

  /// 同一マス(row,col)への重複配置はブロック配置画面の「全部置いた」判定を
  /// 永久に満たせなくするソフトロックを招くため、デバッグビルドで早期検出する。
  static void _assertValidStage(Stage stage) {
    assert(() {
      final seen = <String>{};
      for (final b in stage.blocksRequired) {
        assert(
          b.row >= 0 && b.row < stage.gridSize && b.col >= 0 && b.col < stage.gridSize,
          'Stage ${stage.id}(${stage.difficulty}) has an out-of-grid block at (${b.row},${b.col})',
        );
        final key = '${b.row},${b.col}';
        assert(
          seen.add(key),
          'Stage ${stage.id}(${stage.difficulty}) has duplicate blocksRequired at (${b.row},${b.col})',
        );
      }
      return true;
    }());
  }

  /// ホーム画面のステージ一覧表示用（各ステージのEasy版を代表として返す）
  List<Stage> allStageSummaries() =>
      _stages.where((s) => s.difficulty == Difficulty.easy).toList(growable: false);

  Stage stageByDifficulty(int stageId, Difficulty difficulty) =>
      _stages.firstWhere((s) => s.id == stageId && s.difficulty == difficulty);
}
