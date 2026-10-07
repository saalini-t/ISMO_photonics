import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/project_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/widgets/project_form_dialog.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(projectsProvider);
    final notifier = ref.read(projectsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search projects...',
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (val) => notifier.setSearch(val),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: ['All', 'NOT_STARTED', 'IN_PROGRESS', 'COMPLETED'].map((status) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ActionChip(
                        label: Text(status.replaceAll('_', ' ')),
                        onPressed: () => notifier.setStatus(status),
                      ),
                    );
                  }).toList(),
                ),
              )
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: notifier.refresh,
        child: state.isLoading && state.projects.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: state.projects.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.projects.length) {
                    notifier.fetchProjects(loadMore: true);
                    return const Center(child: CircularProgressIndicator());
                  }
                  final project = state.projects[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(project.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(project.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text('Tasks: ${project.taskCount} | Status: ${project.status}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) => ProjectFormDialog(project: project),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => notifier.deleteProject(project.id),
                          ),
                        ],
                      ),
                      onTap: () => context.go('/projects/${project.id}'),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const ProjectFormDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
