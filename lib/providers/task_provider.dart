import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/Task_model.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService;
  StreamSubscription<List<TaskModel>>? _tasksSubscription;

  String? _userId;
  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filter States
  String _selectedPriority = 'All'; // 'All', 'High', 'Medium', 'Low'
  String _selectedStatus = 'All'; // 'All', 'Pending', 'Completed'
  String _searchQuery = '';

  TaskProvider({TaskService? taskService})
      : _taskService = taskService ?? TaskService();

  List<TaskModel> get allTasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get selectedPriority => _selectedPriority;
  String get selectedStatus => _selectedStatus;
  String get searchQuery => _searchQuery;

  // Count getters
  int get totalCount => _tasks.length;
  int get completedCount => _tasks.where((t) => t.isCompleted).length;
  int get pendingCount => _tasks.where((t) => !t.isCompleted).length;

  bool get hasActiveFilters =>
      _selectedPriority != 'All' ||
      _selectedStatus != 'All' ||
      _searchQuery.isNotEmpty;

  // Listen to Firestore stream when user logs in / changes
  void updateUserId(String? userId) {
    if (_userId == userId && _tasksSubscription != null) return;
    _userId = userId;

    _tasksSubscription?.cancel();
    _tasksSubscription = null;

    if (userId == null || userId.isEmpty) {
      _tasks = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _tasksSubscription = _taskService.getTasksStream(userId).listen(
      (tasks) {
        // Ensure sorted by due date earliest to latest
        tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        _tasks = tasks;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Filter setters
  void setPriorityFilter(String priority) {
    _selectedPriority = priority;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void resetFilters() {
    _selectedPriority = 'All';
    _selectedStatus = 'All';
    _searchQuery = '';
    notifyListeners();
  }

  // Filtered and sorted tasks (Earliest to latest due date)
  List<TaskModel> get filteredTasks {
    List<TaskModel> list = List.from(_tasks);

    // Status filter
    if (_selectedStatus == 'Completed') {
      list = list.where((t) => t.isCompleted).toList();
    } else if (_selectedStatus == 'Pending' || _selectedStatus == 'Incomplete') {
      list = list.where((t) => !t.isCompleted).toList();
    }

    // Priority filter
    if (_selectedPriority != 'All') {
      list = list
          .where((t) =>
              t.priority.toLowerCase() == _selectedPriority.toLowerCase())
          .toList();
    }

    // Search query filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list.where((t) {
        final titleMatch = t.title.toLowerCase().contains(query);
        final descMatch = t.description.toLowerCase().contains(query);
        return titleMatch || descMatch;
      }).toList();
    }

    // Ensure sorted by due date (earliest to latest)
    list.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return list;
  }

  // Tasks for specific section (today, tomorrow, week, later)
  List<TaskModel> getTasksForSection(String section) {
    return filteredTasks.where((task) => task.section == section).toList();
  }

  // CRUD operations
  Future<bool> addTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required String priority,
  }) async {
    if (_userId == null) {
      _errorMessage = 'User not authenticated.';
      notifyListeners();
      return false;
    }

    try {
      await _taskService.addTask(
        userId: _userId!,
        title: title,
        description: description,
        dueDate: dueDate,
        priority: priority,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask(TaskModel task) async {
    try {
      await _taskService.updateTask(task);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    if (_userId == null) return false;
    try {
      await _taskService.deleteTask(
        userId: _userId!,
        taskId: taskId,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleTaskComplete(String taskId, bool currentStatus) async {
    if (_userId == null) return false;
    try {
      await _taskService.toggleTaskStatus(
        userId: _userId!,
        taskId: taskId,
        isCompleted: !currentStatus,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
  }
}
