import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';

class FilterBottomSheet extends ConsumerWidget {
  const FilterBottomSheet({super.key});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(todoFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Todos',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        ref.read(todoFilterProvider.notifier).state = TodoFilter();
                      },
                      icon: const Icon(Icons.clear_all, size: 18),
                      label: const Text('Clear All'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Priority Filter
                Text(
                  'Priority',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: Priority.values.map((priority) {
                    final isSelected = filter.priority == priority;
                    final priorityColor = _getPriorityColor(priority);
                    
                    return GestureDetector(
                      onTap: () {
                        ref.read(todoFilterProvider.notifier).state = filter.copyWith(
                          priority: isSelected ? null : priority,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? priorityColor.withOpacity(0.1)
                              : (isDark ? Colors.grey[800] : Colors.grey[100]),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected 
                                ? priorityColor 
                                : (isDark ? Colors.grey[600]! : Colors.grey[300]!),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: priorityColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              priority.name.toUpperCase(),
                              style: TextStyle(
                                color: isSelected 
                                    ? priorityColor 
                                    : (isDark ? Colors.white : Colors.black),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.check,
                                size: 16,
                                color: priorityColor,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 24),
                
                // Completion Status Filter
                Text(
                  'Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          ref.read(todoFilterProvider.notifier).state = filter.copyWith(
                            completed: filter.completed == true ? null : true,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: filter.completed == true 
                                ? Colors.green.withOpacity(0.1)
                                : (isDark ? Colors.grey[800] : Colors.grey[100]),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: filter.completed == true 
                                  ? Colors.green 
                                  : (isDark ? Colors.grey[600]! : Colors.grey[300]!),
                              width: filter.completed == true ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 18,
                                color: filter.completed == true 
                                    ? Colors.green 
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Completed',
                                style: TextStyle(
                                  color: filter.completed == true 
                                      ? Colors.green 
                                      : (isDark ? Colors.white : Colors.black),
                                  fontWeight: filter.completed == true 
                                      ? FontWeight.bold 
                                      : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          ref.read(todoFilterProvider.notifier).state = filter.copyWith(
                            completed: filter.completed == false ? null : false,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: filter.completed == false 
                                ? Colors.orange.withOpacity(0.1)
                                : (isDark ? Colors.grey[800] : Colors.grey[100]),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: filter.completed == false 
                                  ? Colors.orange 
                                  : (isDark ? Colors.grey[600]! : Colors.grey[300]!),
                              width: filter.completed == false ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.pending,
                                size: 18,
                                color: filter.completed == false 
                                    ? Colors.orange 
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Pending',
                                style: TextStyle(
                                  color: filter.completed == false 
                                      ? Colors.orange 
                                      : (isDark ? Colors.white : Colors.black),
                                  fontWeight: filter.completed == false 
                                      ? FontWeight.bold 
                                      : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // Apply Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.filter_alt),
                    label: const Text('Apply Filters'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                
                // Add bottom padding for safe area
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }
}