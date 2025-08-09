import 'package:flutter/material.dart';

/// 统一的发育商（DQ）等级与配色工具
enum DqLevel { excellent, good, medium, borderlineLow, impaired }

class DqUtils {
  // 最新配色（全局统一）
  // 优秀（≥130） → #237804
  static const Color colorExcellent = Color(0xFF237804);
  // 良好（110～129） → #389E0D
  static const Color colorGood = Color(0xFF389E0D);
  // 中等（80～109） → #52C41A
  static const Color colorMedium = Color(0xFF52C41A);
  // 临界（70～79） → #FAAD14
  static const Color colorBorderlineLow = Color(0xFFFAAD14);
  // 发育障碍（＜70） → #F5222D
  static const Color colorImpaired = Color(0xFFF5222D);

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
        return '发育障碍';
    }
  }

  static String labelByDq(double dq) => labelOf(levelOf(dq));

  /// 更短的标签，适合窄卡片徽标
  static String compactLabelByDq(double dq) {
    switch (levelOf(dq)) {
      case DqLevel.excellent:
        return '优秀';
      case DqLevel.good:
        return '良好';
      case DqLevel.medium:
        return '中等';
      case DqLevel.borderlineLow:
        return '临界';
      case DqLevel.impaired:
        return '发育障碍';
    }
  }

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
    switch (levelOf(dq)) {
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

