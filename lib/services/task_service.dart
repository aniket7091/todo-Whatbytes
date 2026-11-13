import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore;

  TaskService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Subcollection reference for user-scoped tasks
  CollectionReference<Map<String, dynamic>> _userTasksRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  // Stream of tasks sorted by due date (earliest to latest)
  Stream<List<TaskModel>> getTasksStream(String userId) {
    return _userTasksRef(userId)
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TaskModel.fromFirestore(doc);
      }).toList();
    });
  }

  // Add task to Firestore
  Future<String> addTask({
    required String userId,
    required String title,
    required String description,
    required DateTime dueDate,
    required String priority,
  }) async {
    final docRef = _userTasksRef(userId).doc();
    final task = TaskModel(
      id: docRef.id,
      userId: userId,
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    await docRef.set(task.toMap());
    return docRef.id;
  }

  // Update existing task
  Future<void> updateTask(TaskModel task) async {
    await _userTasksRef(task.userId).doc(task.id).update(task.toMap());
  }

  // Delete task
  Future<void> deleteTask({
    required String userId,
    required String taskId,
  }) async {
    await _userTasksRef(userId).doc(taskId).delete();
  }

  // Toggle complete / incomplete status
  Future<void> toggleTaskStatus({
    required String userId,
    required String taskId,
    required bool isCompleted,
  }) async {
    await _userTasksRef(userId).doc(taskId).update({
      'isCompleted': isCompleted,
    });
  }
}
