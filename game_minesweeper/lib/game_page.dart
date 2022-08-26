import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  var gameStatus = GameStatus.normal;
  var second = 0;
  var isTimering = false;
  Timer? timer;

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

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
    this.gameStatus = GameStatus.normal;
    _stopTimer();
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
      Fluttertoast.showToast(msg: "游戏失败");
      itemModel.wrongClick = true;
      this.gameStatus = GameStatus.failure;
      _openAllItems();
      _stopTimer();
      return;
    }

    // 胜利
    if (_isSuccess()) {
      Fluttertoast.showToast(msg: "游戏胜利");
      this.gameStatus = GameStatus.success;
      _openAllItems();
      _stopTimer();
      return;
    }

    // 相邻的周围雷为 0 的，自动打开
    if (itemModel.number == 0) {
      final list = _neighborItems(itemModel);
      for (var element in list) {
        _openNeighborBlankItems(element);
      }
    }
  }

  // 开启计时器
  void _startTimer() {
    if (this.isTimering == true) {
      return;
    }
    _stopTimer();
    this.isTimering = true;
    this.second = 0;
    this.timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        this.second += 1;
      });
    });
  }

  // 停止计时器
  void _stopTimer() {
    if (this.timer != null) {
      this.timer?.cancel();
      this.timer = null;
      this.isTimering = false;
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
    final faceImageName;
    switch (this.gameStatus) {
      case GameStatus.normal:
        faceImageName = "images/face_normal.png";
        break;
      case GameStatus.success:
        faceImageName = "images/face_success.png";
        break;
      case GameStatus.failure:
        faceImageName = "images/face_failure.png";
        break;
    }

    int num1 = 0;
    int num2 = 0;
    int num3 = 0;
    int currentSecond = this.second;
    num1 = currentSecond % 10;
    currentSecond = (currentSecond / 10).toInt();
    num2 = currentSecond % 10;
    currentSecond = (currentSecond / 10).toInt();
    num3 = currentSecond % 10;
    currentSecond = (currentSecond / 10).toInt();

    return Container(
      width: 1.sw,
      height: 100.w,
      padding: EdgeInsets.only(left: 50.w, right: 50.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 39.w,
            height: 23.w,
          ),
          GestureDetector(
            child: Container(
              width: 40.w,
              height: 40.w,
              child: Image(image: AssetImage(faceImageName)),
            ),
            onTap: () {
              setState(() {
                _initAllItems();
              });
            },
          ),
          Container(
            width: 39.5.w,
            height: 23.w,
            color: Colors.red,
            child: Row(
              children: [
                SizedBox(width: 13.w, height: 23.w, child: Image(image: AssetImage("images/classic_numbers_${num3}.png"))),
                SizedBox(width: 13.w, height: 23.w, child: Image(image: AssetImage("images/classic_numbers_${num2}.png"))),
                SizedBox(width: 13.w, height: 23.w, child: Image(image: AssetImage("images/classic_numbers_${num1}.png"))),
              ],
            ),
          ),
        ],
      ),
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
                _startTimer();
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
