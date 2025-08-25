enum Priority { low, medium, high, urgent }

class SubTodo {
  final String id;
  final String title;
  final bool completed;
  final DateTime? dueDate;
  final String? dueTime;
  final DateTime createdAt;

  SubTodo({
    required this.id,
    required this.title,
    required this.completed,
    this.dueDate,
    this.dueTime,
    required this.createdAt,
  });

  factory SubTodo.fromJson(Map<String, dynamic> json) {
    return SubTodo(
      id: json['id'],
      title: json['title'],
      completed: json['completed'] ?? false,
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      dueTime: json['due_time'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'due_date': dueDate?.toIso8601String(),
      'due_time': dueTime,
      'created_at': createdAt.toIso8601String(),
    };
  }

  SubTodo copyWith({
    String? id,
    String? title,
    bool? completed,
    DateTime? dueDate,
    String? dueTime,
    DateTime? createdAt,
  }) {
    return SubTodo(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class Todo {
  final String id;
  final String title;
  final String? description;
  final bool completed;
  final Priority priority;
  final String? color;
  final DateTime? dueDate;
  final String? dueTime;
  final List<SubTodo> subTodos;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? completedAt;

  Todo({
    required this.id,
    required this.title,
    this.description,
    required this.completed,
    required this.priority,
    this.color,
    this.dueDate,
    this.dueTime,
    required this.subTodos,
    required this.tags,
    required this.createdAt,
    this.completedAt,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      completed: json['completed'] ?? false,
      priority: Priority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => Priority.medium,
      ),
      color: json['color'],
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      dueTime: json['due_time'],
      subTodos: (json['sub_todos'] as List<dynamic>?)
          ?.map((subTodo) => SubTodo.fromJson(subTodo))
          .toList() ?? [],
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed,
      'priority': priority.name,
      'color': color,
      'due_date': dueDate?.toIso8601String(),
      'due_time': dueTime,
      'sub_todos': subTodos.map((subTodo) => subTodo.toJson()).toList(),
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? completed,
    Priority? priority,
    String? color,
    DateTime? dueDate,
    String? dueTime,
    List<SubTodo>? subTodos,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
      color: color ?? this.color,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      subTodos: subTodos ?? this.subTodos,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  int get completedSubTodos => subTodos.where((sub) => sub.completed).length;
  double get progress => subTodos.isEmpty ? (completed ? 1.0 : 0.0) : completedSubTodos / subTodos.length;
}

class TodoFilter {
  final Priority? priority;
  final String? tag;
  final bool? completed;
  final String? search;

  TodoFilter({
    this.priority,
    this.tag,
    this.completed,
    this.search,
  });

  TodoFilter copyWith({
    Priority? priority,
    String? tag,
    bool? completed,
    String? search,
  }) {
    return TodoFilter(
      priority: priority ?? this.priority,
      tag: tag ?? this.tag,
      completed: completed ?? this.completed,
      search: search ?? this.search,
    );
  }
}
