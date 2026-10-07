import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/dashboard_stats.dart';
import 'package:mobile/providers/dashboard_provider.dart';
import 'package:mobile/screens/dashboard_screen.dart';

void main() {
  testWidgets('DashboardScreen renders statistics cards correctly', (WidgetTester tester) async {
    final stats = DashboardStats(
      totalProjects: 5,
      projectsInProgress: 2,
      totalTasks: 20,
      completedTasks: 15,
      pendingTasks: 3,
      tasksInProgress: 2,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardProvider.overrideWith((ref) => stats),
        ],
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );

    // Verify AppBar title
    expect(find.text('Dashboard'), findsOneWidget);

    // Verify statistics text
    expect(find.text('Total Projects'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Total Tasks'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
    expect(find.text('Completed Tasks'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
  });
}
