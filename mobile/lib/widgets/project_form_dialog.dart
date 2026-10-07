import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/project.dart';
import 'package:mobile/providers/project_provider.dart';

class ProjectFormDialog extends ConsumerStatefulWidget {
  final Project? project;

  const ProjectFormDialog({super.key, this.project});

  @override
  ConsumerState<ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends ConsumerState<ProjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late String _status;

  @override
  void initState() {
    super.initState();
    _name = widget.project?.name ?? '';
    _description = widget.project?.description ?? '';
    _status = widget.project?.status ?? 'NOT_STARTED';
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
            Text(widget.project == null ? 'New Project' : 'Edit Project', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: 'NOT_STARTED', child: Text('Not Started')),
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
                    'status': _status,
                  };
                  if (widget.project == null) {
                    await ref.read(projectsProvider.notifier).createProject(data);
                  } else {
                    await ref.read(projectsProvider.notifier).updateProject(widget.project!.id, data);
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
