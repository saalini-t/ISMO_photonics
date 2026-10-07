import 'package:mobile/models/task.dart';
import 'package:mobile/services/api_service.dart';

class TaskService {
  final ApiService _apiService;

  TaskService(this._apiService);

  Future<Map<String, dynamic>> getTasks({
    int page = 1,
    int limit = 10,
    String? search,
    String? status,
    String? priority,
    String? projectId,
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
    if (priority != null && priority.isNotEmpty && priority != 'All') {
      queryParams['priority'] = priority;
    }
    if (projectId != null && projectId.isNotEmpty) {
      queryParams['projectId'] = projectId;
    }

    final response = await _apiService.get('/tasks', queryParameters: queryParams);
    
    final List<dynamic> data = response.data['data'] ?? [];
    final tasks = data.map((json) => Task.fromJson(json)).toList();
    
    return {
      'tasks': tasks,
      'pagination': response.data['pagination'] ?? {
        'page': page,
        'limit': limit,
        'totalCount': tasks.length,
        'totalPages': 1,
      },
    };
  }

  Future<Task> getTaskById(String id) async {
    final response = await _apiService.get('/tasks/$id');
    return Task.fromJson(response.data['data']);
  }

  Future<Task> createTask(Map<String, dynamic> data) async {
    final response = await _apiService.post('/tasks', data: data);
    return Task.fromJson(response.data['data']);
  }

  Future<Task> updateTask(String id, Map<String, dynamic> data) async {
    final response = await _apiService.put('/tasks/$id', data: data);
    return Task.fromJson(response.data['data']);
  }

  Future<void> deleteTask(String id) async {
    await _apiService.delete('/tasks/$id');
  }
}
