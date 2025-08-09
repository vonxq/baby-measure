import 'package:flutter/material.dart';

enum DqLevel { excellent, good, medium, borderlineLow, impaired }

class DqUtils {
  // 颜色方案（用户提供）
  // 新配色
  // 优秀（≥130） → #00A896
  static const Color colorExcellent = Color(0xFF00A896);
  // 良好（110～129） → #48B0A3
  static const Color colorGood = Color(0xFF48B0A3);
  // 中等（80～109） → #66C2A5
  static const Color colorMedium = Color(0xFF66C2A5);
  // 临界偏低（70～79） → #7FB8D9
  static const Color colorBorderlineLow = Color(0xFF7FB8D9);
  // 发育障碍（＜70） → #FF4D4D
  static const Color colorImpaired = Color(0xFFFF4D4D);

  static DqLevel levelOf(double dq) {
    if (dq >= 130) return DqLevel.excellent;
    if (dq >= 110) return DqLevel.good;
    if (dq >= 80) return DqLevel.medium;
    if (dq >= 70) return DqLevel.borderlineLow;
    return DqLevel.impaired;
  }

  static String labelOf(DqLevel level) {
    switch (level) {
      case DqLevel.excellent:
        return '优秀';
      case DqLevel.good:
        return '良好';
      case DqLevel.medium:
        return '中等';
      case DqLevel.borderlineLow:
        return '临界偏低';
      case DqLevel.impaired:
        return '智力发育障碍';
    }
  }

  static String labelByDq(double dq) => labelOf(levelOf(dq));

  static Color colorOf(DqLevel level) {
    switch (level) {
      case DqLevel.excellent:
        return colorExcellent;
      case DqLevel.good:
        return colorGood;
      case DqLevel.medium:
        return colorMedium;
      case DqLevel.borderlineLow:
        return colorBorderlineLow;
      case DqLevel.impaired:
        return colorImpaired;
    }
  }

  static Color colorByDq(double dq) => colorOf(levelOf(dq));

  static String descriptionByDq(double dq) {
    final level = levelOf(dq);
    switch (level) {
      case DqLevel.excellent:
        return '发育水平优秀，各项能力发展非常好。';
      case DqLevel.good:
        return '发育水平良好，各项能力发展正常。';
      case DqLevel.medium:
        return '发育水平中等，建议持续关注发展变化。';
      case DqLevel.borderlineLow:
        return '发育水平临界偏低，建议咨询专业医生进一步评估。';
      case DqLevel.impaired:
        return '可能存在发育障碍，请尽快咨询专业医生进行评估。';
    }
  }
}

