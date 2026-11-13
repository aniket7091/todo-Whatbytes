import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo/core/constants/app_colors.dart';
import '../models/Task_model.dart';
import '../providers/task_provider.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
  });

  void _showTaskDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    height: 4,
                    width: 40,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4E4EA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Header with status & priority badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildPriorityBadge(task.priority),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: task.isCompleted
                                ? const Color(0xFFE5F4EA)
                                : const Color(0xFFECEBFF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            task.isCompleted ? 'Completed' : 'Pending',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: task.isCompleted
                                  ? const Color(0xFF2E8540)
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.xmark, size: 20),
                      onPressed: () => Navigator.pop(bottomSheetContext),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Task Title
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),

                const SizedBox(height: 10),

                // Due Date
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.calendar,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Due: ${DateFormat('EEEE, d MMMM yyyy').format(task.dueDate)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF717D96),
                      ),
                    ),
                  ],
                ),

                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEAEAF0)),
                    ),
                    child: Text(
                      task.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4A5568),
                        height: 1.45,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    // Toggle complete button
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: task.isCompleted ? const Color(0xFFE7A844) : AppColors.primary,
                          side: BorderSide(
                            color: task.isCompleted ? const Color(0xFFE7A844) : AppColors.primary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: Icon(
                          task.isCompleted
                              ? CupertinoIcons.arrow_counterclockwise
                              : CupertinoIcons.checkmark_alt,
                          size: 18,
                        ),
                        label: Text(
                          task.isCompleted ? 'Mark Pending' : 'Mark Done',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        onPressed: () {
                          Navigator.pop(bottomSheetContext);
                          context.read<TaskProvider>().toggleTaskComplete(task.id, task.isCompleted);
                        },
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Edit button
                    IconButton.filledTonal(
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFECEBFF),
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(CupertinoIcons.pencil, size: 20),
                      onPressed: () {
                        Navigator.pop(bottomSheetContext);
                        context.push('/add-task', extra: task);
                      },
                    ),

                    const SizedBox(width: 8),

                    // Delete button
                    IconButton.filledTonal(
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFFFECEC),
                        foregroundColor: AppColors.error,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(CupertinoIcons.trash, size: 20),
                      onPressed: () {
                        Navigator.pop(bottomSheetContext);
                        _confirmDelete(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Delete Task',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.darkText),
        ),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.lightText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final success = await context.read<TaskProvider>().deleteTask(task.id);
              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Task deleted'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () => _showTaskDetails(context),
        borderRadius: BorderRadius.circular(17),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minHeight: 76),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: const Color(0xFFEAEAF0),
              width: 0.9,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF263653).withOpacity(0.035),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Checkbox button
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  context.read<TaskProvider>().toggleTaskComplete(task.id, task.isCompleted);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 22,
                  width: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.isCompleted ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: task.isCompleted ? AppColors.primary : const Color(0xFFB5B3ED),
                      width: 1.7,
                    ),
                  ),
                  child: task.isCompleted
                      ? const Icon(
                          Icons.check_rounded,
                          size: 15,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),

              const SizedBox(width: 12),

              // Title and Date + Description snippet
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: task.isCompleted
                            ? const Color(0xFFADB2BD)
                            : const Color(0xFF34415B),
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),

                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        task.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: task.isCompleted
                              ? const Color(0xFFC3C7D2)
                              : const Color(0xFF7E879B),
                        ),
                      ),
                    ],

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 11,
                          color: Color(0xFFA7ADBA),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          task.formattedDate,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFA7ADBA),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Priority Badge
              _buildPriorityBadge(task.priority),

              const SizedBox(width: 4),

              // Quick Popup Menu
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  size: 18,
                  color: Color(0xFFADB3C0),
                ),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  if (value == 'view') {
                    _showTaskDetails(context);
                  } else if (value == 'edit') {
                    context.push('/add-task', extra: task);
                  } else if (value == 'delete') {
                    _confirmDelete(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.eye, size: 16, color: AppColors.darkText),
                        SizedBox(width: 8),
                        Text('View', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.pencil, size: 16, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('Edit', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.trash, size: 16, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(fontSize: 13, color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color bg;
    Color fg;

    switch (priority.toLowerCase()) {
      case 'high':
        bg = const Color(0xFFFFECEC);
        fg = const Color(0xFFD94444);
        break;
      case 'low':
        bg = const Color(0xFFE5F4EA);
        fg = const Color(0xFF2E8540);
        break;
      case 'medium':
      default:
        bg = const Color(0xFFFFF1D8);
        fg = const Color(0xFFD69A32);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        priority,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
