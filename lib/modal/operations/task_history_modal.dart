// lib/models/task_history_item.dart (or your preferred path)
import 'package:flutter/material.dart';

// Enum for different task statuses observed in the image
enum TaskHistoryStatus { allotted, awaitingResponse, reallotted }

// Enum for task priority (only High seen, but good practice to use enum)
enum TaskPriority {
  high,
  // Add medium, low if needed later
}

// Helper function to get display text for status
String taskHistoryStatusToString(TaskHistoryStatus status) {
  switch (status) {
    case TaskHistoryStatus.allotted:
      return 'Allotted';
    case TaskHistoryStatus.awaitingResponse:
      return 'Awaiting-response'; // Match image hyphenation
    case TaskHistoryStatus.reallotted:
      return 'Re-allotted'; // Match image hyphenation
  }
}

// Helper function to get background color for status chip
Color getStatusColor(TaskHistoryStatus status) {
  switch (status) {
    case TaskHistoryStatus.allotted:
      return Colors.blue.shade700; // Blue for Allotted
    case TaskHistoryStatus.awaitingResponse:
      return Colors.red.shade600; // Red for Awaiting-response
    case TaskHistoryStatus.reallotted:
      return Colors
          .red
          .shade600; // Red for Re-allotted (same as awaiting in img)
  }
}

// Helper function to get display text for priority
String taskPriorityToString(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.high:
      return 'High';
  }
}

// Helper function to get background color for priority chip (Consistent Red in image)
Color getPriorityColor(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.high:
      return Colors.red.shade700;
  }
}

class TaskHistoryItem {
  final String srNo;
  final String fileNo;
  final String client;
  final String taskSubTask;
  final String allottedBy;
  final String allottedTo;
  final String instructions;
  final String period; // Can be date range or '-'
  final TaskHistoryStatus status;
  final TaskPriority priority;

  TaskHistoryItem({
    required this.srNo,
    required this.fileNo,
    required this.client,
    required this.taskSubTask,
    required this.allottedBy,
    required this.allottedTo,
    required this.instructions,
    required this.period,
    required this.status,
    required this.priority,
  });
}
