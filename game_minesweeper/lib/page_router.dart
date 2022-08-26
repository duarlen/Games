import 'package:game_minesweeper/level_page.dart';
import 'package:get/get.dart';
import 'game_page.dart';

const LeveLPageKey = '/level_page';
const GamePageKey = '/game_page';

class PageRouter {
  static List<GetPage> pages() {
    return [
      GetPage(
        name: LeveLPageKey,
        page: () => LevelPage(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: GamePageKey,
        page: () => GamePage(),
        transition: Transition.rightToLeft,
      ),
    ];
  }
}
