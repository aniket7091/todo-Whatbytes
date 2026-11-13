import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:todo/core/constants/app_colors.dart';

import '../components/task_card.dart';
import '../models/Task_model.dart';
import '../providers/task_provider.dart';
import 'task_list_screen.dart';

class AllTasksScreen extends StatefulWidget {
  final String section;

  const AllTasksScreen({
    super.key,
    required this.section,
  });

  @override
  State<AllTasksScreen> createState() => _AllTasksScreenState();
}

class _AllTasksScreenState extends State<AllTasksScreen> {
  String selectedStatus = 'All'; // 'All', 'Pending', 'Completed'
  String selectedPriority = 'All'; // 'All', 'High', 'Medium', 'Low'

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final title = sectionTitles[widget.section] ??
        (widget.section == 'all' ? 'All Tasks' : widget.section);

    // Get tasks for section
    List<TaskModel> tasks = widget.section == 'all'
        ? List.from(taskProvider.allTasks)
        : taskProvider.getTasksForSection(widget.section);

    // Apply local status filter
    if (selectedStatus == 'Completed') {
      tasks = tasks.where((t) => t.isCompleted).toList();
    } else if (selectedStatus == 'Pending') {
      tasks = tasks.where((t) => !t.isCompleted).toList();
    }

    // Apply local priority filter
    if (selectedPriority != 'All') {
      tasks = tasks
          .where((t) =>
              t.priority.toLowerCase() == selectedPriority.toLowerCase())
          .toList();
    }

    // Sort by due date (earliest to latest)
    tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            CupertinoIcons.back,
            color: Color(0xFF263653),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: Color(0xFF263653),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.plus, color: AppColors.primary),
            onPressed: () => context.push('/add-task'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildChip(
                  label: 'All',
                  isSelected: selectedStatus == 'All' && selectedPriority == 'All',
                  onTap: () {
                    setState(() {
                      selectedStatus = 'All';
                      selectedPriority = 'All';
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildChip(
                  label: 'Pending',
                  isSelected: selectedStatus == 'Pending',
                  onTap: () {
                    setState(() {
                      selectedStatus = selectedStatus == 'Pending' ? 'All' : 'Pending';
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildChip(
                  label: 'Completed',
                  isSelected: selectedStatus == 'Completed',
                  onTap: () {
                    setState(() {
                      selectedStatus = selectedStatus == 'Completed' ? 'All' : 'Completed';
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildChip(
                  label: 'High',
                  color: AppColors.priorityHigh,
                  isSelected: selectedPriority == 'High',
                  onTap: () {
                    setState(() {
                      selectedPriority = selectedPriority == 'High' ? 'All' : 'High';
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildChip(
                  label: 'Medium',
                  color: AppColors.priorityMedium,
                  isSelected: selectedPriority == 'Medium',
                  onTap: () {
                    setState(() {
                      selectedPriority = selectedPriority == 'Medium' ? 'All' : 'Medium';
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildChip(
                  label: 'Low',
                  color: AppColors.priorityLow,
                  isSelected: selectedPriority == 'Low',
                  onTap: () {
                    setState(() {
                      selectedPriority = selectedPriority == 'Low' ? 'All' : 'Low';
                    });
                  },
                ),
              ],
            ),
          ),

          // Task Count
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
            child: Text(
              '${tasks.length} ${tasks.length == 1 ? "Task" : "Tasks"} sorted by due date',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9299A8),
              ),
            ),
          ),

          // Task List
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          CupertinoIcons.checkmark_seal,
                          size: 40,
                          color: Color(0xFFB5B7C3),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No tasks found',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9299A8),
                          ),
                        ),
                        if (selectedStatus != 'All' || selectedPriority != 'All') ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                selectedStatus = 'All';
                                selectedPriority = 'All';
                              });
                            },
                            child: const Text('Reset Filters'),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                    itemCount: tasks.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 11),
                    itemBuilder: (context, index) {
                      return TaskCard(
                        key: ValueKey(tasks[index].id),
                        task: tasks[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (color != null) ...[
              Container(
                height: 7,
                width: 7,
                margin: const EdgeInsets.only(right: 5),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF636D82),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
