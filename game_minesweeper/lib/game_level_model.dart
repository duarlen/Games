class GameLevelModel {
  final int level;
  final String title;
  final int itemCount;
  final int landmineCount;

  GameLevelModel({required this.level, required this.title, required this.itemCount, required this.landmineCount});

  static GameLevelModel buildModel(int level) {
    if (level == 0) {
      return GameLevelModel(level: level, title: "初级", itemCount: 10, landmineCount: 10);
    }
    if (level == 1) {
      return GameLevelModel(level: level, title: "中级", itemCount: 16, landmineCount: 40);
    }
    return GameLevelModel(level: level, title: "高级", itemCount: 20, landmineCount: 99);
  }
}
