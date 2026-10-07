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

    if (_selectedProjectId == null && projects.isNotEmpty) {
      _selectedProjectId = projects.first.id;
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 12,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Grab Handle Bar
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.task == null ? Icons.add_task_rounded : Icons.edit_calendar_rounded,
                        color: const Color(0xFF0D9488),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.task == null ? 'Create New Task' : 'Edit Task Details',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                TextFormField(
                  initialValue: _name,
                  decoration: InputDecoration(
                    labelText: 'Task Title *',
                    hintText: 'e.g. Design User Interface',
                    prefixIcon: const Icon(Icons.check_box_outlined),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  onSaved: (val) => _name = val ?? '',
                  validator: (val) => val == null || val.trim().isEmpty ? 'Task title is required' : null,
                ),
                const SizedBox(height: 14),

                TextFormField(
                  initialValue: _description,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'Details about this task...',
                    prefixIcon: const Icon(Icons.subtitles_outlined),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  maxLines: 2,
                  onSaved: (val) => _description = val ?? '',
                ),
                const SizedBox(height: 14),

                if (projects.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: projects.any((p) => p.id == _selectedProjectId) ? _selectedProjectId : projects.first.id,
                    decoration: InputDecoration(
                      labelText: 'Assign to Project *',
                      prefixIcon: const Icon(Icons.folder_open_rounded),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
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
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.amber),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No projects available. Please create a project first before adding tasks.',
                            style: TextStyle(color: Colors.brown, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _priority,
                        decoration: InputDecoration(
                          labelText: 'Priority',
                          prefixIcon: const Icon(Icons.priority_high_rounded),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
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
                        decoration: InputDecoration(
                          labelText: 'Status',
                          prefixIcon: const Icon(Icons.timelapse_rounded),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
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
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
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
                                      backgroundColor: Colors.redAccent,
                                      behavior: SnackBarBehavior.floating,
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
                        : Text(
                            widget.task == null ? 'Create Task' : 'Update Task',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
