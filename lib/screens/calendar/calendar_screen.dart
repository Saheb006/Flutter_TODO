import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/todo.dart';
import '../../providers/todo_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<dynamic> _selectedTasks = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
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

  int _getPriorityOrder(Priority priority) {
    switch (priority) {
      case Priority.urgent:
        return 4;
      case Priority.high:
        return 3;
      case Priority.medium:
        return 2;
      case Priority.low:
        return 1;
    }
  }

  // Build a mixed list of main todos and subtasks scheduled for a day
  List<dynamic> _getTasksForDay(DateTime day, List<Todo> todos) {
    final List<dynamic> dayTasks = [];

    for (final todo in todos) {
      if (todo.dueDate != null && isSameDay(todo.dueDate!, day)) {
        dayTasks.add({
          'type': 'todo',
          'todo': todo,
        });
      }
      for (final sub in todo.subTodos) {
        if (sub.dueDate != null && isSameDay(sub.dueDate!, day)) {
          dayTasks.add({
            'type': 'subtask',
            'subtask': sub,
            'parent': todo,
          });
        }
      }
    }
    return dayTasks;
  }

  // Keep TableCalendar eventLoader as todos (it doesn't need subtasks),
  // since we compute markers separately below.
  List<Todo> _getTodosForDay(DateTime day, List<Todo> todos) {
    return todos.where((t) => t.dueDate != null && isSameDay(t.dueDate!, day)).toList();
  }

  // Collect priorities for a day from both todos and subtasks (subtasks inherit parent priority)
  List<Priority> _getPrioritiesForDay(DateTime day, List<Todo> todos) {
    final Set<Priority> set = {};
    for (final todo in todos) {
      if (todo.dueDate != null && isSameDay(todo.dueDate!, day) && !todo.completed) {
        set.add(todo.priority);
      }
      for (final sub in todo.subTodos) {
        if (sub.dueDate != null && isSameDay(sub.dueDate!, day) && !sub.completed) {
          set.add(todo.priority);
        }
      }
    }
    final list = set.toList();
    list.sort((a, b) => _getPriorityOrder(b) - _getPriorityOrder(a));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final todosAsync = ref.watch(todosProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return todosAsync.when(
      data: (todos) {
        _selectedTasks = _selectedDay != null ? _getTasksForDay(_selectedDay!, todos) : [];

        return Column(
          children: [
            // Calendar
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TableCalendar<Todo>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
                eventLoader: (d) => _getTodosForDay(d, todos),
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  weekendTextStyle: TextStyle(color: isDark ? Colors.red[300] : Colors.red),
                  holidayTextStyle: TextStyle(color: isDark ? Colors.red[300] : Colors.red),
                  defaultTextStyle: TextStyle(color: isDark ? Colors.white : Colors.black),
                  selectedDecoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                  todayDecoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.6), shape: BoxShape.circle),
                  markerDecoration: const BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
                  markersMaxCount: 4,
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    final priorities = _getPrioritiesForDay(day, todos);
                    if (priorities.isEmpty) return null;
                    return Positioned(
                      bottom: 2,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: priorities.take(4).map((p) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(color: _getPriorityColor(p), shape: BoxShape.circle),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                  leftChevronIcon: Icon(Icons.chevron_left, color: isDark ? Colors.white : Colors.black),
                  rightChevronIcon: Icon(Icons.chevron_right, color: isDark ? Colors.white : Colors.black),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                  weekendStyle: TextStyle(color: isDark ? Colors.red[300] : Colors.red),
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) => _focusedDay = focusedDay,
              ),
            ),

            // Day task list (todos + subtasks)
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedDay != null
                          ? 'Tasks for ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}'
                          : 'Select a day to view tasks',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (_selectedTasks.isEmpty)
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.event_available, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 12),
                              Text('No tasks scheduled for this day',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(color: Colors.grey[600]),
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          itemCount: _selectedTasks.length,
                          itemBuilder: (context, index) {
                            final task = _selectedTasks[index] as Map<String, dynamic>;
                            if (task['type'] == 'todo') {
                              final todo = task['todo'] as Todo;
                              final pc = _getPriorityColor(todo.priority);
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                elevation: 2,
                                child: ListTile(
                                  leading: Container(
                                    width: 4,
                                    height: double.infinity,
                                    decoration: BoxDecoration(color: pc, borderRadius: BorderRadius.circular(2)),
                                  ),
                                  title: Text(
                                    todo.title,
                                    style: TextStyle(
                                      decoration: todo.completed ? TextDecoration.lineThrough : null,
                                      color: todo.completed ? Colors.grey : null,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (todo.description != null)
                                        Text(
                                          todo.description!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: isDark ? Colors.white70 : Colors.grey[600]),
                                        ),
                                      if (todo.dueTime != null)
                                        Text('Due: ${todo.dueTime}',
                                            style: TextStyle(color: pc, fontSize: 12, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: pc.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: pc.withOpacity(0.25)),
                                    ),
                                    child: Text(
                                      'MAIN',
                                      style: TextStyle(
                                        color: pc,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              final sub = task['subtask'] as SubTodo;
                              final parent = task['parent'] as Todo;
                              final pc = _getPriorityColor(parent.priority);
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                elevation: 1,
                                color: isDark ? Colors.grey[850] : Colors.grey[50],
                                child: ListTile(
                                  leading: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 3,
                                        height: double.infinity,
                                        decoration: BoxDecoration(color: pc.withOpacity(0.6), borderRadius: BorderRadius.circular(2)),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(Icons.subdirectory_arrow_right, size: 16, color: pc),
                                    ],
                                  ),
                                  title: Text(
                                    sub.title,
                                    style: TextStyle(
                                      decoration: sub.completed ? TextDecoration.lineThrough : null,
                                      color: sub.completed ? Colors.grey : null,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('From: ${parent.title}',
                                          style: TextStyle(color: isDark ? Colors.white60 : Colors.grey[500], fontSize: 11)),
                                      if (sub.dueTime != null)
                                        Text('Due: ${sub.dueTime}',
                                            style: TextStyle(color: pc, fontSize: 12, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Upcoming reminders (todos + subtasks)
            Container(
              height: 160,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[50],
                border: Border(top: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Upcoming Reminders',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(child: _buildUpcomingReminders(todos, isDark)),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading todos: $e')),
    );
  }

  Widget _buildUpcomingReminders(List<Todo> todos, bool isDark) {
    final now = DateTime.now();
    final List<Map<String, dynamic>> items = [];

    for (final todo in todos) {
      if (todo.dueDate != null && !todo.completed && todo.dueDate!.isAfter(now.subtract(const Duration(days: 1)))) {
        items.add({
          'type': 'todo',
          'priority': todo.priority,
          'dueDate': todo.dueDate!,
          'dueTime': todo.dueTime,
          'title': todo.title,
          'subtitle': todo.description,
        });
      }
      for (final sub in todo.subTodos) {
        if (sub.dueDate != null && !sub.completed && sub.dueDate!.isAfter(now.subtract(const Duration(days: 1)))) {
          items.add({
            'type': 'subtask',
            'priority': todo.priority, // inherit parent priority
            'dueDate': sub.dueDate!,
            'dueTime': sub.dueTime,
            'title': sub.title,
            'subtitle': 'From: ${todo.title}',
          });
        }
      }
    }

    // Sort: date -> priority -> time
    items.sort((a, b) {
      final dc = (a['dueDate'] as DateTime).compareTo(b['dueDate'] as DateTime);
      if (dc != 0) return dc;
      final pc = _getPriorityOrder(b['priority'] as Priority) - _getPriorityOrder(a['priority'] as Priority);
      if (pc != 0) return pc;
      final ta = a['dueTime'] as String?;
      final tb = b['dueTime'] as String?;
      if (ta != null && tb != null) return ta.compareTo(tb);
      if (ta != null) return -1;
      if (tb != null) return 1;
      return 0;
    });

    if (items.isEmpty) {
      return Center(child: Text('No upcoming reminders', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])));
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: items.length.clamp(0, 10),
      itemBuilder: (context, index) {
        final it = items[index];
        final priority = it['priority'] as Priority;
        final pc = _getPriorityColor(priority);
        final dueDate = it['dueDate'] as DateTime;
        final dueTime = it['dueTime'] as String?;
        final days = dueDate.difference(now).inDays;

        String dueText;
        Color dueColor;
        if (days < 0) {
          dueText = 'Overdue';
          dueColor = Colors.red;
        } else if (days == 0) {
          dueText = 'Due today';
          dueColor = Colors.red;
        } else if (days == 1) {
          dueText = 'Due tomorrow';
          dueColor = Colors.orange;
        } else if (days <= 7) {
          dueText = 'Due in $days days';
          dueColor = Colors.amber[700]!;
        } else {
          dueText = 'Due ${dueDate.day}/${dueDate.month}';
          dueColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
        }

        return Container(
          width: 200,
          margin: const EdgeInsets.only(right: 12),
          child: Card(
            elevation: 3,
            color: isDark ? Colors.grey[800] : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: pc, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: pc.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: pc.withOpacity(0.3)),
                        ),
                        child: Text(
                          it['type'] == 'todo' ? priority.name.toUpperCase() : 'SUBTASK',
                          style: TextStyle(color: pc, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    it['title'] as String,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white : Colors.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // subtitle removed to reduce height and avoid overflow
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 12, color: dueColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          dueText,
                          style: TextStyle(color: dueColor, fontSize: 10, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (dueTime != null)
                    Text('at $dueTime', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 8)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}