class SubTask {
  final String subtaskid;
  final String subTaskName;

  SubTask({required this.subtaskid, required this.subTaskName});

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      subtaskid: json['id'] as String? ?? '',
      subTaskName: json['sub_task_name'] as String? ?? 'Unknown SubTask',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubTask &&
          runtimeType == other.runtimeType &&
          subtaskid == other.subtaskid;

  @override
  int get hashCode => subtaskid.hashCode;
}
