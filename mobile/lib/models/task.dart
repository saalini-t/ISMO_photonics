class Task {
  final String id;
  final String name;
  final String description;
  final String priority;
  final String status;
  final DateTime? dueDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String projectId;
  final String? projectName;

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.priority,
    required this.status,
    this.dueDate,
    this.createdAt,
    this.updatedAt,
    required this.projectId,
    this.projectName,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'LOW',
      status: json['status'] ?? 'PENDING',
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      projectId: json['projectId'] ?? '',
      projectName: json['projectName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'priority': priority,
      'status': status,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'projectId': projectId,
      'projectName': projectName,
    };
  }
}
