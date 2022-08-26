enum ItemMarkState {
  normal,
  flag,
  doubt,
}

enum GameStatus {
  normal,
  success,
  failure,
}

class ItemModel {
  final int x;
  final int y;
  int number = 0;
  bool selected = false;
  bool wrongClick = false;
  ItemMarkState markState = ItemMarkState.normal;
  ItemModel({required this.x, required this.y});

  void initData() {
    number = 0;
    selected = false;
    wrongClick = false;
    markState = ItemMarkState.normal;
  }
}
