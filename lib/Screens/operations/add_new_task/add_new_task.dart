import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../components/common_appbar.dart';
import '../../../components/drawer.dart';
import '../../../modal/operations/financial_year.dart';
import '../../../modal/operations/staff_modal.dart';
import '../../../modal/operations/sub_task_modal.dart';
import '../../../modal/operations/task_modal.dart';
import '../../../modal/operations/client_modal.dart';

import 'add_dialog_box.dart';
import 'add_new_task_page_content.dart';
import 'add_task_api_services.dart';

class AddNewTaskPage extends StatefulWidget {
  const AddNewTaskPage({super.key});

  @override
  State<AddNewTaskPage> createState() => _AddNewTaskPageState();
}

class _AddNewTaskPageState extends State<AddNewTaskPage> {
  Task? _selectedTaskData;
  Client? _selectedClientData;
  Staff? _selectedStaffData;
  SubTask? _selectedSubTaskData;
  FinancialYear? _selectedFYearData;

  String? _selectedFromMonth;
  String? _selectedToMonth;
  String? _selectedPriority = 'Medium';
  bool _isVerifiedByAdmin = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _taskInstructionController =
      TextEditingController();
  final TextEditingController _allottedDateController = TextEditingController();
  final TextEditingController _expectedDateController = TextEditingController();
  final TextEditingController _allottedByController = TextEditingController(
    text: 'Pragma Admin',
  );

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<Task> _taskList = [];
  List<Client> _clientList = [];
  List<Staff> _staffList = [];
  List<FinancialYear> _FYearList = [];
  List<SubTask> _subTaskList = [];

  bool _isTasksLoading = false;
  bool _isClientsLoading = false;
  bool _isStaffsLoading = false;
  bool _isFYearLoading = false;
  bool _isSubTasksLoading = false;
  bool _isLoading = false;

  final List<String> _monthOptions = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final List<String> _priorityOptions = ['High', 'Medium', 'Low'];

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    print("--- AddNewTaskPage initState START ---");
    super.initState();
    final initialDate = DateTime.now();
    _allottedDateController.text = DateFormat('dd-MM-yyyy').format(initialDate);
    _expectedDateController.text = DateFormat('dd-MM-yyyy').format(initialDate);
    print("--- AddNewTaskPage initState calling _loadInitialData ---");
    _loadInitialData();
    print("--- AddNewTaskPage initState END ---");
  }

  void _loadInitialData() {
    print("--- _loadInitialData START ---");
    _fetchTasks();
    _fetchClient();
    _fetchstaff();
    _fetchfinancialyear();
    print("--- _loadInitialData END ---");
  }

  @override
  void dispose() {
    _taskInstructionController.dispose();
    _allottedDateController.dispose();
    _expectedDateController.dispose();
    _allottedByController.dispose();
    super.dispose();
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;

    final displayMessage =
        message.toLowerCase().startsWith('failed') ||
                message.toLowerCase().startsWith('error')
            ? message
            : 'Error: $message';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(displayMessage), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _fetchTasks() async {
    print("--- _fetchTasks START ---");
    setState(() {
      _isTasksLoading = true;
      _taskList = [];
      _selectedTaskData = null;
      _subTaskList = [];
      _selectedSubTaskData = null;
    });
    try {
      print("--- _fetchTasks calling _apiService.fetchTasks ---");
      final tasks = await _apiService.fetchTasks();
      print(
        "--- _fetchTasks API call successful, Tasks received: ${tasks.length} ---",
      );
      if (mounted) {
        setState(() {
          _taskList = tasks;
          print("--- _fetchTasks TaskList updated in state ---");
        });
      }
    } catch (e) {
      print("--- _fetchTasks CATCH BLOCK ERROR: $e ---");
      if (mounted) {
        _showErrorSnackbar('Failed to load tasks: ${e.toString()}');
        setState(() {
          _taskList = [];
        });
      }
    } finally {
      print("--- _fetchTasks FINALLY block ---");
      if (mounted) {
        setState(() {
          _isTasksLoading = false;
          print("--- _fetchTasks setting _isTasksLoading to false ---");
        });
      }
    }
  }

  Future<void> _fetchSubTasks(String taskId) async {
    print("--- _fetchSubTasks START for Task ID: $taskId ---");
    if (taskId.isEmpty) {
      if (mounted)
        _showErrorSnackbar("Cannot fetch sub-tasks: Invalid Task ID.");
      setState(() {
        _subTaskList = [];
        _selectedSubTaskData = null;
        _isSubTasksLoading = false;
      });
      return;
    }
    setState(() {
      _isSubTasksLoading = true;
      _subTaskList = [];
      _selectedSubTaskData = null;
    });
    try {
      print(
        "--- _fetchSubTasks calling _apiService.fetchSubTasks with Task ID: $taskId ---",
      );

      final subTasks = await _apiService.fetchSubTasks(taskId);
      print(
        "--- _fetchSubTasks API call successful, SubTasks received: ${subTasks.length} ---",
      );
      if (mounted) {
        setState(() {
          _subTaskList = subTasks;
          print("--- _fetchSubTasks SubTaskList updated in state ---");
        });
      }
    } catch (e) {
      print("--- _fetchSubTasks CATCH BLOCK ERROR: $e ---");
      if (mounted) {
        _showErrorSnackbar('Failed to load sub-tasks: ${e.toString()}');
        setState(() {
          _subTaskList = [];
        });
      }
    } finally {
      print("--- _fetchSubTasks FINALLY block for Task ID: $taskId ---");
      if (mounted) {
        setState(() {
          _isSubTasksLoading = false;
          print("--- _fetchSubTasks setting _isSubTasksLoading to false ---");
        });
      }
    }
  }

  Future<void> _fetchClient() async {
    print("--- _fetchClient START ---");
    setState(() => _isClientsLoading = true);
    try {
      final clients = await _apiService.fetchClients();
      if (mounted) setState(() => _clientList = clients);
    } catch (e) {
      if (mounted)
        _showErrorSnackbar('Failed to load clients: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isClientsLoading = false);
    }
  }

  Future<void> _fetchstaff() async {
    print("--- _fetchstaff START ---");
    setState(() => _isStaffsLoading = true);
    try {
      final staff = await _apiService.fetchStaff();
      if (mounted) setState(() => _staffList = staff);
    } catch (e) {
      if (mounted) _showErrorSnackbar('Failed to load staff: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isStaffsLoading = false);
    }
  }

  Future<void> _fetchfinancialyear() async {
    print("--- _fetchfinancialyear START ---");
    setState(() => _isFYearLoading = true);
    try {
      final fYears = await _apiService.fetchFinancialYears();
      if (mounted) setState(() => _FYearList = fYears);
    } catch (e) {
      if (mounted)
        _showErrorSnackbar('Failed to load financial years: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isFYearLoading = false);
    }
  }

  Future<void> _submitTask() async {
    print("--- _submitTask START ---");
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackbar('Please fix the errors in the form');
      return;
    }

    final String? taskid = _selectedTaskData?.Taskid;
    final String? subid = _selectedSubTaskData?.subtaskid;
    final String? client_id = _selectedClientData?.client_id;
    final String? allottedToId = _selectedStaffData?.staff_id;
    final String? financialYearId = _selectedFYearData?.financial_year_id;
    const String allottedById = "1";
    const String senderId = "1";
    const String senderType = "superadmin";

    if ([
      taskid,
      subid,
      client_id,
      allottedToId,
      financialYearId,
      _selectedFromMonth,
      _selectedToMonth,
      _selectedPriority,
    ].any((val) => val == null || val.isEmpty)) {
      print("--- Validation Error: Missing required fields ---");
      print("Task ID: $taskid");
      print("SubTask ID: $subid");
      print("Client ID: $client_id");
      print("Allotted To ID: $allottedToId");
      print("Financial Year ID: $financialYearId");
      print("From Month: $_selectedFromMonth");
      print("To Month: $_selectedToMonth");
      print("Priority: $_selectedPriority");
      _showErrorSnackbar('Error: Missing required selections.');
      return;
    }

    String formattedAllottedDate = '';
    String formattedExpectedDate = '';
    try {
      final DateFormat apiDateFormat = DateFormat('yyyy-MM-dd');
      final DateFormat inputFormat = DateFormat('dd-MM-yyyy');

      if (_allottedDateController.text.isNotEmpty) {
        formattedAllottedDate = apiDateFormat.format(
          inputFormat.parseStrict(_allottedDateController.text),
        );
      } else {
        _showErrorSnackbar('Error: Allotted Date cannot be empty.');
        return;
      }
      if (_expectedDateController.text.isNotEmpty) {
        formattedExpectedDate = apiDateFormat.format(
          inputFormat.parseStrict(_expectedDateController.text),
        );
      } else {
        _showErrorSnackbar('Error: Expected End Date cannot be empty.');
        return;
      }
    } catch (e) {
      print("Error formatting dates: $e");
      _showErrorSnackbar('Error: Invalid date format (use DD-MM-YYYY).');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final Map<String, String> taskData = {
      "client_id": client_id!,
      "task_id": taskid!,
      "sub_task_id": subid!,
      "alloted_to": allottedToId!,
      "alloted_by": allottedById,
      "financial_year_id": financialYearId!,
      "month_from": _selectedFromMonth!,
      "month_to": _selectedToMonth!,
      "instruction": _taskInstructionController.text,
      "alloted_date": formattedAllottedDate,
      "expected_end_date": formattedExpectedDate,
      "priority": _selectedPriority!,
      "verify_by_admin": _isVerifiedByAdmin ? "1" : "0",
      "sender_id": senderId,
      "sender_type": senderType,
    };

    try {
      print(
        "--- _submitTask calling _apiService.submitTask with data: $taskData ---",
      );

      final successMessage = await _apiService.submitTask(taskData);
      if (mounted) {
        _showSuccessSnackbar(successMessage);

        Navigator.of(context).pop();
      }
    } catch (e) {
      print("--- _submitTask CATCH BLOCK ERROR: $e ---");
      if (mounted) {
        _showErrorSnackbar(e.toString());
      }
    } finally {
      print("--- _submitTask FINALLY block ---");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime initial;
    try {
      initial =
          controller.text.isNotEmpty
              ? DateFormat('dd-MM-yyyy').parseStrict(controller.text)
              : DateTime.now();
    } catch (e) {
      initial = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final String formattedDate = DateFormat('dd-MM-yyyy').format(picked);

      controller.text = formattedDate;
    }
  }

  void _showAddTaskDialog() {
    print("--- _showAddTaskDialog called ---");
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AddTaskDialog(
          onSave: (newTaskName) async {
            print(
              "--- AddTaskDialog reported success for name: $newTaskName ---",
            );
            print("--- Refreshing task list to get the real Task object ---");

            setState(() {
              _isTasksLoading = true;
            });

            try {
              await _fetchTasks();

              if (!mounted) return;

              final Task? newlyAddedTask = _taskList.firstWhereOrNull(
                (task) => task.TaskName == newTaskName,
              );

              if (newlyAddedTask != null) {
                print(
                  "--- Found newly added task with real ID: ${newlyAddedTask.Taskid} ---",
                );
                setState(() {
                  _selectedTaskData = newlyAddedTask;
                  _subTaskList = [];
                  _selectedSubTaskData = null;
                  _isSubTasksLoading = false;
                });
                _fetchSubTasks(newlyAddedTask.Taskid);
                _showSuccessSnackbar('Task "$newTaskName" added and selected.');
              } else {
                print(
                  "--- ERROR: Newly added task '$newTaskName' not found after refresh! ---",
                );
                _showErrorSnackbar(
                  "Task added, but failed to re-select it. Please select manually.",
                );
                setState(() {
                  _selectedTaskData = null;
                  _subTaskList = [];
                  _selectedSubTaskData = null;
                  _isSubTasksLoading = false;
                });
              }
            } catch (e) {
              print("--- Error during post-add task refresh: $e ---");
              if (mounted) {
                _showErrorSnackbar(
                  "Task added, but failed to refresh list: ${e.toString()}",
                );
                setState(() {
                  _isTasksLoading = false;
                });
              }
            }
          },
        );
      },
    );
  }

  void _showAddSubTaskDialog() {
    print("--- _showAddSubTaskDialog called ---");

    if (_taskList.isEmpty && !_isTasksLoading) {
      _showErrorSnackbar("Please add a Task first or wait for tasks to load.");
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AddSubTaskDialog(
          availableTasks: _taskList,
          isTasksLoading: _isTasksLoading,
          onSave: (parentTask, newSubTaskName) async {
            print(
              "--- AddSubTaskDialog onSave triggered for parent '${parentTask.TaskName}' with name: $newSubTaskName ---",
            );

            try {
              await Future.delayed(const Duration(milliseconds: 500));

              final newSubTask = SubTask(
                subtaskid: DateTime.now().millisecondsSinceEpoch.toString(),
                taskId: parentTask.Taskid,
                subTaskName: newSubTaskName,
              );

              if (!mounted) return;

              if (_selectedTaskData != null &&
                  _selectedTaskData!.Taskid == parentTask.Taskid) {
                setState(() {
                  _subTaskList.add(newSubTask);
                  _selectedSubTaskData = newSubTask;
                  print(
                    "--- SubTaskList updated in state for matching parent, new sub-task selected ---",
                  );
                });
              } else {
                print(
                  "--- SubTask added for '${parentTask.TaskName}', but main selection is '${_selectedTaskData?.TaskName}'. List not visually updated. ---",
                );
              }

              _showSuccessSnackbar(
                'Sub Task "$newSubTaskName" added to "${parentTask.TaskName}"!',
              );
            } catch (e) {
              print("--- Error saving new sub-task via API: $e ---");
              if (mounted) {
                _showErrorSnackbar('Failed to add sub-task: ${e.toString()}');
              }
            }
          },
        );
      },
    );
  }

  // In _AddNewTaskPageState class

  // Ensure collection package is imported for firstWhereOrNull
  // import 'package:collection/collection.dart';

  void _showAddStaffDialog() {
    print("--- _showAddStaffDialog called ---");
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext dialogContext) {
        return AddStaffDialog(
          // onSave is called AFTER the API call in AddStaffDialog succeeds
          onSave: (newStaffName) async {
            print(
              "--- AddStaffDialog reported success for name: $newStaffName ---",
            );
            print("--- Refreshing Staff list to get the real Staff object ---");

            // Show loading indicator for the staff dropdown while refreshing
            setState(() {
              _isStaffsLoading = true;
              _selectedStaffData = null; // Clear selection during load
            });

            try {
              // ** CRUCIAL: Re-fetch the staff list from the API **
              await _fetchstaff(); // This updates _staffList

              if (!mounted) return; // Check mounted state after async operation

              // ** Find the newly added staff member using staff_name **
              final Staff? newlyAddedStaff = _staffList.firstWhereOrNull(
                // Use the correct field name from your Staff model
                (staff) => staff.staff_name == newStaffName,
              );

              if (newlyAddedStaff != null) {
                // ** Found the staff member with the real ID **
                print(
                  // Use the correct field name for logging
                  "--- Found newly added Staff with real ID: ${newlyAddedStaff.staff_id} ---",
                );
                // ** Update state to select the REAL staff object **
                setState(() {
                  _selectedStaffData = newlyAddedStaff;
                  // No sub-staff logic needed here
                });
                _showSuccessSnackbar(
                  'Staff "$newStaffName" added and selected.',
                );
              } else {
                // Staff wasn't found after refresh (unlikely but possible)
                print(
                  "--- ERROR: Newly added Staff '$newStaffName' not found after refresh! ---",
                );
                _showErrorSnackbar(
                  "Staff added, but failed to auto-select. Please select manually.",
                );
                // Keep the list populated, just clear the selection
                setState(() {
                  _selectedStaffData = null;
                });
              }
            } catch (e) {
              print("--- Error during post-add Staff refresh: $e ---");
              if (mounted) {
                _showErrorSnackbar(
                  "Staff added, but failed to refresh list: ${e.toString()}",
                );
              }
              // Ensure loading stops even if refresh fails
              // _fetchstaff should ideally handle its own loading state,
              // but we set it false here just in case.
            } finally {
              // Make sure loading indicator stops
              if (mounted) {
                setState(() {
                  _isStaffsLoading = false;
                });
              }
            }
          },
        );
      },
    );
  }

  void _showAddFYearDialog() {
    print("Add Financial Year button pressed - Functionality not implemented.");
    _showErrorSnackbar(
      "Add Financial Year functionality is not yet available.",
    );
  }

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add New Task',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D47A1),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Home / Tasks / Add New Task',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Builder(
          builder: (appBarContext) {
            return CommonAppBar(
              onMenuPressed: () => Scaffold.of(appBarContext).openDrawer(),
              onNotificationPressed: () => print("Notifications Pressed"),
              onProfilePressed: () => print("Profile Pressed"),
            );
          },
        ),
      ),
      drawer: const AnimatedDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPageHeader(),
              const SizedBox(height: 20),

              TaskFormContent(
                formKey: _formKey,

                taskList: _taskList,
                subTaskList: _subTaskList,
                clientList: _clientList,
                staffList: _staffList,
                fYearList: _FYearList,
                monthOptions: _monthOptions,
                priorityOptions: _priorityOptions,

                selectedTaskData: _selectedTaskData,
                selectedSubTaskData: _selectedSubTaskData,
                selectedClientData: _selectedClientData,
                selectedStaffData: _selectedStaffData,
                selectedFYearData: _selectedFYearData,
                selectedFromMonth: _selectedFromMonth,
                selectedToMonth: _selectedToMonth,
                selectedPriority: _selectedPriority,
                isVerifiedByAdmin: _isVerifiedByAdmin,

                isTasksLoading: _isTasksLoading,
                isSubTasksLoading: _isSubTasksLoading,
                isClientsLoading: _isClientsLoading,
                isStaffsLoading: _isStaffsLoading,
                isFYearLoading: _isFYearLoading,
                isLoading: _isLoading,

                taskInstructionController: _taskInstructionController,
                allottedDateController: _allottedDateController,
                expectedDateController: _expectedDateController,
                allottedByController: _allottedByController,

                onTaskChanged: (Task? newValue) {
                  if (newValue != null &&
                      newValue.Taskid != _selectedTaskData?.Taskid) {
                    print(
                      "Task Changed Handler: New Task selected - ID ${newValue.Taskid}",
                    );
                    setState(() {
                      _selectedTaskData = newValue;
                      _selectedSubTaskData = null;
                      _subTaskList = [];
                      _isSubTasksLoading = true;
                    });
                    _fetchSubTasks(newValue.Taskid);
                  } else if (newValue == null && _selectedTaskData != null) {
                    print("Task Changed Handler: Task deselected");
                    setState(() {
                      _selectedTaskData = null;
                      _selectedSubTaskData = null;
                      _subTaskList = [];
                      _isSubTasksLoading = false;
                    });
                  }
                },
                onSubTaskChanged: (SubTask? newValue) {
                  if (newValue != _selectedSubTaskData) {
                    print(
                      "SubTask Changed Handler: New SubTask selected - ID ${newValue?.subtaskid}",
                    );
                    setState(() => _selectedSubTaskData = newValue);
                  }
                },
                onClientChanged: (Client? newValue) {
                  if (newValue != _selectedClientData) {
                    print(
                      "Client Changed Handler: New Client selected - ID ${newValue?.client_id}",
                    );
                    setState(() => _selectedClientData = newValue);
                  }
                },
                onStaffChanged: (Staff? newValue) {
                  if (newValue != _selectedStaffData) {
                    print(
                      "Staff Changed Handler: New Staff selected - ID ${newValue?.staff_id}",
                    );
                    setState(() => _selectedStaffData = newValue);
                  }
                },
                onFYearChanged: (FinancialYear? newValue) {
                  if (newValue != _selectedFYearData) {
                    print(
                      "FYear Changed Handler: New FYear selected - ID ${newValue?.financial_year_id}",
                    );
                    setState(() => _selectedFYearData = newValue);
                  }
                },
                onFromMonthChanged: (String? value) {
                  if (value != _selectedFromMonth) {
                    print("From Month Changed Handler: $value");
                    setState(() => _selectedFromMonth = value);
                  }
                },
                onToMonthChanged: (String? value) {
                  if (value != _selectedToMonth) {
                    print("To Month Changed Handler: $value");
                    setState(() => _selectedToMonth = value);
                  }
                },
                onPriorityChanged: (String? value) {
                  if (value != _selectedPriority) {
                    print("Priority Changed Handler: $value");
                    setState(() => _selectedPriority = value);
                  }
                },
                onVerifiedByAdminChanged: (bool? value) {
                  final newValue = value ?? false;
                  if (newValue != _isVerifiedByAdmin) {
                    print("Verified Changed Handler: $newValue");
                    setState(() => _isVerifiedByAdmin = newValue);
                  }
                },
                selectDate: _selectDate,
                onSubmit: _submitTask,
                onCancel: () {
                  print("Cancel button pressed");

                  Navigator.of(context).pop();
                },

                onAddTaskPressed: _showAddTaskDialog,
                onAddSubTaskPressed: _showAddSubTaskDialog,
                onAddStaffPressed: _showAddStaffDialog,
                onAddFYearPressed: _showAddFYearDialog,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
