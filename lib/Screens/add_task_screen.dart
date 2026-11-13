import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:todo/core/constants/app_colors.dart';
import 'package:todo/components/task_form_field.dart';
import 'package:todo/components/task_date_picker.dart';
import 'package:todo/components/task_priority_selector.dart';
import 'package:todo/components/task_submit_button.dart';
import 'package:todo/models/Task_model.dart';
import 'package:todo/providers/task_provider.dart';

class AddTaskScreen extends StatefulWidget {
  final TaskModel? initialTask;

  const AddTaskScreen({super.key, this.initialTask});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController titleController;
  late final TextEditingController descriptionController;

  DateTime? selectedDate;
  String selectedPriority = 'Medium';
  bool _isSaving = false;

  bool get isEditing => widget.initialTask != null;

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    titleController = TextEditingController(text: task?.title ?? '');
    descriptionController = TextEditingController(text: task?.description ?? '');
    selectedDate = task?.dueDate ?? DateTime.now();
    selectedPriority = task?.priority ?? 'Medium';
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a due date'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final provider = context.read<TaskProvider>();
    bool success;

    if (isEditing) {
      final updated = widget.initialTask!.copyWith(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        dueDate: selectedDate!,
        priority: selectedPriority,
      );
      success = await provider.updateTask(updated);
    } else {
      success = await provider.addTask(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        dueDate: selectedDate!,
        priority: selectedPriority,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Task updated successfully!' : 'Task created successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to save task.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          isEditing ? 'Edit Task' : 'Add New Task',
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: Color(0xFF263653),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Update task details' : 'Create your task',
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF263653),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isEditing
                    ? 'Modify the details below and save changes.'
                    : 'Fill in the details below to add a new task.',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9299A8),
                ),
              ),
              const SizedBox(height: 28),

              // Title
              TaskFormField(
                label: 'Task Title',
                hint: 'Enter task title',
                controller: titleController,
                icon: CupertinoIcons.pencil,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 22),

              // Description
              TaskFormField(
                label: 'Description',
                hint: 'Write something about your task...',
                controller: descriptionController,
                icon: CupertinoIcons.text_alignleft,
                maxLines: 4,
              ),

              const SizedBox(height: 22),

              // Due Date Picker
              TaskDatePicker(
                selectedDate: selectedDate,
                onDateSelected: (date) {
                  setState(() {
                    selectedDate = date;
                  });
                },
              ),

              const SizedBox(height: 22),

              // Priority Selector
              TaskPrioritySelector(
                selectedPriority: selectedPriority,
                onChanged: (priority) {
                  setState(() {
                    selectedPriority = priority;
                  });
                },
              ),

              const SizedBox(height: 35),

              // Submit Button
              TaskSubmitButton(
                label: isEditing ? 'Update Task' : 'Create Task',
                icon: isEditing ? CupertinoIcons.pencil_circle : CupertinoIcons.checkmark_circle,
                isLoading: _isSaving,
                onPressed: _saveTask,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
