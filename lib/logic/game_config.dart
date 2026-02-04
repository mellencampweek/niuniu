import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

enum GameMode { scoring, timing, infinite }

class GameConfig {
  // --- 1. 设置项 ---
  static double bgmVolume = 0.3;
  static double sfxVolume = 1.0;
  static bool enableVibration = true;
  static int gameDuration = 30;
  static bool practiceAutoReveal = false;

  // ⚠️ 确认文件名：请确保你的 assets/audio/ 下面真的是这个名字
  static const String _bgmFile = 'jazz.mp3';

  // --- 2. 历史记录 ---
  static int highScore30s = 0;
  static int highScore60s = 0;
  static int bestTimeTiming = 999;
  static int totalCorrectInfinite = 0;

  static final AudioPlayer _bgmPlayer = AudioPlayer();
  static final AudioPlayer _sfxPlayer = AudioPlayer();

  // --- 3. 初始化加载 ---
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    bgmVolume = prefs.getDouble('bgmVolume') ?? 0.3;
    sfxVolume = prefs.getDouble('sfxVolume') ?? 1.0;
    enableVibration = prefs.getBool('enableVibration') ?? true;
    gameDuration = prefs.getInt('gameDuration') ?? 30;
    practiceAutoReveal = prefs.getBool('practiceAutoReveal') ?? false;

    highScore30s = prefs.getInt('highScore30s') ?? 0;
    highScore60s = prefs.getInt('highScore60s') ?? 0;
    bestTimeTiming = prefs.getInt('bestTimeTiming') ?? 999;
    totalCorrectInfinite = prefs.getInt('totalCorrectInfinite') ?? 0;

    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
  }

  // --- 4. 保存设置 ---
  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('bgmVolume', bgmVolume);
    await prefs.setDouble('sfxVolume', sfxVolume);
    await prefs.setBool('enableVibration', enableVibration);
    await prefs.setInt('gameDuration', gameDuration);
    await prefs.setBool('practiceAutoReveal', practiceAutoReveal);

    _bgmPlayer.setVolume(bgmVolume);
  }

  // --- 5. 音频控制 (带调试打印版) ---

  // 播放背景音乐
  static Future<void> playBGM() async {
    print("🕵️‍♂️ [调试] 准备播放背景音乐...");
    print("🕵️‍♂️ [调试] 当前音量设置: $bgmVolume");
    print("🕵️‍♂️ [调试] 目标文件: assets/audio/$_bgmFile");

    if (bgmVolume <= 0.05) {
      print("❌ [调试] 音量太小 (<= 0.05)，停止播放");
      _bgmPlayer.stop();
      return;
    }

    try {
      if (_bgmPlayer.state != PlayerState.playing) {
        // 注意：AssetSource 会自动补全 "assets/"，所以这里只写 "audio/..."
        await _bgmPlayer.play(AssetSource('audio/$_bgmFile'),
            volume: bgmVolume);
        print("✅ [调试] 播放指令已发送！如果没有声音，请检查 pubspec.yaml 或清理缓存");
      } else {
        print("⚠️ [调试] 已经在播放中，跳过");
      }
    } catch (e) {
      print("💥 [调试] 播放报错: $e");
    }
  }

  static void stopBGM() {
    print("🛑 [调试] 停止背景音乐");
    _bgmPlayer.stop();
  }

  // 播放音效
  static Future<void> playSFX(String fileName) async {
    if (sfxVolume <= 0.05) return;
    try {
      print("🔊 [调试] 播放音效: assets/audio/$fileName");
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/$fileName'), volume: sfxVolume);
    } catch (e) {
      print("💥 [调试] 音效报错: $e");
    }
  }

  // ... (其他方法保持不变)
  static Future<void> saveScore({int? score, int? time}) async {
    final prefs = await SharedPreferences.getInstance();
    if (score != null && time == null) {
      if (gameDuration == 30) {
        if (score > highScore30s) {
          highScore30s = score;
          await prefs.setInt('highScore30s', highScore30s);
        }
      } else if (gameDuration == 60) {
        if (score > highScore60s) {
          highScore60s = score;
          await prefs.setInt('highScore60s', highScore60s);
        }
      }
    }
    if (time != null && time < bestTimeTiming) {
      bestTimeTiming = time;
      await prefs.setInt('bestTimeTiming', bestTimeTiming);
    }
  }

  static Future<void> incrementInfiniteCorrect() async {
    final prefs = await SharedPreferences.getInstance();
    totalCorrectInfinite++;
    await prefs.setInt('totalCorrectInfinite', totalCorrectInfinite);
  }

  static int getCurrentHighScore() {
    return gameDuration == 30 ? highScore30s : highScore60s;
  }

  static Future<void> vibrate({int duration = 50}) async {
    if (!enableVibration || kIsWeb) return;
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: duration);
    }
  }
}
