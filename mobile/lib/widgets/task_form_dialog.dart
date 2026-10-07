import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/task.dart';
import 'package:mobile/providers/task_provider.dart';

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
  late String _projectId;

  @override
  void initState() {
    super.initState();
    _name = widget.task?.name ?? '';
    _description = widget.task?.description ?? '';
    _priority = widget.task?.priority ?? 'LOW';
    _status = widget.task?.status ?? 'PENDING';
    _projectId = widget.task?.projectId ?? widget.projectId ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.task == null ? 'New Task' : 'Edit Task', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextFormField(
              initialValue: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              onSaved: (val) => _name = val ?? '',
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              initialValue: _description,
              decoration: const InputDecoration(labelText: 'Description'),
              onSaved: (val) => _description = val ?? '',
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              initialValue: _projectId,
              decoration: const InputDecoration(labelText: 'Project ID'),
              onSaved: (val) => _projectId = val ?? '',
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            ),
            DropdownButtonFormField<String>(
              value: _priority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: const [
                DropdownMenuItem(value: 'LOW', child: Text('Low')),
                DropdownMenuItem(value: 'MEDIUM', child: Text('Medium')),
                DropdownMenuItem(value: 'HIGH', child: Text('High')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _priority = val);
              },
            ),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: 'PENDING', child: Text('Pending')),
                DropdownMenuItem(value: 'IN_PROGRESS', child: Text('In Progress')),
                DropdownMenuItem(value: 'COMPLETED', child: Text('Completed')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _status = val);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final data = {
                    'name': _name,
                    'description': _description,
                    'priority': _priority,
                    'status': _status,
                    'projectId': _projectId,
                  };
                  if (widget.task == null) {
                    await ref.read(tasksProvider.notifier).createTask(data);
                  } else {
                    await ref.read(tasksProvider.notifier).updateTask(widget.task!.id, data);
                  }
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
