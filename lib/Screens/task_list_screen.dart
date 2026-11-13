import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:todo/core/constants/app_colors.dart';

import '../components/task_card.dart';
import '../models/Task_model.dart';
import '../providers/task_provider.dart';

// Section Titles
const Map<String, String> sectionTitles = {
  'today': 'Today',
  'tomorrow': 'Tomorrow',
  'week': 'This Week',
  'later': 'Later / Upcoming',
};

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();

    if (taskProvider.isLoading && taskProvider.allTasks.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    final hasActiveFilter = taskProvider.hasActiveFilters;
    final filteredTasks = taskProvider.filteredTasks;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        // Stream updates automatically in Firestore, this is just for tactile feedback
        await Future.delayed(const Duration(milliseconds: 300));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Filter Chips
            _buildStatusFilterRow(context, taskProvider),

            const SizedBox(height: 10),

            // Priority Filter Chips
            _buildPriorityFilterRow(context, taskProvider),

            const SizedBox(height: 14),

            // If active filter, show active filter header + flat list sorted by due date
            if (hasActiveFilter) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtered Results (${filteredTasks.length})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      minimumSize: Size.zero,
                    ),
                    icon: const Icon(CupertinoIcons.clear_circled, size: 14, color: AppColors.primary),
                    label: const Text(
                      'Clear Filters',
                      style: TextStyle(fontSize: 12, color: AppColors.primary),
                    ),
                    onPressed: () {
                      taskProvider.resetFilters();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (filteredTasks.isEmpty)
                _buildEmptyFilterState(context, taskProvider)
              else
                ...filteredTasks.map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: 11),
                    child: TaskCard(task: task),
                  ),
                ),
            ] else ...[
              // No filters active: Section based layout (Today, Tomorrow, This Week, Later)
              if (taskProvider.allTasks.isEmpty)
                _buildEmptyAllTasks(context)
              else ...[
                _buildSection(context, taskProvider, 'today'),
                const SizedBox(height: 18),
                _buildSection(context, taskProvider, 'tomorrow'),
                const SizedBox(height: 18),
                _buildSection(context, taskProvider, 'week'),
                if (taskProvider.getTasksForSection('later').isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _buildSection(context, taskProvider, 'later'),
                ],
              ],
            ],
          ],
        ),
      ),
    );
  }

  // Status filter pills (All, Incomplete, Completed)
  Widget _buildStatusFilterRow(BuildContext context, TaskProvider provider) {
    final statuses = [
      {'label': 'All', 'value': 'All', 'count': provider.totalCount},
      {'label': 'Incomplete', 'value': 'Pending', 'count': provider.pendingCount},
      {'label': 'Completed', 'value': 'Completed', 'count': provider.completedCount},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statuses.map((item) {
          final isSelected = provider.selectedStatus == item['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              showCheckmark: false,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item['label'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF636D82),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withOpacity(0.25) : const Color(0xFFEBEBF2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${item['count']}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : const Color(0xFF7A8499),
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.white,
              selectedColor: AppColors.primary,
              side: BorderSide(
                color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB),
                width: 1,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onSelected: (_) => provider.setStatusFilter(item['value'] as String),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Priority filter chips (All, High, Medium, Low)
  Widget _buildPriorityFilterRow(BuildContext context, TaskProvider provider) {
    final priorities = [
      {'label': 'All Priorities', 'value': 'All', 'color': Colors.transparent},
      {'label': 'High', 'value': 'High', 'color': AppColors.priorityHigh},
      {'label': 'Medium', 'value': 'Medium', 'color': AppColors.priorityMedium},
      {'label': 'Low', 'value': 'Low', 'color': AppColors.priorityLow},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: priorities.map((p) {
          final isSelected = provider.selectedPriority.toLowerCase() == (p['value'] as String).toLowerCase();
          final Color dotColor = p['color'] as Color;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: isSelected,
              showCheckmark: false,
              avatar: dotColor != Colors.transparent
                  ? Container(
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : dotColor,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
              label: Text(
                p['label'] as String,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF636D82),
                ),
              ),
              backgroundColor: Colors.white,
              selectedColor: AppColors.secondary,
              side: BorderSide(
                color: isSelected ? AppColors.secondary : const Color(0xFFE5E7EB),
                width: 1,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onSelected: (_) => provider.setPriorityFilter(p['value'] as String),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Task Section (Today, Tomorrow, Week, Later)
  Widget _buildSection(BuildContext context, TaskProvider provider, String section) {
    final tasks = provider.getTasksForSection(section);
    final title = sectionTitles[section] ?? section;

    if (tasks.isEmpty) {
      return const SizedBox.shrink();
    }

    final previewTasks = tasks.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Heading + View All
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF263653),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBEBF2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7A8499),
                    ),
                  ),
                ),
              ],
            ),

            if (tasks.length > 2)
              TextButton(
                onPressed: () {
                  context.push('/tasks/$section');
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 8),

        // Task Cards (Sorted by due date)
        ...previewTasks.map(
          (task) => Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: TaskCard(task: task),
          ),
        ),
      ],
    );
  }

  // Empty state when user has no tasks
  Widget _buildEmptyAllTasks(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.doc_text,
              size: 34,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No tasks yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Create your first task by tapping the pencil button below!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.lightText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(160, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(CupertinoIcons.plus, size: 18),
            label: const Text('Add Task', style: TextStyle(color: Colors.white, fontSize: 13)),
            onPressed: () => context.push('/add-task'),
          ),
        ],
      ),
    );
  }

  // Empty state for filters
  Widget _buildEmptyFilterState(BuildContext context, TaskProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAEAF0)),
      ),
      child: Column(
        children: [
          const Icon(
            CupertinoIcons.search,
            size: 36,
            color: Color(0xFFB5B7C3),
          ),
          const SizedBox(height: 12),
          const Text(
            'No matching tasks',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Try adjusting your search or priority/status filters.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.lightText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () => provider.resetFilters(),
            child: const Text('Reset All Filters'),
          ),
        ],
      ),
    );
  }
}
