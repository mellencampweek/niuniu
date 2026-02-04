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

    // --- 音频兼容性配置 ---
    try {
      // 尝试设置音频上下文（兼容旧版本写法）
      await AudioPlayer.global.setAudioContext(AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.ambient,
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: true,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.none,
        ),
      ));
    } catch (e) {
      // 如果版本不支持，忽略错误
      print("Audio Context Warning: $e");
    }

    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _sfxPlayer.setPlayerMode(PlayerMode.lowLatency);
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

  // --- 5. 音频控制 ---

  static Future<void> playBGM() async {
    if (bgmVolume <= 0.05) {
      _bgmPlayer.stop();
      return;
    }

    try {
      if (_bgmPlayer.state != PlayerState.playing) {
        await _bgmPlayer.play(AssetSource('audio/$_bgmFile'),
            volume: bgmVolume);
      }
    } catch (e) {
      // ignore
    }
  }

  static void stopBGM() {
    _bgmPlayer.stop();
  }

  static Future<void> playSFX(String fileName) async {
    if (sfxVolume <= 0.05) return;
    try {
      await _sfxPlayer.play(AssetSource('audio/$fileName'), volume: sfxVolume);
    } catch (e) {}
  }

  // --- 6. 数据逻辑 ---

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
