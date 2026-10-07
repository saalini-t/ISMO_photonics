import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/dashboard_stats.dart';
import 'package:mobile/services/dashboard_service.dart';
import 'package:mobile/providers/auth_provider.dart';

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  final apiService = ref.watch(apiServiceProvider); 
  return DashboardService(apiService);
});

final dashboardProvider = FutureProvider.autoDispose<DashboardStats>((ref) async {
  final service = ref.watch(dashboardServiceProvider);
  return await service.getDashboardStats();
});
