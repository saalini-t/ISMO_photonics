import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/project_provider.dart';
import 'package:mobile/providers/task_provider.dart';
import 'package:mobile/widgets/task_form_dialog.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final String id;

  const ProjectDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(projectsProvider);
    final project = state.projects.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('Project not found'),
    );

    final tasksState = ref.watch(tasksProvider);
    final taskNotifier = ref.read(tasksProvider.notifier);
    
    // Note: We might want to filter tasks by project id locally or trigger a fetch for this specific project.
    // Assuming tasks provider is generic, let's filter locally for demonstration, or we should fetch:
    // Ideally, when opening this screen, we'd do taskNotifier.setProjectId(id).
    
    final projectTasks = tasksState.tasks.where((t) => t.projectId == id).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              ref.read(projectsProvider.notifier).deleteProject(id);
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.description, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Chip(label: Text(project.status)),
                  ],
                ),
              ),
            ),
          ),
          const Divider(),
          const Text('Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: ListView.builder(
              itemCount: projectTasks.length,
              itemBuilder: (context, index) {
                final task = projectTasks[index];
                return ListTile(
                  leading: Checkbox(
                    value: task.status == 'COMPLETED',
                    onChanged: (val) => taskNotifier.toggleTaskStatus(task),
                  ),
                  title: Text(task.name),
                  subtitle: Text(task.status),
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => TaskFormDialog(projectId: id),
          );
        },
        child: const Icon(Icons.add_task),
      ),
    );
  }
}
