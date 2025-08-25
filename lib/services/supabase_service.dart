import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/todo.dart';

class SupabaseService {
  // Constants for table names
  static const String todosTable = 'todos';
  static const String subTodosTable = 'sub_todos';

  static SupabaseClient get _client => Supabase.instance.client;

  // Initialize Supabase
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );
    } catch (e) {
      throw Exception('Failed to initialize Supabase: $e');
    }
  }

  // -------------------------
  // Authentication
  // -------------------------

  static User? get currentUser => _client.auth.currentUser;

  static bool get isAuthenticated => currentUser != null;

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      return await _client.auth.signUp(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Sign-up failed: $e');
    }
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Sign-in failed: $e');
    }
  }

  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Sign-out failed: $e');
    }
  }

  // -------------------------
  // Todos CRUD
  // -------------------------

  static Future<List<Todo>> getTodos() async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      final response = await _client
          .from(todosTable)
          .select('*, $subTodosTable(*)')
          .eq('user_id', currentUser!.id)
          .order('created_at', ascending: false);

      return response.map<Todo>((json) => Todo.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch todos: $e');
    }
  }

  static Future<Todo> createTodo(Todo todo) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      final todoData = todo.toJson()
        ..['user_id'] = currentUser!.id
        ..remove('sub_todos');

      final response = await _client
          .from(todosTable)
          .insert(todoData)
          .select()
          .single();

      final createdTodo = Todo.fromJson(response);

      // Insert sub_todos if any
      if (todo.subTodos.isNotEmpty) {
        final subTodosData = todo.subTodos.map((subTodo) {
          final data = subTodo.toJson();
          data['todo_id'] = createdTodo.id;
          return data;
        }).toList();

        await _client.from(subTodosTable).insert(subTodosData);
      }

      return await getTodoById(createdTodo.id);
    } catch (e) {
      throw Exception('Failed to create todo: $e');
    }
  }

  static Future<Todo> updateTodo(Todo todo) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      // Update main todo (excluding sub_todos)
      final todoData = todo.toJson()..remove('sub_todos');
      await _client.from(todosTable).update(todoData).eq('id', todo.id);

      // Handle subtodos - delete existing and insert new ones
      await _client.from(subTodosTable).delete().eq('todo_id', todo.id);
      
      if (todo.subTodos.isNotEmpty) {
        final subTodosData = todo.subTodos.map((subTodo) {
          final data = subTodo.toJson();
          data['todo_id'] = todo.id;
          return data;
        }).toList();

        await _client.from(subTodosTable).insert(subTodosData);
      }

      return await getTodoById(todo.id);
    } catch (e) {
      throw Exception('Failed to update todo: $e');
    }
  }

  static Future<void> deleteTodo(String todoId) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      await _client.from(todosTable).delete().eq('id', todoId);
    } catch (e) {
      throw Exception('Failed to delete todo: $e');
    }
  }

  static Future<Todo> getTodoById(String todoId) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      final response = await _client
          .from(todosTable)
          .select('*, $subTodosTable(*)')
          .eq('id', todoId)
          .single();

      return Todo.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch todo by ID: $e');
    }
  }

  // -------------------------
  // SubTodos CRUD
  // -------------------------

  static Future<SubTodo> createSubTodo(String todoId, SubTodo subTodo) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      final subTodoData = subTodo.toJson()..['todo_id'] = todoId;

      final response = await _client
          .from(subTodosTable)
          .insert(subTodoData)
          .select()
          .single();

      return SubTodo.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create sub-todo: $e');
    }
  }

  static Future<SubTodo> updateSubTodo(SubTodo subTodo) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      final response = await _client
          .from(subTodosTable)
          .update(subTodo.toJson())
          .eq('id', subTodo.id)
          .select()
          .single();

      return SubTodo.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update sub-todo: $e');
    }
  }

  static Future<void> deleteSubTodo(String subTodoId) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      await _client.from(subTodosTable).delete().eq('id', subTodoId);
    } catch (e) {
      throw Exception('Failed to delete sub-todo: $e');
    }
  }

  // -------------------------
  // Real-time subscriptions
  // -------------------------

  static RealtimeChannel subscribeTodos(
      Future<void> Function(List<Todo>) onTodosChanged) {
    return _client
        .channel('todos_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: todosTable,
          callback: (payload) async {
            try {
              final todos = await getTodos();
              await onTodosChanged(todos);
            } catch (e) {
              // Optionally log error
            }
          },
        )
        .subscribe();
  }

  static RealtimeChannel subscribeSubTodos(Function() onSubTodosChanged) {
    return _client
        .channel('sub_todos_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: subTodosTable,
          callback: (payload) {
            try {
              onSubTodosChanged();
            } catch (_) {
              // Ignore callback errors
            }
          },
        )
        .subscribe();
  }
}

