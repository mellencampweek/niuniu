import 'package:flutter/material.dart';
import '../logic/game_config.dart';

class SettingsPanel extends StatefulWidget {
  const SettingsPanel({super.key});

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 400, // 高度减小了，因为去掉了选择器
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
              child: Text("⚙️ 设置控制台",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold))),
          const SizedBox(height: 20),

          // 1. 游戏时长选择
          const Text("⏱️ 计分模式时长", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildDurationOption(30, "30秒"),
              const SizedBox(width: 20),
              _buildDurationOption(60, "60秒"),
            ],
          ),
          const Divider(color: Colors.white10, height: 30),

          // 2. 震动开关
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("📳 震动反馈", style: TextStyle(color: Colors.white)),
            value: GameConfig.enableVibration,
            activeColor: Colors.amber,
            onChanged: (val) {
              setState(() {
                GameConfig.enableVibration = val;
                GameConfig.save();
                if (val) GameConfig.vibrate();
              });
            },
          ),

          // 3. 音量调节
          const Text("🔊 音效音量", style: TextStyle(color: Colors.white70)),
          Slider(
            value: GameConfig.sfxVolume,
            min: 0.0,
            max: 1.0,
            activeColor: Colors.amber,
            onChanged: (val) => setState(() {
              GameConfig.sfxVolume = val;
              GameConfig.save();
            }),
          ),

          const Text("🎵 音乐音量", style: TextStyle(color: Colors.white70)),
          Slider(
            value: GameConfig.bgmVolume,
            min: 0.0,
            max: 1.0,
            activeColor: Colors.amber,
            onChanged: (val) {
              setState(() {
                GameConfig.bgmVolume = val;
                GameConfig.save();
                // 实时应用音量
                GameConfig.playBGM();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDurationOption(int seconds, String label) {
    final isSelected = GameConfig.gameDuration == seconds;
    return GestureDetector(
      onTap: () {
        setState(() {
          GameConfig.gameDuration = seconds;
          GameConfig.save();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber : Colors.white10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.amber : Colors.white30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
