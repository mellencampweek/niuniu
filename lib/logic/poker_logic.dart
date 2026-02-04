// lib/logic/poker_logic.dart

/// 牛牛的计算结果类型
enum NiuResult {
  noNiu, // 没牛 (0)
  niu1, // 牛一 (1)
  niu2,
  niu3,
  niu4,
  niu5,
  niu6,
  niu7,
  niu8,
  niu9,
  niuNiu, // 牛牛 (10)
}

class PokerLogic {
  /// 核心算法：输入5张牌的点数 (1-13)，返回牛几
  /// 11=J, 12=Q, 13=K
  static NiuResult calculate(List<int> cards) {
    if (cards.length != 5) {
      throw Exception('必须输入5张牌');
    }

    // 1. 先把 JQK (11,12,13) 都转换成 10 分，用于计算
    // map转换得到一个新的列表，不改变原数组
    List<int> values = cards.map((c) => c > 10 ? 10 : c).toList();

    int totalSum = values.reduce((a, b) => a + b);

    // 2. 暴力寻找是否有3张牌之和为10的倍数
    // 因为是5选3，组合数只有C(5,3)=10种，循环效率非常高
    for (int i = 0; i < 5; i++) {
      for (int j = i + 1; j < 5; j++) {
        for (int k = j + 1; k < 5; k++) {
          int sum3 = values[i] + values[j] + values[k];

          // 如果这3张牌凑成了10的倍数 (有牛)
          if (sum3 % 10 == 0) {
            // 剩下的2张牌之和
            int remainingSum = totalSum - sum3;

            // 计算牛几：余数是0就是牛牛，否则就是余数
            int remainder = remainingSum % 10;
            return remainder == 0
                ? NiuResult.niuNiu
                : NiuResult.values[remainder];
          }
        }
      }
    }

    // 3. 找遍了所有组合都没凑成10的倍数
    return NiuResult.noNiu;
  }

  /// 辅助方法：把结果转成中文，方便打印调试
  static String resultToChinese(NiuResult result) {
    switch (result) {
      case NiuResult.noNiu:
        return '没牛';
      case NiuResult.niuNiu:
        return '牛牛';
      default:
        return '牛${result.index}';
    }
  }
}
