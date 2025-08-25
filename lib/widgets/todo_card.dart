import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:ui';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../screens/todo/todo_detail_screen.dart';

class TodoCard extends ConsumerWidget {
  final Todo todo;

  const TodoCard({super.key, required this.todo});

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.urgent:
        return Colors.red;
      case Priority.high:
        return Colors.orange;
      case Priority.medium:
        return Colors.blue;
      case Priority.low:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final priorityColor = _getPriorityColor(todo.priority);

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _deleteTodo(context, ref),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: theme.brightness == Brightness.dark
                ? [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0.05),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.9),
                    Colors.white.withValues(alpha: 0.7),
                  ],
          ),
          border: Border.all(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.brightness == Brightness.dark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: InkWell(
              onTap: () => _navigateToDetail(context),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _toggleComplete(ref),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: todo.completed ? priorityColor : Colors.grey,
                                width: 2,
                              ),
                              color: todo.completed ? priorityColor : Colors.transparent,
                            ),
                            child: todo.completed
                                ? const Icon(Icons.check, size: 16, color: Colors.white)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            todo.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              decoration: todo.completed ? TextDecoration.lineThrough : null,
                              color: todo.completed ? Colors.grey : null,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: priorityColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: priorityColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            todo.priority.name.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: priorityColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (todo.description != null && todo.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        todo.description!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.brightness == Brightness.dark 
                              ? Colors.white70 
                              : Colors.grey[600],
                          decoration: todo.completed ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (todo.subTodos.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.checklist, 
                            size: 16, 
                            color: theme.brightness == Brightness.dark 
                                ? Colors.white70 
                                : Colors.grey[600]
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${todo.completedSubTodos}/${todo.subTodos.length} subtasks',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.brightness == Brightness.dark 
                                  ? Colors.white70 
                                  : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: todo.progress,
                              backgroundColor: theme.brightness == Brightness.dark 
                                  ? Colors.white24 
                                  : Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(priorityColor),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (todo.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        children: todo.tags.take(3).map((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.dark 
                                ? Colors.white.withValues(alpha: 0.1) 
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.brightness == Brightness.dark 
                                  ? Colors.white.withValues(alpha: 0.2) 
                                  : Colors.grey.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            tag,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.brightness == Brightness.dark 
                                  ? Colors.white70 
                                  : Colors.grey[700],
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                    if (todo.dueDate != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: _getDueDateColor(todo.dueDate!),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDueDate(todo.dueDate!),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _getDueDateColor(todo.dueDate!),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleComplete(WidgetRef ref) {
    ref.read(todosProvider.notifier).toggleTodoComplete(todo.id);
  }

  void _deleteTodo(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Todo'),
        content: Text('Are you sure you want to delete "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(todosProvider.notifier).deleteTodo(todo.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TodoDetailScreen(todoId: todo.id),
      ),
    );
  }

  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    
    if (difference < 0) return Colors.red;
    if (difference == 0) return Colors.orange;
    if (difference <= 3) return Colors.amber;
    return Colors.grey;
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    
    if (difference < 0) return 'Overdue';
    if (difference == 0) return 'Due today';
    if (difference == 1) return 'Due tomorrow';
    if (difference <= 7) return 'Due in $difference days';
    
    return '${dueDate.day}/${dueDate.month}/${dueDate.year}';
  }
}