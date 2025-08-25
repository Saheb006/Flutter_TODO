import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/todo.dart';
import '../../providers/todo_provider.dart';

class AddTodoScreen extends ConsumerStatefulWidget {
  final Todo? todo;

  const AddTodoScreen({super.key, this.todo});

  @override
  ConsumerState<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends ConsumerState<AddTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagController = TextEditingController();
  
  Priority _selectedPriority = Priority.medium;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  List<String> _tags = [];
  List<SubTodo> _subTodos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      _initializeWithTodo(widget.todo!);
    }
  }

  void _initializeWithTodo(Todo todo) {
    _titleController.text = todo.title;
    _descriptionController.text = todo.description ?? '';
    _selectedPriority = todo.priority;
    _dueDate = todo.dueDate;
    if (todo.dueTime != null) {
      final parts = todo.dueTime!.split(':');
      _dueTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    _tags = List.from(todo.tags);
    _subTodos = List.from(todo.subTodos);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final todo = Todo(
        id: widget.todo?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        completed: widget.todo?.completed ?? false,
        priority: _selectedPriority,
        dueDate: _dueDate,
        dueTime: _dueTime != null 
            ? '${_dueTime!.hour.toString().padLeft(2, '0')}:${_dueTime!.minute.toString().padLeft(2, '0')}'
            : null,
        subTodos: _subTodos,
        tags: _tags,
        createdAt: widget.todo?.createdAt ?? DateTime.now(),
        completedAt: widget.todo?.completedAt,
      );

      if (widget.todo == null) {
        await ref.read(todosProvider.notifier).addTodo(todo);
      } else {
        await ref.read(todosProvider.notifier).updateTodo(todo);
      }

      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving todo: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  void _addSubTodo() {
    showDialog(
      context: context,
      builder: (context) => _SubTodoDialog(
        onAdd: (title) {
          setState(() {
            _subTodos.add(SubTodo(
              id: const Uuid().v4(),
              title: title,
              completed: false,
              createdAt: DateTime.now(),
            ));
          });
        },
      ),
    );
  }

  void _removeSubTodo(int index) {
    setState(() => _subTodos.removeAt(index));
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _dueDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _dueTime = time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todo == null ? 'Add Todo' : 'Edit Todo'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTodo,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Priority>(
              initialValue: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: Priority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(priority.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (priority) {
                if (priority != null) {
                  setState(() => _selectedPriority = priority);
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_dueDate == null 
                        ? 'Set Due Date' 
                        : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(_dueTime == null 
                        ? 'Set Time' 
                        : _dueTime!.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      labelText: 'Add Tag',
                      border: OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addTag,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _tags.map((tag) => Chip(
                  label: Text(tag),
                  onDeleted: () => _removeTag(tag),
                )).toList(),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtasks',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: _addSubTodo,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Subtask'),
                ),
              ],
            ),
            ..._subTodos.asMap().entries.map((entry) {
              final index = entry.key;
              final subTodo = entry.value;
              return Card(
                child: ListTile(
                  title: Text(subTodo.title),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeSubTodo(index),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SubTodoDialog extends StatefulWidget {
  final Function(String) onAdd;

  const _SubTodoDialog({required this.onAdd});

  @override
  State<_SubTodoDialog> createState() => _SubTodoDialogState();
}

class _SubTodoDialogState extends State<_SubTodoDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Subtask'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Enter subtask title',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final title = _controller.text.trim();
            if (title.isNotEmpty) {
              widget.onAdd(title);
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
