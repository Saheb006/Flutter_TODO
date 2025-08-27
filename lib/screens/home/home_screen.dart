import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/todo_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/supabase_service.dart';
import '../auth/login_screen.dart';
import '../todo/add_todo_screen.dart';
import '../calendar/calendar_screen.dart';
import '../profile/profile_screen.dart';
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
  int _currentIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.8,
        builder: (context, scrollController) => const FilterBottomSheet(),
      ),
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

  Widget _buildTodosTab() {
    final filteredTodos = ref.watch(filteredTodosProvider);
    final filter = ref.watch(todoFilterProvider);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
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
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[100],
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
                  padding: const EdgeInsets.all(16),
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
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
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'FocusFlow';
      case 1:
        return 'Calendar & Reminders';
      case 2:
        return 'Profile';
      default:
        return 'FocusFlow';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(todoFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: _currentIndex == 0 ? [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: _hasActiveFilters(filter) 
                  ? Theme.of(context).primaryColor 
                  : (Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white 
                      : Colors.black),
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
        ] : _currentIndex == 1 ? [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark 
                  ? Icons.light_mode 
                  : Icons.dark_mode,
            ),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
        ] : null,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildTodosTab(),
          const CalendarScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Todos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddTodoScreen()),
          );
        },
        child: const Icon(Icons.add),
      ) : null,
    );
  }

  bool _hasActiveFilters(TodoFilter filter) {
    return filter.priority != null ||
           filter.tag != null ||
           filter.completed != null ||
           (filter.search != null && filter.search!.isNotEmpty);
  }
}