import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/todo_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/supabase_service.dart';
import '../auth/login_screen.dart';
import '../todo/add_todo_screen.dart';
import '../../widgets/todo_card.dart';
import '../../widgets/filter_bottom_sheet.dart';
import '../../models/todo.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const FilterBottomSheet(),
    );
  }

  Future<void> _signOut() async {
    try {
      await SupabaseService.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTodos = ref.watch(filteredTodosProvider);
    final filter = ref.watch(todoFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FocusFlow'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: _hasActiveFilters(filter) ? Theme.of(context).primaryColor : null,
            ),
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark 
                  ? Icons.light_mode 
                  : Icons.dark_mode,
            ),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'signout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'signout') _signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search todos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(todoFilterProvider.notifier).state = 
                              filter.copyWith(search: '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                ref.read(todoFilterProvider.notifier).state = 
                    filter.copyWith(search: value);
              },
            ),
          ),
          Expanded(
            child: filteredTodos.when(
              data: (todos) {
                if (todos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _hasActiveFilters(filter) 
                              ? 'No todos match your filters'
                              : 'No todos yet',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _hasActiveFilters(filter)
                              ? 'Try adjusting your search or filters'
                              : 'Tap + to create your first todo',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(todosProvider.notifier).loadTodos();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TodoCard(todo: todo),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading todos',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.read(todosProvider.notifier).loadTodos(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddTodoScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  bool _hasActiveFilters(TodoFilter filter) {
    return filter.priority != null ||
           filter.tag != null ||
           filter.completed != null ||
           (filter.search != null && filter.search!.isNotEmpty);
  }
}
