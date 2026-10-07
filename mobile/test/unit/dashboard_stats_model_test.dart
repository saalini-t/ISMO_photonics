import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/dashboard_stats.dart';

void main() {
  group('DashboardStats Model Tests', () {
    test('DashboardStats.fromJson() creates a valid instance', () {
      final json = {
        'totalProjects': 10,
        'totalTasks': 50,
        'completedTasks': 35
      };

      final stats = DashboardStats.fromJson(json);

      expect(stats.totalProjects, 10);
      expect(stats.totalTasks, 50);
      expect(stats.completedTasks, 35);
    });
  });
}
