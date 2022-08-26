import 'dart:math';

import 'package:flutter/material.dart';
import 'package:game_minesweeper/game_level_model.dart';
import 'package:game_minesweeper/item_model.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late GameLevelModel levelModel;
  late List<List<ItemModel>> itemModels;

  @override
  void initState() {
    super.initState();

    GameLevelModel model = Get.arguments as GameLevelModel;
    if (model == null) {
      this.levelModel = GameLevelModel.buildModel(0);
    } else {
      this.levelModel = model;
    }

    List<List<ItemModel>> itemModels = [];
    for (var x = 0; x < levelModel.itemCount; x++) {
      List<ItemModel> list = [];
      for (var y = 0; y < levelModel.itemCount; y++) {
        list.add(ItemModel(x: x, y: y));
      }
      itemModels.add(list);
    }
    this.itemModels = itemModels;

    _initAllItems();
  }

  // 初始化所有的 item
  void _initAllItems() {
    _initItemModels();
    _randomLandmine();
    _statisticsLandmineCount();
  }

  // 获取 index 的 model
  ItemModel _findeItemModeAtIndex(int index) {
    int x = (index / levelModel.itemCount).toInt();
    int y = index % levelModel.itemCount;
    return itemModels[x][y];
  }

  // 初始化所有的item
  void _initItemModels() {
    for (var x = 0; x < levelModel.itemCount; x++) {
      for (var y = 0; y < levelModel.itemCount; y++) {
        final itemModel = itemModels[x][y];
        itemModel.initData();
      }
    }
  }

  // 随机
  void _randomLandmine() {
    var landmineCount = 0;
    while (landmineCount < levelModel.landmineCount) {
      var random = new Random();
      final x = random.nextInt(levelModel.itemCount);
      final y = random.nextInt(levelModel.itemCount);
      final itemModel = itemModels[x][y];
      if (itemModel.number != 9) {
        itemModel.number = 9;
        landmineCount++;
      }
    }
  }

  // 周围的 itemModel
  List<ItemModel> _neighborItems(ItemModel itemModel) {
    final x_min = itemModel.x - 1;
    final x_max = itemModel.x + 1;
    final y_min = itemModel.y - 1;
    final y_max = itemModel.y + 1;
    List<ItemModel> list = [];
    for (var x = x_min; x <= x_max; x++) {
      if (x < 0 || x >= levelModel.itemCount) {
        continue;
      }
      for (var y = y_min; y <= y_max; y++) {
        if (y < 0 || y >= levelModel.itemCount) {
          continue;
        }
        list.add(itemModels[x][y]);
      }
    }
    return list;
  }

  // 统计数量
  void _statisticsLandmineCount() {
    for (var x = 0; x < levelModel.itemCount; x++) {
      for (var y = 0; y < levelModel.itemCount; y++) {
        final itemModel = itemModels[x][y];
        if (itemModel.number == 9) {
          continue;
        }
        final list = _neighborItems(itemModel).where((element) => element.number == 9);
        itemModel.number = list.length;
      }
    }
  }

  // 是否成功了
  bool _isSuccess() {
    List<ItemModel> list = [];
    for (var x = 0; x < levelModel.itemCount; x++) {
      for (var y = 0; y < levelModel.itemCount; y++) {
        ItemModel itemModel = itemModels[x][y];
        if (itemModel.selected == false) {
          list.add(itemModel);
        }
      }
    }
    return list.length == levelModel.landmineCount;
  }

  // 打开所有的 item
  void _openAllItems() {
    for (var x = 0; x < levelModel.itemCount; x++) {
      for (var y = 0; y < levelModel.itemCount; y++) {
        final itemModel = itemModels[x][y];
        itemModel.selected = true;
      }
    }
  }

  // 打开邻近的所有空白item
  void _openNeighborBlankItems(ItemModel itemModel) {
    if (itemModel.selected) {
      return;
    }

    // 打开
    itemModel.selected = true;

    // 失败
    if (itemModel.number == 9) {
      print(" 游戏失败");
      itemModel.wrongClick = true;
      _openAllItems();
      setState(() {});
      return;
    }

    // 胜利
    if (_isSuccess()) {
      print(" 游戏胜利");
      _openAllItems();
      return;
    }

    // 相邻的周围雷为 0 的，自动打开
    final list = _neighborItems(itemModel);
    final count = list.where((element) => element.number == 9).length;
    if (count == 0) {
      for (var element in list) {
        _openNeighborBlankItems(element);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(levelModel.title),
      ),
      body: Column(
        children: [
          _buildHeaderView(),
          _buildGameView(),
          _buildFooterView(),
        ],
      ),
    );
  }

  Widget _buildHeaderView() {
    return Container(
      width: 1.sw,
      height: 100.w,
      color: Colors.red,
    );
  }

  Widget _buildGameView() {
    final itemCount = levelModel.itemCount * levelModel.itemCount;

    return Container(
        height: 1.sw,
        width: 1.sw,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: levelModel.itemCount,
            childAspectRatio: 1,
            mainAxisSpacing: 1,
            crossAxisSpacing: 1,
          ),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            final itemModel = _findeItemModeAtIndex(index);
            String imageName;
            if (itemModel.selected) {
              if (itemModel.wrongClick) {
                imageName = "images/item_x.png";
              } else {
                imageName = "images/item_${itemModel.number}.png";
              }
            } else {
              switch (itemModel.markState) {
                case ItemMarkState.normal:
                  imageName = "images/item_default.png";
                  break;
                case ItemMarkState.flag:
                  imageName = "images/item_flag.png";
                  break;
                case ItemMarkState.doubt:
                  imageName = "images/item_doubt.png";
                  break;
              }
            }

            return GestureDetector(
              child: Container(
                child: Image(image: AssetImage(imageName)),
              ),
              onTap: () {
                setState(() {
                  _openNeighborBlankItems(itemModel);
                });
              },
            );
          },
        ));
  }

  Widget _buildFooterView() {
    return Container(
      width: 1.sw,
      height: 100.w,
      color: Colors.yellow,
    );
  }
}
