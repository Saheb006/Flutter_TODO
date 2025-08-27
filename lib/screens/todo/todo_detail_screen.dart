import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/todo.dart';
import '../../providers/todo_provider.dart';
import 'add_todo_screen.dart';

class TodoDetailScreen extends ConsumerWidget {
  final String todoId;

  const TodoDetailScreen({super.key, required this.todoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todosProvider);
    
    return todosAsync.when(
      data: (todos) {
        final todo = todos.firstWhere((t) => t.id == todoId);
        return _TodoDetailView(todo: todo);
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _TodoDetailView extends ConsumerWidget {
  final Todo todo;

  const _TodoDetailView({required this.todo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddTodoScreen(todo: todo),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => ref.read(todosProvider.notifier).toggleTodoComplete(todo.id),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: todo.completed ? _getPriorityColor(todo.priority) : Colors.grey,
                                width: 2,
                              ),
                              color: todo.completed ? _getPriorityColor(todo.priority) : Colors.transparent,
                            ),
                            child: todo.completed
                                ? const Icon(Icons.check, size: 18, color: Colors.white)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            todo.title,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              decoration: todo.completed ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (todo.description != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        todo.description!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (todo.subTodos.isNotEmpty) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Subtasks (${todo.completedSubTodos}/${todo.subTodos.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: todo.progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getPriorityColor(todo.priority),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...todo.subTodos.map((subTodo) => Card(
                child: ListTile(
                  leading: GestureDetector(
                    onTap: () => ref.read(todosProvider.notifier).toggleSubTodoComplete(todo.id, subTodo.id),
                    child: Icon(
                      subTodo.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: subTodo.completed ? _getPriorityColor(todo.priority) : Colors.grey,
                    ),
                  ),
                  title: Text(
                    subTodo.title,
                    style: TextStyle(
                      decoration: subTodo.completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: subTodo.dueDate != null || subTodo.dueTime != null
                      ? Text(
                          '${subTodo.dueDate != null ? '${subTodo.dueDate!.day}/${subTodo.dueDate!.month}/${subTodo.dueDate!.year}' : ''} ${subTodo.dueTime ?? ''}'.trim(),
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        )
                      : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editSubTodo(context, ref, todo, subTodo),
                  ),
                ),
              )),
              const SizedBox(height: 16),
            ],
            if (todo.tags.isNotEmpty) ...[
              Text(
                'Tags',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: todo.tags.map((tag) => Chip(label: Text(tag))).toList(),
              ),
              const SizedBox(height: 16),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      icon: Icons.flag,
                      label: 'Priority',
                      value: todo.priority.name.toUpperCase(),
                      color: _getPriorityColor(todo.priority),
                    ),
                    if (todo.dueDate != null)
                      _DetailRow(
                        icon: Icons.calendar_today,
                        label: 'Due Date',
                        value: '${todo.dueDate!.day}/${todo.dueDate!.month}/${todo.dueDate!.year}',
                      ),
                    if (todo.dueTime != null)
                      _DetailRow(
                        icon: Icons.access_time,
                        label: 'Due Time',
                        value: todo.dueTime!,
                      ),
                    _DetailRow(
                      icon: Icons.calendar_month,
                      label: 'Created',
                      value: '${todo.createdAt.day}/${todo.createdAt.month}/${todo.createdAt.year}',
                    ),
                    if (todo.completedAt != null)
                      _DetailRow(
                        icon: Icons.check_circle,
                        label: 'Completed',
                        value: '${todo.completedAt!.day}/${todo.completedAt!.month}/${todo.completedAt!.year}',
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.urgent:
        return Colors.red;
      case Priority.high:
        return Colors.orange;
      case Priority.medium:
        return Colors.yellow[700]!;
      case Priority.low:
        return Colors.blue;
    }
  }

  void _editSubTodo(BuildContext context, WidgetRef ref, Todo todo, SubTodo subTodo) {
    showDialog(
      context: context,
      builder: (context) => _EditSubTodoDialog(
        subTodo: subTodo,
        onUpdate: (updatedSubTodo) {
          ref.read(todosProvider.notifier).updateSubTodo(todo.id, updatedSubTodo);
        },
      ),
    );
  }
}

class _EditSubTodoDialog extends StatefulWidget {
  final SubTodo subTodo;
  final Function(SubTodo) onUpdate;

  const _EditSubTodoDialog({
    required this.subTodo,
    required this.onUpdate,
  });

  @override
  State<_EditSubTodoDialog> createState() => _EditSubTodoDialogState();
}

class _EditSubTodoDialogState extends State<_EditSubTodoDialog> {
  late TextEditingController _titleController;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.subTodo.title);
    _dueDate = widget.subTodo.dueDate;
    if (widget.subTodo.dueTime != null) {
      final parts = widget.subTodo.dueTime!.split(':');
      _dueTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
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
    return AlertDialog(
      title: const Text('Edit Subtask'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
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
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final title = _titleController.text.trim();
            if (title.isNotEmpty) {
              final updatedSubTodo = widget.subTodo.copyWith(
                title: title,
                dueDate: _dueDate,
                dueTime: _dueTime != null 
                    ? '${_dueTime!.hour.toString().padLeft(2, '0')}:${_dueTime!.minute.toString().padLeft(2, '0')}'
                    : null,
              );
              widget.onUpdate(updatedSubTodo);
              Navigator.pop(context);
            }
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: color != null ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }
}