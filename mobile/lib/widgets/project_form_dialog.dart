import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/project.dart';
import 'package:mobile/providers/project_provider.dart';
import 'package:mobile/services/api_service.dart';

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
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _name = widget.project?.name ?? '';
    _description = widget.project?.description ?? '';
    _status = widget.project?.status ?? 'NOT_STARTED';
  }

  @override
  Widget build(BuildContext context) {
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
                // Top Grab Handle Bar
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
                        color: const Color(0xFF4F46E5).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.project == null ? Icons.create_new_folder_rounded : Icons.edit_note_rounded,
                        color: const Color(0xFF4F46E5),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.project == null ? 'Create New Project' : 'Edit Project Details',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                TextFormField(
                  initialValue: _name,
                  decoration: InputDecoration(
                    labelText: 'Project Name *',
                    hintText: 'e.g. Website Redesign',
                    prefixIcon: const Icon(Icons.folder_outlined),
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
                  validator: (val) => val == null || val.trim().isEmpty ? 'Project name is required' : null,
                ),
                const SizedBox(height: 14),

                TextFormField(
                  initialValue: _description,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'Brief summary of the project goals...',
                    prefixIcon: const Icon(Icons.notes_rounded),
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
                  maxLines: 3,
                  onSaved: (val) => _description = val ?? '',
                ),
                const SizedBox(height: 14),

                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: InputDecoration(
                    labelText: 'Project Status',
                    prefixIcon: const Icon(Icons.flag_outlined),
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
                    DropdownMenuItem(value: 'NOT_STARTED', child: Text('Not Started')),
                    DropdownMenuItem(value: 'IN_PROGRESS', child: Text('In Progress')),
                    DropdownMenuItem(value: 'COMPLETED', child: Text('Completed')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _status = val);
                  },
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              setState(() => _isSubmitting = true);

                              final data = <String, dynamic>{
                                'name': _name.trim(),
                                'status': _status,
                              };

                              if (_description.trim().isNotEmpty) {
                                data['description'] = _description.trim();
                              }

                              try {
                                if (widget.project == null) {
                                  await ref.read(projectsProvider.notifier).createProject(data);
                                } else {
                                  await ref.read(projectsProvider.notifier).updateProject(widget.project!.id, data);
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
                            widget.project == null ? 'Create Project' : 'Update Project',
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
