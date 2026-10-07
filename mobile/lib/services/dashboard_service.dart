import 'package:mobile/models/dashboard_stats.dart';
import 'package:mobile/services/api_service.dart';

class DashboardService {
  final ApiService _apiService;

  DashboardService(this._apiService);

  Future<DashboardStats> getDashboardStats() async {
    final response = await _apiService.get('/dashboard');
    final data = response['data'] as Map<String, dynamic>? ?? response;
    return DashboardStats.fromJson(data);
  }
}
