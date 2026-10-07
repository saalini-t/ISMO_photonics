import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/task.dart';
import 'package:mobile/providers/project_provider.dart';
import 'package:mobile/providers/task_provider.dart';
import 'package:mobile/services/api_service.dart';

class TaskFormDialog extends ConsumerStatefulWidget {
  final Task? task;
  final String? projectId;

  const TaskFormDialog({super.key, this.task, this.projectId});

  @override
  ConsumerState<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends ConsumerState<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late String _priority;
  late String _status;
  String? _selectedProjectId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _name = widget.task?.name ?? '';
    _description = widget.task?.description ?? '';
    _priority = widget.task?.priority ?? 'MEDIUM';
    _status = widget.task?.status ?? 'PENDING';
    _selectedProjectId = widget.task?.projectId ?? widget.projectId;
  }

  @override
  Widget build(BuildContext context) {
    final projectsState = ref.watch(projectsProvider);
    final projects = projectsState.projects;

    // Auto-select first project if none selected and projects exist
    if (_selectedProjectId == null && projects.isNotEmpty) {
      _selectedProjectId = projects.first.id;
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.task == null ? 'New Task' : 'Edit Task',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _name,
              decoration: const InputDecoration(
                labelText: 'Task Name *',
                border: OutlineInputBorder(),
              ),
              onSaved: (val) => _name = val ?? '',
              validator: (val) => val == null || val.trim().isEmpty ? 'Task name is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _description,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onSaved: (val) => _description = val ?? '',
            ),
            const SizedBox(height: 12),
            if (projects.isNotEmpty)
              DropdownButtonFormField<String>(
                value: projects.any((p) => p.id == _selectedProjectId) ? _selectedProjectId : projects.first.id,
                decoration: const InputDecoration(
                  labelText: 'Select Project *',
                  border: OutlineInputBorder(),
                ),
                items: projects.map((p) {
                  return DropdownMenuItem(
                    value: p.id,
                    child: Text(p.name, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedProjectId = val);
                },
                validator: (val) => val == null || val.isEmpty ? 'Project is required' : null,
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'No projects found. Please create a project first before adding tasks.',
                  style: TextStyle(color: Colors.brown, fontWeight: FontWeight.w600),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _priority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'LOW', child: Text('Low')),
                      DropdownMenuItem(value: 'MEDIUM', child: Text('Medium')),
                      DropdownMenuItem(value: 'HIGH', child: Text('High')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _priority = val);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'PENDING', child: Text('Pending')),
                      DropdownMenuItem(value: 'IN_PROGRESS', child: Text('In Progress')),
                      DropdownMenuItem(value: 'COMPLETED', child: Text('Completed')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _status = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: (_isSubmitting || (widget.task == null && _selectedProjectId == null))
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        setState(() => _isSubmitting = true);

                        final data = <String, dynamic>{
                          'name': _name.trim(),
                          'priority': _priority,
                          'status': _status,
                        };

                        if (_description.trim().isNotEmpty) {
                          data['description'] = _description.trim();
                        }

                        if (_selectedProjectId != null && _selectedProjectId!.isNotEmpty) {
                          data['projectId'] = _selectedProjectId;
                        }

                        try {
                          if (widget.task == null) {
                            await ref.read(tasksProvider.notifier).createTask(data);
                          } else {
                            await ref.read(tasksProvider.notifier).updateTask(widget.task!.id, data);
                          }
                          if (context.mounted) Navigator.pop(context);
                        } catch (e) {
                          final errorMessage = e is ApiException ? e.message : e.toString();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $errorMessage'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isSubmitting = false);
                        }
                      }
                    },
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save Task'),
            ),
          ],
        ),
      ),
    );
  }
}
