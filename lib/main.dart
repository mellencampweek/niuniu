import 'package:flutter/material.dart';
import 'logic/game_config.dart';
import 'ui/home_page.dart'; // 只需要引入主页

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 提前加载配置 (读取之前的音量设置)
  await GameConfig.load();

  runApp(const MaterialApp(
    home: HomePage(), // 直接去主页
    debugShowCheckedModeBanner: false,
  ));
}
