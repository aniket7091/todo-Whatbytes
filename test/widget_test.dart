import 'package:flutter_test/flutter_test.dart';
import 'package:todo/models/Task_model.dart';

void main() {
  group('TaskModel Tests', () {
    test('TaskModel creation and copyWith', () {
      final now = DateTime.now();
      final task = TaskModel(
        id: '1',
        userId: 'user123',
        title: 'Complete assignment',
        description: 'Finish Flutter assignment',
        dueDate: now,
        priority: 'High',
        isCompleted: false,
        createdAt: now,
      );

      expect(task.id, '1');
      expect(task.title, 'Complete assignment');
      expect(task.priority, 'High');
      expect(task.isCompleted, false);

      final updatedTask = task.copyWith(isCompleted: true);
      expect(updatedTask.isCompleted, true);
      expect(updatedTask.title, 'Complete assignment');
    });

    test('TaskModel section calculations', () {
      final now = DateTime.now();
      final todayTask = TaskModel(
        id: '1',
        userId: 'u1',
        title: 'Today task',
        dueDate: now,
        createdAt: now,
      );
      expect(todayTask.section, 'today');

      final tomorrowTask = TaskModel(
        id: '2',
        userId: 'u1',
        title: 'Tomorrow task',
        dueDate: now.add(const Duration(days: 1)),
        createdAt: now,
      );
      expect(tomorrowTask.section, 'tomorrow');
    });
  });
}
