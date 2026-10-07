import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/task.dart';
import 'package:mobile/services/task_service.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/providers/auth_provider.dart';

final taskServiceProvider = Provider<TaskService>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return TaskService(apiService);
});

class TasksState {
  final List<Task> tasks;
  final bool isLoading;
  final String? error;
  final int page;
  final bool hasMore;

  TasksState({
    this.tasks = const [],
    this.isLoading = false,
    this.error,
    this.page = 1,
    this.hasMore = true,
  });

  TasksState copyWith({
    List<Task>? tasks,
    bool? isLoading,
    String? error,
    int? page,
    bool? hasMore,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class TasksNotifier extends StateNotifier<TasksState> {
  final TaskService _service;
  String _search = '';
  String _status = 'All';
  String _priority = 'All';
  String _projectId = '';

  TasksNotifier(this._service) : super(TasksState()) {
    fetchTasks();
  }

  void setSearch(String search) {
    _search = search;
    refresh();
  }

  void setStatus(String status) {
    _status = status;
    refresh();
  }

  void setPriority(String priority) {
    _priority = priority;
    refresh();
  }

  void setProjectId(String projectId) {
    _projectId = projectId;
    refresh();
  }

  Future<void> fetchTasks({bool loadMore = false}) async {
    if (state.isLoading || (!state.hasMore && loadMore)) return;

    final page = loadMore ? state.page + 1 : 1;

    if (!loadMore) {
      state = state.copyWith(isLoading: true, error: null, page: 1, hasMore: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final result = await _service.getTasks(
        page: page,
        search: _search,
        status: _status,
        priority: _priority,
        projectId: _projectId.isNotEmpty ? _projectId : null,
      );
      final newTasks = result['tasks'] as List<Task>;
      final pagination = result['pagination'];

      state = state.copyWith(
        tasks: loadMore ? [...state.tasks, ...newTasks] : newTasks,
        isLoading: false,
        page: page,
        hasMore: page < (pagination['totalPages'] ?? 1),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await fetchTasks(loadMore: false);
  }

  Future<void> toggleTaskStatus(Task task) async {
    final newStatus = task.status == 'COMPLETED' ? 'PENDING' : 'COMPLETED';
    try {
      final updatedTask = Task(
        id: task.id,
        name: task.name,
        description: task.description,
        priority: task.priority,
        status: newStatus,
        dueDate: task.dueDate,
        createdAt: task.createdAt,
        updatedAt: DateTime.now(),
        projectId: task.projectId,
        projectName: task.projectName,
      );
      
      state = state.copyWith(
        tasks: state.tasks.map((t) => t.id == task.id ? updatedTask : t).toList(),
      );
      
      await _service.updateTask(task.id, {'status': newStatus});
    } catch (e) {
      await refresh();
      rethrow;
    }
  }

  Future<void> createTask(Map<String, dynamic> data) async {
    try {
      final task = await _service.createTask(data);
      state = state.copyWith(tasks: [task, ...state.tasks]);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTask(String id, Map<String, dynamic> data) async {
    try {
      final task = await _service.updateTask(id, data);
      state = state.copyWith(
        tasks: state.tasks.map((t) => t.id == id ? task : t).toList(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _service.deleteTask(id);
      state = state.copyWith(
        tasks: state.tasks.where((t) => t.id != id).toList(),
      );
    } catch (e) {
      rethrow;
    }
  }
}

final tasksProvider = StateNotifierProvider<TasksNotifier, TasksState>((ref) {
  final service = ref.watch(taskServiceProvider);
  return TasksNotifier(service);
});
