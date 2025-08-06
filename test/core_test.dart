import 'package:flutter_test/flutter_test.dart';
import 'package:grow_assess/core/services/assessment_service.dart';
import 'package:grow_assess/data/models/assessment_item.dart';
import 'package:grow_assess/data/models/assessment_result.dart';

void main() {
  group('AssessmentService Tests', () {
    late AssessmentService service;

    setUp(() {
      service = AssessmentService();
    });

    test('determineMainTestAge should return correct age group', () {
      expect(service.determineMainTestAge(12.5), 12);
      expect(service.determineMainTestAge(15.2), 15);
      expect(service.determineMainTestAge(18.8), 18);
    });

    test('calculateDevelopmentQuotient should calculate correctly', () {
      expect(service.calculateDevelopmentQuotient(12.0, 12.0), 100.0);
      expect(service.calculateDevelopmentQuotient(15.0, 12.0), 125.0);
      expect(service.calculateDevelopmentQuotient(9.0, 12.0), 75.0);
      expect(service.calculateDevelopmentQuotient(0.0, 12.0), 0.0);
    });

    test('determineLevel should return correct level', () {
      expect(service.determineLevel(135.0), 'excellent');
      expect(service.determineLevel(120.0), 'good');
      expect(service.determineLevel(100.0), 'average');
      expect(service.determineLevel(75.0), 'low');
      expect(service.determineLevel(65.0), 'disability');
    });

    test('calculateMentalAge should calculate correctly', () {
      final items = [
        AssessmentItem(
          id: '1',
          category: '大运动',
          ageGroup: '12',
          itemName: '测试项目1',
          description: '测试描述',
          passCriteria: '通过标准',
          score: 1.0,
          isImportant: false,
          canAskParent: false,
        ),
        AssessmentItem(
          id: '2',
          category: '大运动',
          ageGroup: '12',
          itemName: '测试项目2',
          description: '测试描述',
          passCriteria: '通过标准',
          score: 1.0,
          isImportant: false,
          canAskParent: false,
        ),
      ];

      final results = {
        '1': true,
        '2': false,
      };

      final mentalAge = service.calculateMentalAge(items, results, 'motor');
      expect(mentalAge, 1.0); // 只计算第一个通过的项目
    });

    test('calculateResult should create valid result', () {
      final items = [
        AssessmentItem(
          id: '1',
          category: '大运动',
          ageGroup: '12',
          itemName: '测试项目',
          description: '测试描述',
          passCriteria: '通过标准',
          score: 1.0,
          isImportant: false,
          canAskParent: false,
        ),
      ];

      final results = {
        '1': true,
      };

      final result = service.calculateResult(items, results, 'test-baby-id', 12.0);
      
      expect(result.babyId, 'test-baby-id');
      expect(result.ageInMonths, 12.0);
      expect(result.mainTestAge, 12);
      expect(result.status, 'completed');
      expect(result.areaResults.length, 5); // 5个能区
    });
  });
} 