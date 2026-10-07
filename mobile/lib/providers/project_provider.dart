import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/project.dart';
import 'package:mobile/services/project_service.dart';
import 'package:mobile/services/api_service.dart';

final projectServiceProvider = Provider<ProjectService>((ref) {
  final apiService = ApiService();
  return ProjectService(apiService);
});

class ProjectsState {
  final List<Project> projects;
  final bool isLoading;
  final String? error;
  final int page;
  final bool hasMore;

  ProjectsState({
    this.projects = const [],
    this.isLoading = false,
    this.error,
    this.page = 1,
    this.hasMore = true,
  });

  ProjectsState copyWith({
    List<Project>? projects,
    bool? isLoading,
    String? error,
    int? page,
    bool? hasMore,
  }) {
    return ProjectsState(
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class ProjectsNotifier extends StateNotifier<ProjectsState> {
  final ProjectService _service;
  String _search = '';
  String _status = 'All';

  ProjectsNotifier(this._service) : super(ProjectsState()) {
    fetchProjects();
  }

  void setSearch(String search) {
    _search = search;
    refresh();
  }

  void setStatus(String status) {
    _status = status;
    refresh();
  }

  Future<void> fetchProjects({bool loadMore = false}) async {
    if (state.isLoading || (!state.hasMore && loadMore)) return;

    final page = loadMore ? state.page + 1 : 1;

    if (!loadMore) {
      state = state.copyWith(isLoading: true, error: null, page: 1, hasMore: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final result = await _service.getProjects(
        page: page,
        search: _search,
        status: _status,
      );
      final newProjects = result['projects'] as List<Project>;
      final pagination = result['pagination'];

      state = state.copyWith(
        projects: loadMore ? [...state.projects, ...newProjects] : newProjects,
        isLoading: false,
        page: page,
        hasMore: page < (pagination['totalPages'] ?? 1),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await fetchProjects(loadMore: false);
  }

  Future<void> createProject(Map<String, dynamic> data) async {
    try {
      final project = await _service.createProject(data);
      state = state.copyWith(projects: [project, ...state.projects]);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProject(String id, Map<String, dynamic> data) async {
    try {
      final project = await _service.updateProject(id, data);
      state = state.copyWith(
        projects: state.projects.map((p) => p.id == id ? project : p).toList(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProject(String id) async {
    try {
      await _service.deleteProject(id);
      state = state.copyWith(
        projects: state.projects.where((p) => p.id != id).toList(),
      );
    } catch (e) {
      rethrow;
    }
  }
}

final projectsProvider = StateNotifierProvider<ProjectsNotifier, ProjectsState>((ref) {
  final service = ref.watch(projectServiceProvider);
  return ProjectsNotifier(service);
});
