import 'package:flutter/material.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // 保持深色背景
      body: Stack(
        children: [
          // 1. 滑动内容区
          PageView(
            controller: _controller,
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: [
              _buildPage1Rules(),
              _buildPage2Calculation(),
              _buildPage3Modes(),
            ],
          ),

          // 2. 底部指示点 (Dots)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) => _buildDot(index)),
            ),
          ),

          // 3. 关闭按钮 (右上角)
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white54, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  // --- 第一页：核心规则 ---
  Widget _buildPage1Rules() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.class_, size: 80, color: Colors.amber),
          const SizedBox(height: 20),
          const Text("什么是“牛”？",
              style: TextStyle(
                  color: Colors.amber,
                  fontSize: 28,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          const Text(
            "“牛牛”玩法的核心是\n从5张牌中找到3张牌\n它们的点数之和是 10 的倍数",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18, height: 1.5),
          ),
          const SizedBox(height: 40),
          // 视觉演示：3张牌凑整
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDemoCard("10", Colors.black, highlight: true),
              _buildDemoCard("K", Colors.red, highlight: true),
              _buildDemoCard("Q", Colors.black, highlight: true),
              const SizedBox(width: 15),
              _buildDemoCard("A", Colors.red),
              _buildDemoCard("8", Colors.black),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "⬆️ 金色框的3张牌凑成了30 (牛底)\n剩下的 1+8=9，所以这是【牛九】",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // --- 第二页：算分公式 ---
  Widget _buildPage2Calculation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calculate, size: 80, color: Colors.greenAccent),
          const SizedBox(height: 20),
          const Text("点数怎么算？",
              style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 28,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          _buildCalcRow(
              "J", "Q", "10", "5", "3", "牛八", "10+10+10=30 (有牛)\n5+3=8"),
          const Divider(color: Colors.white12, height: 40),
          _buildCalcRow(
              "3", "5", "A", "8", "K", "没牛", "任意3张都凑不出10的倍数\n这就是【没牛】"),
        ],
      ),
    );
  }

  // --- 第三页：模式介绍 ---
  Widget _buildPage3Modes() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.videogame_asset, size: 80, color: Colors.blueAccent),
          const SizedBox(height: 20),
          const Text("三种模式",
              style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 28,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          _buildModeDesc("⏱️ 计分模式", "限时30秒或60秒，答对加分，答错扣分。追求最高分！"),
          const SizedBox(height: 20),
          _buildModeDesc("⚡ 计时模式", "必须连续答对10题。错一次直接失败。追求最快手速！"),
          const SizedBox(height: 20),
          _buildModeDesc("🧩 练习模式", "无压力刷题。如果你算不出，可以开启右上角的【错题显形】看答案。"),
          const SizedBox(height: 60),
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber, foregroundColor: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("开始练习！",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  // --- 组件封装 ---

  // 模式文字描述
  Widget _buildModeDesc(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      ],
    );
  }

  // 算分演示行
  Widget _buildCalcRow(String c1, String c2, String c3, String c4, String c5,
      String result, String logic) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSmallCard(c1),
            _buildSmallCard(c2),
            _buildSmallCard(c3),
            const SizedBox(width: 10),
            _buildSmallCard(c4),
            _buildSmallCard(c5),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_right_alt, color: Colors.white54),
            const SizedBox(width: 5),
            Text(result,
                style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Text(logic,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }

  // 底部指示点
  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index ? Colors.amber : Colors.white24,
      ),
    );
  }

  // 迷你卡片 (用于文字流中)
  Widget _buildSmallCard(String text) {
    return Container(
      width: 24,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(3)),
      alignment: Alignment.center,
      child: Text(text,
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  // 演示卡片 (带高亮功能)
  Widget _buildDemoCard(String text, Color color, {bool highlight = false}) {
    return Container(
      width: 40,
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFD),
        borderRadius: BorderRadius.circular(6),
        border: highlight
            ? Border.all(color: Colors.amber, width: 3)
            : null, // 高亮边框
        boxShadow: const [
          BoxShadow(color: Colors.black38, offset: Offset(2, 2), blurRadius: 4)
        ],
      ),
      alignment: Alignment.center,
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }
}
