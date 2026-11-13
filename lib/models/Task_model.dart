import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/core/constants/app_colors.dart';

class TaskModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime dueDate;
  final String priority; // 'Low', 'Medium', 'High'
  final bool isCompleted;
  final DateTime createdAt;

  const TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    required this.dueDate,
    this.priority = 'Medium',
    this.isCompleted = false,
    required this.createdAt,
  });

  // Section calculation: today, tomorrow, week, later
  String get section {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final diff = taskDay.difference(today).inDays;

    if (diff <= 0) {
      return 'today';
    } else if (diff == 1) {
      return 'tomorrow';
    } else if (diff <= 7) {
      return 'week';
    } else {
      return 'later';
    }
  }

  // Formatted date string (e.g., '14 Nov')
  String get formattedDate {
    final now = DateTime.now();
    if (dueDate.year == now.year) {
      return DateFormat('d MMM').format(dueDate);
    }
    return DateFormat('d MMM yyyy').format(dueDate);
  }

  // Priority color helper
  Color get priorityColor {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.priorityHigh;
      case 'low':
        return AppColors.priorityLow;
      case 'medium':
      default:
        return AppColors.priorityMedium;
    }
  }

  // Category badge name helper (e.g. for display)
  List<String> get categories {
    return [priority];
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'priority': priority,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Factory from Firestore map
  factory TaskModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is DateTime) {
        return value;
      } else if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return TaskModel(
      id: docId,
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      dueDate: parseDate(map['dueDate']),
      priority: map['priority'] as String? ?? 'Medium',
      isCompleted: map['isCompleted'] as bool? ?? false,
      createdAt: parseDate(map['createdAt']),
    );
  }

  // Factory from Firestore DocumentSnapshot
  factory TaskModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return TaskModel.fromMap(doc.data() ?? {}, doc.id);
  }

  TaskModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? dueDate,
    String? priority,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Backward compatibility alias for any existing code
typedef TaskItem = TaskModel;
