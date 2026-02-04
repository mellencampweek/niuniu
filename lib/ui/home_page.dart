import 'package:flutter/material.dart';
import '../logic/game_config.dart';
import 'settings_panel.dart';
import 'game_page.dart';
import 'help_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // ✅ 简化：直接播放 jazz.mp3
    GameConfig.playBGM();
    _refreshScores();
  }

  void _refreshScores() {
    setState(() {});
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C2C2C),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => const SettingsPanel(),
    ).then((_) => _refreshScores());
  }

  void _startGame(GameMode mode) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => GamePage(mode: mode)),
    );
    _refreshScores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.3,
            colors: [
              Color(0xFF006400),
              Color(0xFF002200),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 20,
                right: 20,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.help_outline,
                          color: Colors.white54, size: 30),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const HelpPage()),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.settings,
                          color: Colors.white54, size: 30),
                      onPressed: _showSettings,
                    ),
                  ],
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("🐮 牛牛练习器 🐮",
                        style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                  offset: Offset(2, 2),
                                  blurRadius: 4,
                                  color: Colors.black45)
                            ])),
                    const SizedBox(height: 30),
                    SizedBox(
                      height: 80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildUiCard("10", "♠", Colors.black),
                          _buildUiCard("J", "♠", Colors.black),
                          _buildUiCard("Q", "♠", Colors.black),
                          _buildUiCard("K", "♠", Colors.black),
                          _buildUiCard("A", "♠", Colors.black),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                    _buildModeSection(
                        "⏱️ 计分模式",
                        const Color(0xFF4CAF50),
                        GameMode.scoring,
                        "30s纪录: ${GameConfig.highScore30s}  |  60s纪录: ${GameConfig.highScore60s}"),
                    const SizedBox(height: 20),
                    _buildModeSection(
                        "⚡ 计时模式",
                        const Color(0xFF2196F3),
                        GameMode.timing,
                        GameConfig.bestTimeTiming == 999
                            ? "暂无记录"
                            : "最快记录: ${GameConfig.bestTimeTiming} 秒"),
                    const SizedBox(height: 20),
                    _buildModeSection(
                        "🧩 练习模式",
                        const Color(0xFF9C27B0),
                        GameMode.infinite,
                        "历史累计答对: ${GameConfig.totalCorrectInfinite} 题"),
                  ],
                ),
              ),
              const Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Center(
                    child: Text("v1.0.0",
                        style: TextStyle(color: Colors.white24))),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUiCard(String rank, String suit, Color color) {
    return Container(
      width: 50,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFD),
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(color: Colors.black38, offset: Offset(2, 2), blurRadius: 4)
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(rank,
              style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif')),
          Text(suit, style: TextStyle(color: color, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildModeSection(
      String title, Color color, GameMode mode, String scoreText) {
    return Column(
      children: [
        SizedBox(
          width: 260,
          height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 6,
              shadowColor: Colors.black45,
            ),
            onPressed: () => _startGame(mode),
            child: Text(title,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(scoreText,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontFamily: "monospace")),
        ),
      ],
    );
  }
}
