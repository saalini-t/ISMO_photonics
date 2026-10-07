class Project {
  final String id;
  final String name;
  final String description;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int taskCount;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
    this.taskCount = 0,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    int parsedTaskCount = 0;
    if (json['taskCount'] != null) {
      parsedTaskCount = json['taskCount'] as int;
    } else if (json['_count'] != null && json['_count']['tasks'] != null) {
      parsedTaskCount = json['_count']['tasks'] as int;
    } else if (json['tasks'] != null && json['tasks'] is List) {
      parsedTaskCount = (json['tasks'] as List).length;
    }

    return Project(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'NOT_STARTED',
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      taskCount: parsedTaskCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'taskCount': taskCount,
      '_count': {'tasks': taskCount},
    };
  }
}
