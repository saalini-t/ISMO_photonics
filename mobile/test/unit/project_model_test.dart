import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/project.dart';

void main() {
  group('Project Model Tests', () {
    test('Project.fromJson() creates a valid instance', () {
      final json = {
        'id': 'p1',
        'name': 'Project 1',
        'description': 'A test project'
      };

      final project = Project.fromJson(json);

      expect(project.id, 'p1');
      expect(project.name, 'Project 1');
      expect(project.description, 'A test project');
    });

    test('Project.toJson() creates a valid map', () {
      final project = Project(
        id: 'p2',
        name: 'Project 2',
        description: 'Another test project',
        status: 'IN_PROGRESS',
      );

      final json = project.toJson();

      expect(json['id'], 'p2');
      expect(json['name'], 'Project 2');
      expect(json['description'], 'Another test project');
    });
  });
}
