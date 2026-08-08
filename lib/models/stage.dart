enum Difficulty { easy, normal, hard }

enum MonsterType { kanjiGoblin, kukuSlime, prefectureDragon, experimentGhost }

class BlockPosition {
  const BlockPosition({required this.type, required this.row, required this.col});

  final String type;
  final int row;
  final int col;

  bool matches(BlockPosition other) =>
      type == other.type && row == other.row && col == other.col;
}

class Stage {
  const Stage({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.monsterType,
    required this.bossHp,
    required this.gridSize,
    required this.blocksRequired,
    required this.tier,
    required this.trivia,
  });

  final int id;
  final String title;
  final String description;
  final Difficulty difficulty;
  final MonsterType monsterType;
  final int bossHp;
  final int gridSize;
  final List<BlockPosition> blocksRequired;
  final int tier;
  final String trivia;

  int get blocksTotal => blocksRequired.length;
}
