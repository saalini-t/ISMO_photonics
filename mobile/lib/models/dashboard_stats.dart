class DashboardStats {
  final int totalProjects;
  final int projectsInProgress;
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int tasksInProgress;

  DashboardStats({
    required this.totalProjects,
    required this.projectsInProgress,
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.tasksInProgress,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalProjects: json['totalProjects'] ?? 0,
      projectsInProgress: json['projectsInProgress'] ?? 0,
      totalTasks: json['totalTasks'] ?? 0,
      completedTasks: json['completedTasks'] ?? 0,
      pendingTasks: json['pendingTasks'] ?? 0,
      tasksInProgress: json['tasksInProgress'] ?? 0,
    );
  }
}
