import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:game_minesweeper/level_page.dart';
import 'package:game_minesweeper/page_router.dart';
import 'package:get/get.dart';
import 'page_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(375, 667),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return GetMaterialApp(
            title: "扫雷",
            home: LevelPage(),
            getPages: PageRouter.pages(),
          );
        });
  }
}
