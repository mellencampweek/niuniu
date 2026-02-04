import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/niu_niu_game.dart';
import '../logic/poker_logic.dart';
import '../logic/game_config.dart';

class GamePage extends StatefulWidget {
  final GameMode mode;
  const GamePage({super.key, this.mode = GameMode.scoring});
  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late NiuNiuGame game;
  NiuResult? correctAnswer;
  NiuResult? selectedAnswer;
  Timer? _timer;

  int timerValue = 0;
  int score = 0;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    _initGameData();
    game = NiuNiuGame(
      onHandDealt: (ranks) {
        final result = PokerLogic.calculate(ranks);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !isGameOver) {
            setState(() {
              correctAnswer = result;
              selectedAnswer = null;
            });
          }
        });
      },
    );
    _startTimer();
  }

  void _initGameData() {
    score = 0;
    isGameOver = false;
    if (widget.mode == GameMode.scoring) {
      timerValue = GameConfig.gameDuration;
    } else {
      timerValue = 0;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isGameOver) {
        timer.cancel();
        return;
      }
      setState(() {
        if (widget.mode == GameMode.scoring) {
          if (timerValue > 0) {
            timerValue--;
          } else {
            timer.cancel();
            _handleGameOver();
          }
        } else {
          timerValue++;
        }
      });
    });
  }

  // --- 🛑 练习模式专用：错误详情弹窗 ---
  void _showPracticeErrorDialog(NiuResult correctResult) {
    GameConfig.vibrate(duration: 500);
    showDialog(
      context: context,
      barrierDismissible: false, // 🔒 必须点击按钮才能关闭，禁止点背景关闭
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("回答错误 😅", style: TextStyle(color: Colors.redAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("别急，再看一眼牌面...", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            const Text("正确答案是",
                style: TextStyle(color: Colors.white38, fontSize: 14)),
            const SizedBox(height: 4),
            Text(PokerLogic.resultToChinese(correctResult),
                style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 40,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          // 👇 只有点击这个按钮，才会发新牌
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.of(ctx).pop(); // 1. 关掉弹窗
                game.startNewRound(); // 2. 发下一手牌 (手动触发)
              },
              child: const Text("看懂了，下一题",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  // 结束处理 (计分/计时模式用)
  void _handleGameOver({bool win = false, NiuResult? correctResult}) {
    setState(() {
      isGameOver = true;
    });
    _timer?.cancel();

    GameConfig.vibrate(duration: win ? 200 : 800);

    bool isNewRecord = false;
    if (widget.mode == GameMode.scoring) {
      int currentHigh = GameConfig.getCurrentHighScore();
      if (score > currentHigh) isNewRecord = true;
      GameConfig.saveScore(score: score);
    } else if (widget.mode == GameMode.timing && win) {
      if (timerValue < GameConfig.bestTimeTiming) isNewRecord = true;
      GameConfig.saveScore(time: timerValue);
    }

    String title = "⏳ 时间到！";
    Widget contentWidget;

    if (widget.mode == GameMode.timing) {
      title = win ? "🎉 挑战成功！" : "💥 挑战失败！";
      if (win) {
        contentWidget = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("耗时: ${timerValue}秒",
                style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 32,
                    fontWeight: FontWeight.bold)),
            if (isNewRecord)
              const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text("🚨 新纪录！🚨",
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)))
          ],
        );
      } else {
        String correctStr = correctResult != null
            ? PokerLogic.resultToChinese(correctResult)
            : "未知";
        contentWidget = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("计时模式不允许失误",
                style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 10),
            const Text("正确答案是",
                style: TextStyle(color: Colors.white38, fontSize: 14)),
            Text(correctStr,
                style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 40,
                    fontWeight: FontWeight.bold)),
          ],
        );
      }
    } else {
      contentWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("最终得分: $score 分",
              style: const TextStyle(color: Colors.amber, fontSize: 32)),
          if (isNewRecord)
            const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text("🚨 新纪录！🚨",
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)))
        ],
      );
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text(title,
            style: TextStyle(color: win ? Colors.greenAccent : Colors.white)),
        content: contentWidget,
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child:
                  const Text("返回主菜单", style: TextStyle(color: Colors.white70))),
          TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _restartGame();
              },
              child: const Text("再来一局")),
        ],
      ),
    );
  }

  void _restartGame() {
    setState(() {
      _initGameData();
    });
    game.startNewRound();
    _startTimer();
  }

  // 🎯 核心提交逻辑
  void _submitAnswer() {
    if (isGameOver) return;
    if (selectedAnswer == null) {
      _showFeedback("请先选择一个结果!", Colors.orange);
      return;
    }

    if (selectedAnswer == correctAnswer) {
      // ✅ 答对
      setState(() {
        score++;
      });
      GameConfig.playSFX('correct.mp3');
      _showFeedback("回答正确！", Colors.green);

      // 练习模式：实时保存累计数
      if (widget.mode == GameMode.infinite) {
        GameConfig.incrementInfiniteCorrect();
      }

      // 计时模式：检查胜利
      if (widget.mode == GameMode.timing && score >= 10) {
        _handleGameOver(win: true);
        return;
      }

      // 只有答对时，才会自动 0.3秒后下一题
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!isGameOver) game.startNewRound();
      });
    } else {
      // ❌ 答错
      GameConfig.playSFX('wrong.mp3');

      if (widget.mode == GameMode.timing) {
        _handleGameOver(win: false, correctResult: correctAnswer);
      } else if (widget.mode == GameMode.infinite) {
        // 🧩 练习模式判断
        if (GameConfig.practiceAutoReveal) {
          // ⚠️ 开关开：暂停！弹出窗口等待确认！
          _showPracticeErrorDialog(correctAnswer!);
        } else {
          // 开关关：震动提示，不换题
          _showFeedback("回答错误！请再算算", Colors.red);
          GameConfig.vibrate(duration: 100);
        }
      } else {
        // 计分模式
        setState(() {
          score--;
        });
        _showFeedback("回答错误！请再算算 (-1)", Colors.red);
        GameConfig.vibrate(duration: 100);
      }
    }
  }

  void _showFeedback(String msg, Color color) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: color,
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20)));
  }

  @override
  Widget build(BuildContext context) {
    Widget topCenterWidget;

    if (widget.mode == GameMode.infinite) {
      topCenterWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("错题显形",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Switch(
            value: GameConfig.practiceAutoReveal,
            activeColor: Colors.amber,
            onChanged: (val) {
              setState(() {
                GameConfig.practiceAutoReveal = val;
                GameConfig.save();
              });
            },
          )
        ],
      );
    } else {
      String timerText = "";
      if (widget.mode == GameMode.scoring) {
        timerText = "00:${timerValue.toString().padLeft(2, '0')}";
      } else {
        int min = timerValue ~/ 60;
        int sec = timerValue % 60;
        timerText =
            "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
      }
      topCenterWidget = _buildInfoText(timerText, Icons.timer,
          color: (widget.mode == GameMode.scoring && timerValue <= 5)
              ? Colors.redAccent
              : Colors.white);
    }

    String scoreText =
        widget.mode == GameMode.timing ? "${score}/10" : "$score题";
    if (widget.mode == GameMode.scoring) scoreText = "$score分";

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(flex: 55, child: ClipRect(child: GameWidget(game: game))),
            Expanded(
              flex: 45,
              child: Container(
                decoration: const BoxDecoration(
                    color: Color(0xFF2C2C2C),
                    border: Border(
                        top: BorderSide(color: Colors.white10, width: 1))),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(children: [
                      _buildCircleBtn(
                          Icons.arrow_back, Colors.redAccent.withOpacity(0.2),
                          () {
                        Navigator.of(context).pop();
                      }),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Container(
                              height: 48,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(24)),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    topCenterWidget,
                                    Container(
                                        width: 1,
                                        height: 20,
                                        color: Colors.white10),
                                    _buildInfoText(
                                        scoreText, Icons.emoji_events,
                                        color: Colors.amber)
                                  ]))),
                    ]),
                    const Spacer(),
                    Column(children: [
                      _buildKeyRow(
                          [NiuResult.niu1, NiuResult.niu2, NiuResult.niu3]),
                      const SizedBox(height: 8),
                      _buildKeyRow(
                          [NiuResult.niu4, NiuResult.niu5, NiuResult.niu6]),
                      const SizedBox(height: 8),
                      _buildKeyRow(
                          [NiuResult.niu7, NiuResult.niu8, NiuResult.niu9]),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                            child: _buildNiuKey(NiuResult.noNiu,
                                color: Colors.white24)),
                        const SizedBox(width: 8),
                        Expanded(
                            child: _buildNiuKey(NiuResult.niuNiu,
                                color: Colors.redAccent.withOpacity(0.5))),
                        const SizedBox(width: 8),
                        Expanded(
                            child: _buildActionKey(
                                "确定", const Color(0xFFD4AF37), _submitAnswer))
                      ]),
                    ]),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyRow(List<NiuResult> items) {
    return Row(
        children: items
            .map((val) => Expanded(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildNiuKey(val))))
            .toList());
  }

  Widget _buildNiuKey(NiuResult value, {Color? color}) {
    final isSelected = selectedAnswer == value;
    return Material(
        color: isSelected
            ? Colors.amber
            : (color ?? Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              if (!isGameOver)
                setState(() {
                  selectedAnswer = value;
                });
            },
            child: Container(
                height: 50,
                alignment: Alignment.center,
                child: Text(PokerLogic.resultToChinese(value),
                    style: TextStyle(
                        fontSize: 20,
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: "SimHei")))));
  }

  Widget _buildActionKey(String text, Color bg, VoidCallback onTap) {
    return Material(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Container(
                height: 50,
                alignment: Alignment.center,
                child: Text(text,
                    style: const TextStyle(
                        fontSize: 22,
                        color: Colors.black,
                        fontWeight: FontWeight.w900)))));
  }

  Widget _buildCircleBtn(IconData icon, Color bg, VoidCallback onTap) {
    return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white70, size: 22)));
  }

  Widget _buildInfoText(String text, IconData icon,
      {Color color = Colors.white}) {
    return Row(children: [
      Icon(icon, size: 16, color: color.withOpacity(0.7)),
      const SizedBox(width: 6),
      Text(text,
          style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: "monospace"))
    ]);
  }
}
