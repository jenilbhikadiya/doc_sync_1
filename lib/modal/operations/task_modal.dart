import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum TaskStatus { allotted, completed, awaiting, reallotted }

enum TaskPriority { high, medium, low }

class Task {
  final String? srNo;
  final String Taskid;
  final String TaskName;
  final String? fileNo;
  final String? client;
  final String? taskSubTask;
  final String? allottedBy;
  final String? allottedTo;
  final String? instructions;
  final String? period;
  final TaskStatus? status;
  final TaskPriority? priority;

  final String? clientId;
  final String? subTaskId;
  final String? allottedToId;
  final String? allottedById;
  final String? financialYearId;
  final String? monthFrom;
  final String? monthTo;
  final DateTime? allottedDate;
  final DateTime? expectedEndDate;
  final String? verifyByAdmin;
  final DateTime? dateTime;
  final String? adt;
  final String? financialYear;

  Task({
    this.srNo,
    required this.Taskid,
    required this.TaskName,
    this.fileNo,
    this.client,
    this.taskSubTask,
    this.allottedBy,
    this.allottedTo,
    this.instructions,
    this.period,
    this.status,
    this.priority,

    this.clientId,
    this.subTaskId,
    this.allottedToId,
    this.allottedById,
    this.financialYearId,
    this.monthFrom,
    this.monthTo,
    this.allottedDate,
    this.expectedEndDate,
    this.verifyByAdmin,
    this.dateTime,
    this.adt,
    this.financialYear,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    DateTime? _tryParseDateTime(String? dateString) {
      if (dateString == null || dateString.isEmpty) {
        return null;
      }

      return DateTime.tryParse(dateString);
    }

    String? from = json['month_from'] as String?;
    String? to = json['month_to'] as String?;
    String constructedPeriod = 'N/A';
    if (from != null && from.isNotEmpty && to != null && to.isNotEmpty) {
      constructedPeriod = '$from - $to';
    } else if (from != null && from.isNotEmpty) {
      constructedPeriod = from;
    } else if (to != null && to.isNotEmpty) {
      constructedPeriod = to;
    }

    return Task(
      srNo: json['id'] as String? ?? '',
      Taskid: json['task_id'] as String? ?? '',
      TaskName: json['task_name'] as String? ?? 'Unknown Task',
      fileNo: json['file_no'] as String? ?? 'N/A',
      client: json['client_name'] as String? ?? 'Unknown Client',
      taskSubTask: json['sub_task_name'] as String? ?? 'N/A',
      allottedBy: json['alloted_by_name'] as String? ?? 'Unknown',
      allottedTo: json['alloted_to_name'] as String? ?? 'Unassigned',
      instructions: json['instruction'] as String? ?? '',
      period: constructedPeriod,
      status: _parseStatus(json['status'] as String?),
      priority: _parsePriority(json['priority'] as String?),

      clientId: json['client_id'] as String?,
      subTaskId: json['sub_task_id'] as String?,
      allottedToId: json['alloted_to'] as String?,
      allottedById: json['alloted_by'] as String?,
      financialYearId: json['financial_year_id'] as String?,
      monthFrom: from,
      monthTo: to,
      allottedDate: _tryParseDateTime(json['alloted_date'] as String?),
      expectedEndDate: _tryParseDateTime(json['expected_end_date'] as String?),
      verifyByAdmin: json['verify_by_admin'] as String?,
      dateTime: _tryParseDateTime(json['date_time'] as String?),
      adt: json['adt'] as String?,
      financialYear: json['financial_year'] as String?,
    );
  }
}

TaskStatus _parseStatus(String? statusString) {
  statusString = statusString?.toLowerCase().trim();
  switch (statusString) {
    case 'allotted':
      return TaskStatus.allotted;
    case 'completed':
      return TaskStatus.completed;
    case 'awaiting':
      return TaskStatus.awaiting;
    case 're-allotted':
    case 'reallotted':
      return TaskStatus.reallotted;
    default:
      return TaskStatus.awaiting;
  }
}

TaskPriority _parsePriority(String? priorityString) {
  priorityString = priorityString?.toLowerCase().trim();
  switch (priorityString) {
    case 'high':
      return TaskPriority.high;
    case 'medium':
      return TaskPriority.medium;
    case 'low':
      return TaskPriority.low;
    default:
      return TaskPriority.medium;
  }
}

String statusToString(TaskStatus? status) {
  if (status == null) return 'Unknown';
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

Color statusToColor(TaskStatus? status) {
  if (status == null) return Colors.grey;
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

String priorityToString(TaskPriority? priority) {
  if (priority == null) return 'Medium';
  switch (priority) {
    case TaskPriority.high:
      return 'High';
    case TaskPriority.medium:
      return 'Medium';
    case TaskPriority.low:
      return 'Low';
  }
}

Color priorityToColor(TaskPriority? priority) {
  if (priority == null) return Colors.orange.shade600;
  switch (priority) {
    case TaskPriority.high:
      return Colors.red.shade600;
    case TaskPriority.medium:
      return Colors.orange.shade600;
    case TaskPriority.low:
      return Colors.green.shade600;
  }
}

String formatTaskDate(DateTime? date, {String format = 'dd-MM-yyyy'}) {
  if (date == null) {
    return 'N/A';
  }

  try {
    return DateFormat(format).format(date);
  } catch (e) {
    print("Error formatting date: $e");
    return date.toIso8601String().substring(0, 10);
  }
}
