// lib/task_model.dart
import 'package:flutter/material.dart';

enum TaskStatus { allotted, completed, awaiting, reallotted }

enum TaskPriority { high, medium, low } // Added Low for completeness

class Task {
  final String srNo;
  final String Taskid;
  final String TaskName;
  final String fileNo;
  final String client;
  final String taskSubTask;
  final String allottedBy;
  final String allottedTo;
  final String instructions;
  final String period;

  Task({
    required this.srNo,
    required this.Taskid,
    required this.TaskName,
    required this.fileNo,
    required this.client,
    required this.taskSubTask,
    required this.allottedBy,
    required this.allottedTo,
    required this.instructions,
    required this.period,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      srNo: json['id'] as String? ?? '',
      Taskid: json['id'] as String? ?? '',
      TaskName: json['task_name'] as String? ?? '',
      fileNo: json['Task_name'] as String? ?? 'Unknown Task',
      client: json['id'] as String? ?? '',
      taskSubTask: json['Task_name'] as String? ?? 'Unknown Task',
      allottedBy: json['id'] as String? ?? '',
      allottedTo: json['Task_name'] as String? ?? 'Unknown Task',
      instructions: json['id'] as String? ?? '',
      period: json['Task_name'] as String? ?? 'Unknown Task',
      // status: json['id'] as String? ?? '',
      // priority: json['Task_name'] as String? ?? 'Unknown Task',
    );
  }
}

// Helper functions to get display properties from enums
String statusToString(TaskStatus status) {
  switch (status) {
    case TaskStatus.allotted:
      return 'Allotted';
    case TaskStatus.completed:
      return 'Completed';
    case TaskStatus.awaiting:
      return 'Awaiting';
    case TaskStatus.reallotted:
      return 'Re-allotted';
  }
}

Color statusToColor(TaskStatus status) {
  switch (status) {
    case TaskStatus.allotted:
      return Colors.blue.shade700;
    case TaskStatus.completed:
      return Colors.green.shade700;
    case TaskStatus.awaiting:
      return Colors.orange.shade700;
    case TaskStatus.reallotted:
      return Colors.red.shade700;
  }
}

String priorityToString(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.high:
      return 'High';
    case TaskPriority.medium:
      return 'Medium';
    case TaskPriority.low:
      return 'Low';
  }
}

Color priorityToColor(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.high:
      return Colors.red.shade600;
    case TaskPriority.medium:
      return Colors.orange.shade600;
    case TaskPriority.low:
      return Colors.green.shade600; // Example color
  }
}
