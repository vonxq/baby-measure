// 统一维护允许选择的月龄集合，以及映射到最近可选月龄的工具函数

const List<int> kAllowedAges = <int>[
  1, 2, 3, 4, 5, 6,
  7, 8, 9, 10, 11, 12,
  15, 18, 21, 24, 27, 30, 33, 36,
  42, 48, 54, 60, 66, 72, 78, 84,
];

int nearestAllowedAge(int currentAge) {
  if (kAllowedAges.isEmpty) return currentAge;
  int closest = kAllowedAges.first;
  int minDiff = (currentAge - closest).abs();
  for (final age in kAllowedAges) {
    final diff = (currentAge - age).abs();
    if (diff < minDiff) {
      minDiff = diff;
      closest = age;
    }
  }
  return closest;
}

