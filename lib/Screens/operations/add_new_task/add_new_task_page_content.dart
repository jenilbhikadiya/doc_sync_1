import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../modal/operations/financial_year.dart';
import '../../../modal/operations/staff_modal.dart';
import '../../../modal/operations/sub_task_modal.dart';
import '../../../modal/operations/task_modal.dart';
import '../../../modal/operations/client_modal.dart';

class TaskFormContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  final List<Task> taskList;
  final List<SubTask> subTaskList;
  final List<Client> clientList;
  final List<Staff> staffList;
  final List<FinancialYear> fYearList;
  final List<String> monthOptions;
  final List<String> priorityOptions;

  final Task? selectedTaskData;
  final SubTask? selectedSubTaskData;
  final Client? selectedClientData;
  final Staff? selectedStaffData;
  final FinancialYear? selectedFYearData;
  final String? selectedFromMonth;
  final String? selectedToMonth;
  final String? selectedPriority;
  final bool isVerifiedByAdmin;

  final bool isTasksLoading;
  final bool isSubTasksLoading;
  final bool isClientsLoading;
  final bool isStaffsLoading;
  final bool isFYearLoading;
  final bool isLoading;

  final TextEditingController taskInstructionController;
  final TextEditingController allottedDateController;
  final TextEditingController expectedDateController;
  final TextEditingController allottedByController;

  final ValueChanged<Task?> onTaskChanged;
  final ValueChanged<SubTask?> onSubTaskChanged;
  final ValueChanged<Client?> onClientChanged;
  final ValueChanged<Staff?> onStaffChanged;
  final ValueChanged<FinancialYear?> onFYearChanged;
  final ValueChanged<String?> onFromMonthChanged;
  final ValueChanged<String?> onToMonthChanged;
  final ValueChanged<String?> onPriorityChanged;
  final ValueChanged<bool?> onVerifiedByAdminChanged;
  final Future<void> Function(BuildContext, TextEditingController) selectDate;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  final VoidCallback? onAddTaskPressed;
  final VoidCallback? onAddSubTaskPressed;
  final VoidCallback? onAddFYearPressed;
  final VoidCallback? onAddStaffPressed;

  const TaskFormContent({
    super.key,
    required this.formKey,
    required this.taskList,
    required this.subTaskList,
    required this.clientList,
    required this.staffList,
    required this.fYearList,
    required this.monthOptions,
    required this.priorityOptions,
    required this.selectedTaskData,
    required this.selectedSubTaskData,
    required this.selectedClientData,
    required this.selectedStaffData,
    required this.selectedFYearData,
    required this.selectedFromMonth,
    required this.selectedToMonth,
    required this.selectedPriority,
    required this.isVerifiedByAdmin,
    required this.isTasksLoading,
    required this.isSubTasksLoading,
    required this.isClientsLoading,
    required this.isStaffsLoading,
    required this.isFYearLoading,
    required this.isLoading,
    required this.taskInstructionController,
    required this.allottedDateController,
    required this.expectedDateController,
    required this.allottedByController,
    required this.onTaskChanged,
    required this.onSubTaskChanged,
    required this.onClientChanged,
    required this.onStaffChanged,
    required this.onFYearChanged,
    required this.onFromMonthChanged,
    required this.onToMonthChanged,
    required this.onPriorityChanged,
    required this.onVerifiedByAdminChanged,
    required this.selectDate,
    required this.onSubmit,
    required this.onCancel,
    this.onAddTaskPressed,
    this.onAddSubTaskPressed,
    this.onAddFYearPressed,
    this.onAddStaffPressed,
  });

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0D47A1),
        ),
      ),
    );
  }

  Widget _buildAddButton({VoidCallback? onPressed}) {
    return SizedBox(
      width: 40,
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed ?? () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE8F5E9),
          foregroundColor: const Color(0xFF388E3C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: EdgeInsets.zero,
          elevation: 0,
        ),
        child: const Icon(Icons.add, size: 24),
      ),
    );
  }

  InputDecoration _dropdownDecoration(
    String hintText, {
    bool isLoading = false,
  }) {
    return InputDecoration(
      hintText: isLoading ? "Loading..." : hintText,
      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 12.0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
    );
  }

  InputDecoration _textFieldDecoration({String? hintText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 12.0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      suffixIcon: suffixIcon,
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildSectionTitle(title), const SizedBox(height: 8), child],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double horizontalGap = 12.0;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'Task Details',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DropdownButtonFormField<Task>(
                    value: selectedTaskData,
                    items:
                        taskList
                            .map(
                              (task) => DropdownMenuItem<Task>(
                                value: task,
                                child: Text(
                                  task.TaskName,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: isTasksLoading ? null : onTaskChanged,
                    decoration: _dropdownDecoration(
                      'Select Task',
                      isLoading: isTasksLoading,
                    ),
                    validator:
                        (value) => value == null ? 'Task is required' : null,
                    isExpanded: true,
                    hint:
                        isTasksLoading
                            ? const Text("Loading Tasks...")
                            : taskList.isEmpty
                            ? const Text("No tasks found")
                            : const Text("Select Task"),
                    disabledHint:
                        isTasksLoading ? const Text("Loading...") : null,
                  ),
                ),
                const SizedBox(width: horizontalGap),
                Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: _buildAddButton(onPressed: onAddTaskPressed),
                ),
                const SizedBox(width: horizontalGap),
                Expanded(
                  child: DropdownButtonFormField<SubTask>(
                    value: selectedSubTaskData,
                    items:
                        subTaskList
                            .map(
                              (subTask) => DropdownMenuItem<SubTask>(
                                value: subTask,
                                child: Text(
                                  subTask.subTaskName,
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (selectedTaskData == null || isSubTasksLoading)
                            ? null
                            : onSubTaskChanged,
                    decoration: _dropdownDecoration(
                      selectedTaskData == null
                          ? 'Select Task First'
                          : 'Select Sub Task',
                      isLoading: isSubTasksLoading,
                    ),
                    validator:
                        (value) =>
                            value == null ? 'Sub Task is required' : null,
                    isExpanded: true,
                    hint:
                        isSubTasksLoading
                            ? const Text("Loading Sub-Tasks...")
                            : selectedTaskData == null
                            ? const Text("Select Task First")
                            : subTaskList.isEmpty && !isSubTasksLoading
                            ? const Text("No sub-tasks")
                            : const Text("Select Sub Task"),
                    disabledHint:
                        selectedTaskData == null
                            ? const Text("Select Task First")
                            : isSubTasksLoading
                            ? const Text("Loading...")
                            : null,
                  ),
                ),
                const SizedBox(width: horizontalGap),
                Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: _buildAddButton(onPressed: onAddSubTaskPressed),
                ),
              ],
            ),
          ),

          _buildSectionCard(
            title: 'Client',
            child: DropdownButtonFormField<Client>(
              value: selectedClientData,
              items:
                  clientList
                      .map(
                        (client) => DropdownMenuItem<Client>(
                          value: client,
                          child: Text(
                            client.firm_name,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      )
                      .toList(),
              onChanged: isClientsLoading ? null : onClientChanged,
              decoration: _dropdownDecoration(
                'Select Client',
                isLoading: isClientsLoading,
              ),
              validator: (value) => value == null ? 'Client is required' : null,
              isExpanded: true,
              hint:
                  isClientsLoading
                      ? const Text("Loading Clients...")
                      : clientList.isEmpty
                      ? const Text("No Clients found")
                      : const Text("Select Client"),
              disabledHint: isClientsLoading ? const Text("Loading...") : null,
            ),
          ),

          _buildSectionCard(
            title: 'Allotment',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Allotted To'),
                      DropdownButtonFormField<Staff>(
                        value: selectedStaffData,
                        items:
                            staffList
                                .map(
                                  (staff) => DropdownMenuItem<Staff>(
                                    value: staff,
                                    child: Text(
                                      staff.staff_name,
                                      style: const TextStyle(fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: isStaffsLoading ? null : onStaffChanged,
                        decoration: _dropdownDecoration(
                          'Select Staff/Group',
                          isLoading: isStaffsLoading,
                        ),
                        validator: (value) => value == null ? 'Required' : null,
                        isExpanded: true,
                        hint:
                            isStaffsLoading
                                ? const Text("Loading Staff...")
                                : staffList.isEmpty
                                ? const Text("No Staff found")
                                : const Text("Select Staff/Group"),
                        disabledHint:
                            isStaffsLoading ? const Text("Loading...") : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: horizontalGap),
                Padding(
                  padding: const EdgeInsets.only(top: 22.0),
                  child: _buildAddButton(onPressed: onAddStaffPressed),
                ),
                const SizedBox(width: horizontalGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Allotted By'),
                      TextFormField(
                        controller: allottedByController,
                        readOnly: true,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        decoration: _textFieldDecoration(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          _buildSectionCard(
            title: 'Period',
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<FinancialYear>(
                        value: selectedFYearData,
                        items:
                            fYearList
                                .map(
                                  (financialYear) =>
                                      DropdownMenuItem<FinancialYear>(
                                        value: financialYear,
                                        child: Text(
                                          financialYear.financial_year,
                                          style: const TextStyle(fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                )
                                .toList(),
                        onChanged: isFYearLoading ? null : onFYearChanged,
                        decoration: _dropdownDecoration(
                          'Select Financial Year',
                          isLoading: isFYearLoading,
                        ),
                        validator: (value) => value == null ? 'Required' : null,
                        isExpanded: true,
                        hint:
                            isFYearLoading
                                ? const Text("Loading Financial Year...")
                                : fYearList.isEmpty
                                ? const Text("No Financial Year found")
                                : const Text("Select Financial Year"),
                        disabledHint:
                            isFYearLoading ? const Text("Loading...") : null,
                      ),
                    ),
                    const SizedBox(width: horizontalGap),
                    Padding(
                      padding: const EdgeInsets.only(top: 0.0),
                      child: _buildAddButton(onPressed: onAddFYearPressed),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('From'),
                          DropdownButtonFormField<String>(
                            value: selectedFromMonth,
                            items:
                                monthOptions
                                    .map(
                                      (label) => DropdownMenuItem(
                                        value: label,
                                        child: Text(
                                          label,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged: onFromMonthChanged,
                            decoration: _dropdownDecoration('Select Month'),
                            validator:
                                (value) => value == null ? 'Required' : null,
                            isExpanded: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: horizontalGap),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('To'),
                          DropdownButtonFormField<String>(
                            value: selectedToMonth,
                            items:
                                monthOptions
                                    .map(
                                      (label) => DropdownMenuItem(
                                        value: label,
                                        child: Text(
                                          label,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged: onToMonthChanged,
                            decoration: _dropdownDecoration('Select Month'),
                            validator:
                                (value) => value == null ? 'Required' : null,
                            isExpanded: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          _buildSectionCard(
            title: 'Task Instruction',
            child: TextFormField(
              controller: taskInstructionController,
              maxLines: 4,
              minLines: 4,
              style: const TextStyle(fontSize: 14),
              decoration: _textFieldDecoration(
                hintText: 'Enter Task Details...',
              ).copyWith(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 12.0,
                ),
              ),
            ),
          ),

          _buildSectionCard(
            title: 'Dates',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Allotted Date'),
                      TextFormField(
                        controller: allottedDateController,
                        readOnly: true,
                        style: const TextStyle(fontSize: 14),
                        decoration: _textFieldDecoration(
                          suffixIcon: Icon(
                            Icons.calendar_today,
                            color: Colors.teal.shade400,
                            size: 18,
                          ),
                        ),
                        onTap:
                            () => selectDate(context, allottedDateController),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Date required'
                                    : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: horizontalGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Expected End Date'),
                      TextFormField(
                        controller: expectedDateController,
                        readOnly: true,
                        style: const TextStyle(fontSize: 14),
                        decoration: _textFieldDecoration(
                          suffixIcon: Icon(
                            Icons.calendar_today,
                            color: Colors.teal.shade400,
                            size: 18,
                          ),
                        ),
                        onTap:
                            () => selectDate(context, expectedDateController),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Date required'
                                    : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          _buildSectionCard(
            title: 'Priority & Verification',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('Priority'),
                DropdownButtonFormField<String>(
                  value: selectedPriority,
                  items:
                      priorityOptions
                          .map(
                            (label) => DropdownMenuItem(
                              value: label,
                              child: Text(
                                label,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: onPriorityChanged,
                  decoration: _dropdownDecoration('Medium'),
                  validator:
                      (value) => value == null ? 'Priority is required' : null,
                  isExpanded: true,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  child: CheckboxListTile(
                    title: const Text(
                      'Verify By Admin',
                      style: TextStyle(fontSize: 14),
                    ),
                    value: isVerifiedByAdmin,
                    onChanged: onVerifiedByAdminChanged,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: Colors.green.shade600,
                    dense: true,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: isLoading ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  disabledBackgroundColor: Colors.grey.shade400,
                ),
                child:
                    isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.0,
                          ),
                        )
                        : const Text('Save'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: isLoading ? null : onCancel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC62828),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  disabledBackgroundColor: Colors.grey.shade400,
                ),
                child: const Text('Close'),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
