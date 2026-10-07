import 'package:mobile/models/project.dart';
import 'package:mobile/services/api_service.dart';

class ProjectService {
  final ApiService _apiService;

  ProjectService(this._apiService);

  Future<Map<String, dynamic>> getProjects({
    int page = 1,
    int limit = 10,
    String? search,
    String? status,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (status != null && status.isNotEmpty && status != 'All') {
      queryParams['status'] = status;
    }

    final response = await _apiService.get('/projects', queryParameters: queryParams);
    
    final List<dynamic> data = response['data'] ?? [];
    final projects = data.map((json) => Project.fromJson(json)).toList();
    
    return {
      'projects': projects,
      'pagination': response['pagination'] ?? {
        'page': page,
        'limit': limit,
        'totalCount': projects.length,
        'totalPages': 1,
      },
    };
  }

  Future<Project> getProjectById(String id) async {
    final response = await _apiService.get('/projects/$id');
    return Project.fromJson(response['data']);
  }

  Future<Project> createProject(Map<String, dynamic> data) async {
    final response = await _apiService.post('/projects', data: data);
    return Project.fromJson(response['data']);
  }

  Future<Project> updateProject(String id, Map<String, dynamic> data) async {
    final response = await _apiService.put('/projects/$id', data: data);
    return Project.fromJson(response['data']);
  }

  Future<void> deleteProject(String id) async {
    await _apiService.delete('/projects/$id');
  }
}
