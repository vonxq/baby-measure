import 'package:flutter_test/flutter_test.dart';
import 'package:grow_assess/data/models/baby.dart';
import 'package:grow_assess/data/models/assessment_result.dart';

void main() {
  group('Baby Model Tests', () {
    test('should create baby with correct properties', () {
      final baby = Baby(
        id: 'test-id',
        name: '测试宝宝',
        birthDate: DateTime(2023, 1, 1),
        gender: 'male',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(baby.id, 'test-id');
      expect(baby.name, '测试宝宝');
      expect(baby.gender, 'male');
      expect(baby.ageInMonths, greaterThan(0));
    });

    test('should calculate age correctly', () {
      final birthDate = DateTime.now().subtract(Duration(days: 365));
      final baby = Baby(
        id: 'test-id',
        name: '测试宝宝',
        birthDate: birthDate,
        gender: 'male',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(baby.ageInMonths, closeTo(12.0, 0.1));
    });
  });

  group('Assessment Result Tests', () {
    test('should create assessment result with correct properties', () {
      final result = AssessmentResult(
        id: 'test-result-id',
        babyId: 'test-baby-id',
        testDate: DateTime.now(),
        ageInMonths: 12.0,
        developmentQuotient: 100.0,
        levelDescription: '正常',
        levelColor: 0xFF4CAF50,
        areaResults: {
          'motor': AreaResult(
            mentalAge: 12.0,
            score: 10.0,
            maxScore: 10.0,
            percentage: 100.0,
          ),
        },
        totalScore: 50.0,
        maxTotalScore: 50.0,
      );

      expect(result.id, 'test-result-id');
      expect(result.babyId, 'test-baby-id');
      expect(result.developmentQuotient, 100.0);
      expect(result.levelDescription, '正常');
    });
  });
} 