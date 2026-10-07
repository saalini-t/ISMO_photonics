import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/task.dart';

void main() {
  group('Task Model Tests', () {
    test('Task.fromJson() creates a valid instance', () {
      final json = {
        'id': 't1',
        'name': 'Task 1',
        'description': 'Description',
        'priority': 'HIGH',
        'status': 'COMPLETED',
        'projectId': 'p1'
      };

      final task = Task.fromJson(json);

      expect(task.id, 't1');
      expect(task.name, 'Task 1');
      expect(task.status, 'COMPLETED');
      expect(task.priority, 'HIGH');
    });

    test('Task.toJson() creates a valid map', () {
      final task = Task(
        id: 't2',
        name: 'Task 2',
        description: 'Test',
        priority: 'MEDIUM',
        status: 'PENDING',
        projectId: 'p1'
      );

      final json = task.toJson();

      expect(json['id'], 't2');
      expect(json['name'], 'Task 2');
      expect(json['status'], 'PENDING');
    });
  });
}
