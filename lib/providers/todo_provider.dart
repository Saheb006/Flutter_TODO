import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/todo.dart';
import '../services/supabase_service.dart';

// Configuration check provider
final isSupabaseConfiguredProvider = Provider<bool>((ref) {
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
  
  return supabaseUrl != null && 
         supabaseAnonKey != null &&
         !supabaseUrl.contains('your-project-ref') &&
         !supabaseAnonKey.contains('your-anon-key') &&
         supabaseUrl.isNotEmpty &&
         supabaseAnonKey.isNotEmpty;
});

// Auth state provider
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (state) => state.session != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

// Todo providers
final todosProvider = StateNotifierProvider<TodosNotifier, AsyncValue<List<Todo>>>((ref) {
  return TodosNotifier();
});

final todoFilterProvider = StateProvider<TodoFilter>((ref) => TodoFilter());

final filteredTodosProvider = Provider<AsyncValue<List<Todo>>>((ref) {
  final todos = ref.watch(todosProvider);
  final filter = ref.watch(todoFilterProvider);
  
  return todos.when(
    data: (todoList) {
      var filtered = todoList;
      
      if (filter.search != null && filter.search!.isNotEmpty) {
        filtered = filtered.where((todo) =>
          todo.title.toLowerCase().contains(filter.search!.toLowerCase()) ||
          (todo.description?.toLowerCase().contains(filter.search!.toLowerCase()) ?? false)
        ).toList();
      }
      
      if (filter.priority != null) {
        filtered = filtered.where((todo) => todo.priority == filter.priority).toList();
      }
      
      if (filter.completed != null) {
        filtered = filtered.where((todo) => todo.completed == filter.completed).toList();
      }
      
      if (filter.tag != null && filter.tag!.isNotEmpty) {
        filtered = filtered.where((todo) => todo.tags.contains(filter.tag)).toList();
      }
      
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

class TodosNotifier extends StateNotifier<AsyncValue<List<Todo>>> {
  TodosNotifier() : super(const AsyncValue.loading()) {
    loadTodos();
  }

  Future<void> loadTodos() async {
    try {
      state = const AsyncValue.loading();
      final todos = await SupabaseService.getTodos();
      state = AsyncValue.data(todos);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addTodo(Todo todo) async {
    try {
      final newTodo = await SupabaseService.createTodo(todo);
      state = state.when(
        data: (todos) => AsyncValue.data([newTodo, ...todos]),
        loading: () => state,
        error: (error, stack) => state,
      );
    } catch (error) {
      // Handle error
      rethrow;
    }
  }

  Future<void> updateTodo(Todo todo) async {
    try {
      final updatedTodo = await SupabaseService.updateTodo(todo);
      state = state.when(
        data: (todos) {
          final index = todos.indexWhere((t) => t.id == todo.id);
          if (index != -1) {
            final newTodos = [...todos];
            newTodos[index] = updatedTodo;
            return AsyncValue.data(newTodos);
          }
          return state;
        },
        loading: () => state,
        error: (error, stack) => state,
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteTodo(String todoId) async {
    try {
      await SupabaseService.deleteTodo(todoId);
      state = state.when(
        data: (todos) => AsyncValue.data(todos.where((t) => t.id != todoId).toList()),
        loading: () => state,
        error: (error, stack) => state,
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<void> toggleTodoComplete(String todoId) async {
    state = state.when(
      data: (todos) {
        final index = todos.indexWhere((t) => t.id == todoId);
        if (index != -1) {
          final todo = todos[index];
          final updatedTodo = todo.copyWith(
            completed: !todo.completed,
            completedAt: !todo.completed ? DateTime.now() : null,
          );
          updateTodo(updatedTodo);
          
          final newTodos = [...todos];
          newTodos[index] = updatedTodo;
          return AsyncValue.data(newTodos);
        }
        return state;
      },
      loading: () => state,
      error: (error, stack) => state,
    );
  }
}
