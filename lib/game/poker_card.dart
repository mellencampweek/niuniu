import 'package:flame/components.dart';
import 'package:flame/game.dart';

class PokerCard extends SpriteComponent with HasGameRef {
  final int suit;
  final int rank;

  // 构造函数
  PokerCard({
    required this.suit,
    required this.rank,
    super.position,
    super.size,
    super.anchor,
  });

  @override
  Future<void> onLoad() async {
    // 1. 加载图片
    final image = await gameRef.images.load('cards.png');

    // 2. 算一下单张牌的大小
    final w = image.width / 13;
    final h = image.height / 4;

    // 3. 算出切图坐标
    final x = (rank - 1) * w;
    final y = suit * h;

    // 4. 设置贴图
    sprite = Sprite(
      image,
      srcPosition: Vector2(x, y),
      srcSize: Vector2(w, h),
    );
  }
}
