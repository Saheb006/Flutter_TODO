import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                                color: todo.completed ? Colors.green : Colors.grey,
                                width: 2,
                              ),
                              color: todo.completed ? Colors.green : Colors.transparent,
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
              Text(
                'Subtasks (${todo.completedSubTodos}/${todo.subTodos.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...todo.subTodos.map((subTodo) => Card(
                child: ListTile(
                  leading: Icon(
                    subTodo.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: subTodo.completed ? Colors.green : Colors.grey,
                  ),
                  title: Text(
                    subTodo.title,
                    style: TextStyle(
                      decoration: subTodo.completed ? TextDecoration.lineThrough : null,
                    ),
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
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }
}
