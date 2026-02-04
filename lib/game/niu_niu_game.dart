// lib/game/niu_niu_game.dart

import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'poker_card.dart';
import 'dart:math';

class NiuNiuGame extends FlameGame {
  final Function(List<int>) onHandDealt;

  NiuNiuGame({required this.onHandDealt});

  @override
  Future<void> onLoad() async {
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xFF006400),
    ));
    startNewRound();
  }

  void startNewRound() {
    children.whereType<PokerCard>().forEach((card) => card.removeFromParent());

    final hand = _generateRandomHand();
    final ranks = hand.map((card) => card[1]).toList();
    onHandDealt(ranks);

    // 适配屏幕宽度
    final cardWidth = size.x * 0.17;
    final cardHeight = cardWidth * 1.5;
    final spacing = size.x * 0.18;
    final centerX = size.x / 2;
    final centerY = size.y / 2;

    for (int i = 0; i < hand.length; i++) {
      final offsetX = (i - 2) * spacing;
      add(PokerCard(
        suit: hand[i][0],
        rank: hand[i][1],
        position: Vector2(centerX + offsetX, centerY),
        size: Vector2(cardWidth, cardHeight),
        anchor: Anchor.center,
      ));
    }
  }

  // ✅ 修正后的发牌逻辑：模拟真实洗牌
  List<List<int>> _generateRandomHand() {
    // 1. 生成 52 张牌
    List<List<int>> deck = [];
    for (int suit = 0; suit < 4; suit++) {
      for (int rank = 1; rank <= 13; rank++) {
        deck.add([suit, rank]);
      }
    }
    // 2. 洗牌
    deck.shuffle();
    // 3. 发前 5 张
    return deck.sublist(0, 5);
  }
}
