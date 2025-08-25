import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';

class FilterBottomSheet extends ConsumerWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(todoFilterProvider);
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Todos',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () {
                  ref.read(todoFilterProvider.notifier).state = TodoFilter();
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Priority Filter
          Text(
            'Priority',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: Priority.values.map((priority) {
              final isSelected = filter.priority == priority;
              return FilterChip(
                label: Text(priority.name.toUpperCase()),
                selected: isSelected,
                onSelected: (selected) {
                  ref.read(todoFilterProvider.notifier).state = filter.copyWith(
                    priority: selected ? priority : null,
                  );
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: 20),
          
          // Completion Status Filter
          Text(
            'Status',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              FilterChip(
                label: const Text('Completed'),
                selected: filter.completed == true,
                onSelected: (selected) {
                  ref.read(todoFilterProvider.notifier).state = filter.copyWith(
                    completed: selected ? true : null,
                  );
                },
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Pending'),
                selected: filter.completed == false,
                onSelected: (selected) {
                  ref.read(todoFilterProvider.notifier).state = filter.copyWith(
                    completed: selected ? false : null,
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
