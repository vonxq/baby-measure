import 'package:flutter_test/flutter_test.dart';
import 'package:grow_assess/data/models/baby.dart';
import 'package:grow_assess/data/models/assessment_result.dart';

void main() {
  group('Baby Model Tests', () {
    test('should create baby with correct properties', () {
      final baby = Baby(
        id: '1',
        name: '小明',
        birthDate: DateTime(2023, 1, 1),
        gender: 'male',
        avatarPath: null,
      );

      expect(baby.id, '1');
      expect(baby.name, '小明');
      expect(baby.birthDate, DateTime(2023, 1, 1));
      expect(baby.gender, 'male');
      expect(baby.avatarPath, null);
    });

    test('should calculate age correctly', () {
      final baby = Baby(
        id: '1',
        name: '小明',
        birthDate: DateTime(2023, 1, 1),
        gender: 'male',
        avatarPath: null,
      );

      final ageInMonths = baby.ageInMonths;
      expect(ageInMonths, greaterThan(0));
    });
  });

  group('Assessment Result Tests', () {
    test('should create assessment result with correct properties', () {
      final result = AssessmentResult(
        id: '1',
        babyId: '1',
        testDate: DateTime.now(),
        ageInMonths: 12.0,
        mainTestAge: 12,
        areaResults: {},
        totalMentalAge: 12.0,
        developmentQuotient: 100.0,
        level: 'average',
        status: 'completed',
        createdAt: DateTime.now(),
        totalScore: 50.0,
        maxTotalScore: 100.0,
      );

      expect(result.id, '1');
      expect(result.babyId, '1');
      expect(result.ageInMonths, 12.0);
      expect(result.developmentQuotient, 100.0);
      expect(result.level, 'average');
    });
  });
} 