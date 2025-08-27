import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:ui';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../screens/todo/todo_detail_screen.dart';

class TodoCard extends ConsumerStatefulWidget {
  final Todo todo;

  const TodoCard({super.key, required this.todo});

  @override
  ConsumerState<TodoCard> createState() => _TodoCardState();
}

class _TodoCardState extends ConsumerState<TodoCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priorityColor = _getPriorityColor(widget.todo.priority);
    final isDark = theme.brightness == Brightness.dark;

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
            colors: isDark
                ? [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ]
                : [
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0.7),
                  ],
          ),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              children: [
                InkWell(
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
                                    color: widget.todo.completed ? priorityColor : Colors.grey,
                                    width: 2,
                                  ),
                                  color: widget.todo.completed ? priorityColor : Colors.transparent,
                                ),
                                child: widget.todo.completed
                                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.todo.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  decoration: widget.todo.completed ? TextDecoration.lineThrough : null,
                                  color: widget.todo.completed ? Colors.grey : null,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: priorityColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: priorityColor.withOpacity(0.3)),
                              ),
                              child: Text(
                                widget.todo.priority.name.toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: priorityColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (widget.todo.subTodos.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _toggleExpanded,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: priorityColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: AnimatedRotation(
                                    turns: _isExpanded ? 0.5 : 0,
                                    duration: const Duration(milliseconds: 300),
                                    child: Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 20,
                                      color: priorityColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (widget.todo.description != null && widget.todo.description!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            widget.todo.description!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark 
                                  ? Colors.white70 
                                  : Colors.grey[600],
                              decoration: widget.todo.completed ? TextDecoration.lineThrough : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (widget.todo.subTodos.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.checklist, 
                                size: 16, 
                                color: isDark 
                                    ? Colors.white70 
                                    : Colors.grey[600]
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.todo.completedSubTodos}/${widget.todo.subTodos.length} subtasks',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark 
                                      ? Colors.white70 
                                      : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: widget.todo.progress,
                                  backgroundColor: isDark 
                                      ? Colors.white24 
                                      : Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(priorityColor),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (widget.todo.tags.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 4,
                            children: widget.todo.tags.take(3).map((tag) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark 
                                    ? Colors.white.withOpacity(0.1) 
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark 
                                      ? Colors.white.withOpacity(0.2) 
                                      : Colors.grey.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                tag,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isDark 
                                      ? Colors.white70 
                                      : Colors.grey[700],
                                ),
                              ),
                            )).toList(),
                          ),
                        ],
                        if (widget.todo.dueDate != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 16,
                                color: _getDueDateColor(widget.todo.dueDate!),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDueDate(widget.todo.dueDate!),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: _getDueDateColor(widget.todo.dueDate!),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (widget.todo.dueTime != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  'at ${widget.todo.dueTime}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: priorityColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Expandable Subtodos Section
                if (widget.todo.subTodos.isNotEmpty)
                  SizeTransition(
                    sizeFactor: _expandAnimation,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark 
                            ? Colors.black.withOpacity(0.2)
                            : Colors.grey[50],
                        border: Border(
                          top: BorderSide(
                            color: isDark 
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.2),
                          ),
                        ),
                      ),
                      child: Column(
                        children: widget.todo.subTodos.map((subTodo) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                const SizedBox(width: 20),
                                GestureDetector(
                                  onTap: () => ref
                                      .read(todosProvider.notifier)
                                      .toggleSubTodoComplete(widget.todo.id, subTodo.id),
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: subTodo.completed ? priorityColor : Colors.grey,
                                        width: 1.5,
                                      ),
                                      color: subTodo.completed ? priorityColor : Colors.transparent,
                                    ),
                                    child: subTodo.completed
                                        ? const Icon(Icons.check, size: 12, color: Colors.white)
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        subTodo.title,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          decoration: subTodo.completed ? TextDecoration.lineThrough : null,
                                          color: subTodo.completed 
                                              ? Colors.grey 
                                              : (isDark ? Colors.white : Colors.black),
                                        ),
                                      ),
                                      if (subTodo.dueDate != null || subTodo.dueTime != null)
                                        Text(
                                          '${subTodo.dueDate != null ? '${subTodo.dueDate!.day}/${subTodo.dueDate!.month}' : ''} ${subTodo.dueTime ?? ''}'.trim(),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: priorityColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
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

  void _toggleComplete(WidgetRef ref) {
    ref.read(todosProvider.notifier).toggleTodoComplete(widget.todo.id);
  }

  void _deleteTodo(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Todo'),
        content: Text('Are you sure you want to delete "${widget.todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(todosProvider.notifier).deleteTodo(widget.todo.id);
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
        builder: (_) => TodoDetailScreen(todoId: widget.todo.id),
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