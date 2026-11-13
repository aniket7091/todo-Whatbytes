import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo/core/constants/app_colors.dart';
import '../components/task_card.dart';
import '../providers/task_provider.dart';

class CalendarTasksScreen extends StatefulWidget {
  const CalendarTasksScreen({super.key});

  @override
  State<CalendarTasksScreen> createState() => _CalendarTasksScreenState();
}

class _CalendarTasksScreenState extends State<CalendarTasksScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();

    // Tasks on selected date
    final dateTasks = taskProvider.allTasks.where((task) {
      return task.dueDate.year == _selectedDate.year &&
          task.dueDate.month == _selectedDate.month &&
          task.dueDate.day == _selectedDate.day;
    }).toList();

    dateTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calendar Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFEAEAF0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: AppColors.darkText,
                ),
              ),
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
                onDateChanged: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Date Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('EEEE, d MMMM').format(_selectedDate),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${dateTasks.length} ${dateTasks.length == 1 ? "task" : "tasks"}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Tasks on date
          if (dateTasks.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEAEAF0)),
              ),
              child: Column(
                children: [
                  const Icon(
                    CupertinoIcons.calendar_badge_plus,
                    size: 34,
                    color: Color(0xFFB5B7C3),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'No tasks on this date',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Enjoy your free time or schedule a new task.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(130, 38),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(CupertinoIcons.plus, size: 16),
                    label: const Text(
                      'Schedule Task',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    onPressed: () => context.push('/add-task'),
                  ),
                ],
              ),
            )
          else
            ...dateTasks.map(
              (task) => Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: TaskCard(task: task),
              ),
            ),
        ],
      ),
    );
  }
}
