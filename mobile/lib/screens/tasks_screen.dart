import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/task_provider.dart';
import 'package:mobile/widgets/task_form_dialog.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tasksProvider);
    final notifier = ref.read(tasksProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search tasks...',
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
                  children: [
                    DropdownButton<String>(
                      value: 'All', // Update dynamically in real app based on state
                      items: ['All', 'PENDING', 'IN_PROGRESS', 'COMPLETED'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) => notifier.setStatus(val!),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: 'All',
                      items: ['All', 'LOW', 'MEDIUM', 'HIGH'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) => notifier.setPriority(val!),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: notifier.refresh,
        child: state.isLoading && state.tasks.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: state.tasks.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.tasks.length) {
                    notifier.fetchTasks(loadMore: true);
                    return const Center(child: CircularProgressIndicator());
                  }
                  final task = state.tasks[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Checkbox(
                        value: task.status == 'COMPLETED',
                        onChanged: (val) => notifier.toggleTaskStatus(task),
                      ),
                      title: Text(task.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Priority: ${task.priority} | Project: ${task.projectName ?? 'N/A'}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) => TaskFormDialog(task: task),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => notifier.deleteTask(task.id),
                          ),
                        ],
                      ),
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
            builder: (_) => const TaskFormDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
