import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:game_minesweeper/game_level_model.dart';
import 'package:game_minesweeper/page_router.dart';
import 'package:get/get.dart';

class LevelPage extends StatefulWidget {
  const LevelPage({Key? key}) : super(key: key);

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Center(
        child: Container(
          width: 1.sw - 120.w,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLevelActionItem("初级", 0),
              _buildLevelActionItem("中级", 1),
              _buildLevelActionItem("高级", 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelActionItem(String title, int level) {
    return GestureDetector(
      child: Container(
        width: 1.sw - 120.w,
        height: 44.w,
        margin: EdgeInsets.only(top: 5.w, bottom: 5.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          border: Border.all(color: Colors.grey.withAlpha(100), width: 0.5),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              spreadRadius: 0.1,
              color: Colors.grey.withOpacity(0.2),
            )
          ],
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(),
        ),
      ),
      onTap: () {
        final model = GameLevelModel.buildModel(level);
        Get.toNamed(GamePageKey, arguments: model);
      },
    );
  }
}
