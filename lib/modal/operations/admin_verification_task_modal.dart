// lib/models/verification_task_model.dart (adjust path as needed)
import 'package:flutter/material.dart';

// Re-use or redefine enums if not globally accessible
// Assuming TaskStatus and TaskPriority are defined elsewhere (e.g., in task_modal.dart)
// If not, define them here:
enum TaskStatus { completed } // Simplified for this view based on image

enum TaskPriority { medium } // Simplified for this view based on image

// Helper functions (can be reused or redefined)
String statusVerificationToString(TaskStatus status) {
  switch (status) {
    case TaskStatus.completed:
      return 'Completed';
    // Add other cases if needed
  }
}

String priorityVerificationToString(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.medium:
      return 'Medium';
    // Add other cases if needed
  }
}

// Define specific color for this screen's status
Color statusVerificationColor = Colors.green.shade700; // Consistent green

class VerificationTask {
  final String id; // Use an ID for selection tracking
  final String srNo;
  final String fileNo;
  final String client;
  final String taskSubTask;
  final String allottedBy;
  final String allottedTo;
  final String instruction;
  final String endDate; // String for simplicity, format "dd-MM-yyyy"
  final String period;
  final TaskStatus status;
  final TaskPriority priority;
  final bool approvalNeeded;
  bool isSelected; // For checkbox state

  VerificationTask({
    required this.id,
    required this.srNo,
    required this.fileNo,
    required this.client,
    required this.taskSubTask,
    required this.allottedBy,
    required this.allottedTo,
    required this.instruction,
    required this.endDate,
    required this.period,
    required this.status,
    required this.priority,
    this.approvalNeeded = true, // Default based on image
    this.isSelected = false, // Default to not selected
  });
}
