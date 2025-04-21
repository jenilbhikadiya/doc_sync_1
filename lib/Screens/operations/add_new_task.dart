import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../components/common_appbar.dart';
import '../../components/drawer.dart';
import '../../modal/operations/sub_task_modal.dart';
import '../../modal/operations/task_modal.dart';
import '../../modal/operations/client_modal.dart';
import '../../utils/constants.dart';

class AddNewTaskPage extends StatefulWidget {
  const AddNewTaskPage({super.key});

  @override
  State<AddNewTaskPage> createState() => _AddNewTaskPageState();
}

class _AddNewTaskPageState extends State<AddNewTaskPage> {
  Task? _selectedTaskData;
  Client? _selectedClientData;
  SubTask? _selectedSubTaskData;
  String? _selectedClient;
  String? _selectedAllottedTo;
  String? _selectedFinancialYear;
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
  List<SubTask> _subTaskList = [];

  bool _isTasksLoading = false;
  bool _isClientsLoading = false;
  bool _isSubTasksLoading = false;
  bool _isLoading = false;

  final List<String> _allottedToOptions = [
    'admin1',
    'Staff1',
    'staff2',
    'staff9',
  ];
  final List<String> _financialYearOptions = [
    '2024-2025',
    '2023-2024',
    '2022-2023',
    '2018-2019',
  ];
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

  final Map<String, String> _allottedToNameToIdMap = {
    'admin1': '1',
    'Staff1': '10',
    'staff2': '11',
    'staff9': '12',
  };
  final Map<String, String> _financialYearToIdMap = {
    '2024-2025': '3',
    '2023-2024': '2',
    '2022-2023': '1',
    '2018-2019': '4',
  };

  @override
  void initState() {
    super.initState();
    final initialDate = DateTime.now();
    _allottedDateController.text = DateFormat('dd-MM-yyyy').format(initialDate);
    _expectedDateController.text = DateFormat('dd-MM-yyyy').format(initialDate);
    _fetchTasks();
    _fetchClient();
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _fetchTasks() async {
    setState(() {
      _isTasksLoading = true;
      _taskList = [];
      _selectedTaskData = null;
      _subTaskList = [];
      _selectedSubTaskData = null;
    });
    print("--- Fetching Tasks ---");
    final url = Uri.parse('$baseUrl/get_task_list');
    try {
      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 20));

      print("Fetch Tasks Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (decodedData['success'] == true && decodedData['data'] is List) {
          List<Task> loadedTasks =
              (decodedData['data'] as List)
                  .map((taskJson) => Task.fromJson(taskJson))
                  .toList();

          loadedTasks.sort(
            (a, b) =>
                a.TaskName.toLowerCase().compareTo(b.TaskName.toLowerCase()),
          );
          setState(() {
            _taskList = loadedTasks;
          });
          print("--- Tasks Fetched Successfully (${_taskList.length}) ---");
        } else {
          print("--- Fetch Tasks API Error: ${decodedData['message']} ---");
          _showErrorSnackbar(
            decodedData['message'] ??
                'Failed to load tasks: Invalid data format',
          );
        }
      } else {
        print("--- Fetch Tasks HTTP Error: ${response.statusCode} ---");
        _showErrorSnackbar(
          'Failed to load tasks (HTTP ${response.statusCode})',
        );
      }
    } catch (e) {
      print("--- Fetch Tasks Exception: $e ---");
      _showErrorSnackbar('An error occurred while fetching tasks: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isTasksLoading = false;
        });
      }
    }
  }

  Future<void> _fetchSubTasks(String id) async {
    if (id.isEmpty) {
      print("--- Fetch Sub-Tasks Error: Received empty Task ID ---");
      _showErrorSnackbar("Cannot fetch sub-tasks: Invalid Task ID.");
      setState(() {
        _isSubTasksLoading = false;
        _subTaskList = [];
        _selectedSubTaskData = null;
      });
      return;
    }

    setState(() {
      _isSubTasksLoading = true;
      _subTaskList = [];
      _selectedSubTaskData = null;
    });

    print("--- Fetching Sub-Tasks for Task ID: $id ---");
    final url = Uri.parse('$baseUrl/get_sub_task_list');

    final String innerJsonValue = jsonEncode({'id': id});

    final Map<String, String> formData = {'data': innerJsonValue};

    print("--- Sub-Task Request Body (Form Data): $formData ---");

    try {
      final response = await http
          .post(url, headers: {'Accept': 'application/json'}, body: formData)
          .timeout(const Duration(seconds: 20));

      print("Fetch Sub-Tasks Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (decodedData['success'] == true && decodedData['data'] is List) {
          List<SubTask> loadedSubTasks =
              (decodedData['data'] as List)
                  .map((subTaskJson) => SubTask.fromJson(subTaskJson))
                  .toList();
          loadedSubTasks.sort(
            (a, b) => a.subTaskName.toLowerCase().compareTo(
              b.subTaskName.toLowerCase(),
            ),
          );
          setState(() {
            _subTaskList = loadedSubTasks;
          });
          print(
            "--- Sub-Tasks Fetched Successfully (${_subTaskList.length}) ---",
          );
        } else {
          if (decodedData['success'] == true &&
              decodedData['data'] != null &&
              decodedData['data'].isEmpty) {
            print("--- No Sub-Tasks found for Task ID: $id ---");
            setState(() {
              _subTaskList = [];
            });
          } else {
            print(
              "--- Fetch Sub-Tasks API Error: ${decodedData['message']} ---",
            );
            _showErrorSnackbar(
              decodedData['message'] ??
                  'Failed to load sub-tasks: Invalid data format',
            );
          }
        }
      } else {
        print("--- Fetch Sub-Tasks HTTP Error: ${response.statusCode} ---");
        print("--- Response Body for Error: ${response.body} ---");
        _showErrorSnackbar(
          'Failed to load sub-tasks (HTTP ${response.statusCode})',
        );
      }
    } catch (e) {
      print("--- Fetch Sub-Tasks Exception: $e ---");
      if (e is FormatException) {
        print("--- JSON Parsing Error in Sub-Task Response ---");
        _showErrorSnackbar('Error reading sub-task data from server.');
      } else {
        _showErrorSnackbar('An error occurred while fetching sub-tasks: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubTasksLoading = false;
        });
      }
    }
  }

  Future<void> _fetchClient() async {
    setState(() {
      _isClientsLoading = true;
      // ***** FIX THIS LINE *****
      // _taskList = []; // Incorrect: Clears task list
      _clientList = []; // Correct: Clear client list
      // ***** END FIX *****
      _selectedClientData = null;
    });
    print("--- Fetching Client ---");
    final url = Uri.parse(
      '$baseUrl/get_client_list',
    ); // Make sure baseUrl is defined correctly
    try {
      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 20));

      print("Fetch Client Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (decodedData['success'] == true && decodedData['data'] is List) {
          // Ensure your Client.fromJson matches the API response structure
          List<Client> loadedClients =
              (decodedData['data'] as List)
                  .map((clientJson) => Client.fromJson(clientJson))
                  // .cast<Client>() // .cast is often redundant if .map already returns the correct type
                  .toList();

          // Ensure sorting uses the correct field name from your Client model
          loadedClients.sort(
            (a, b) =>
                a.firm_name.toLowerCase().compareTo(b.firm_name.toLowerCase()),
          );
          setState(() {
            _clientList = loadedClients; // No need for .cast here either
          });
          print("--- Clients Fetched Successfully (${_clientList.length}) ---");
        } else {
          print("--- Fetch Clients API Error: ${decodedData['message']} ---");
          _showErrorSnackbar(
            decodedData['message'] ??
                'Failed to load clients: Invalid data format',
          );
        }
      } else {
        print("--- Fetch Clients HTTP Error: ${response.statusCode} ---");
        print(
          "--- Response Body for Error: ${response.body} ---",
        ); // Log error body
        _showErrorSnackbar(
          'Failed to load clients (HTTP ${response.statusCode})',
        );
      }
    } catch (e) {
      print(
        "--- Fetch Clients Exception: $e ---",
      ); // Changed print message slightly
      _showErrorSnackbar('An error occurred while fetching clients: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isClientsLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime initial = DateTime.now();
    try {
      if (controller.text.isNotEmpty) {
        initial = DateFormat('dd-MM-yyyy').parse(controller.text);
      }
    } catch (e) {
      print("Error parsing date: $e");
      _showErrorSnackbar('Invalid date format entered.');
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D47A1),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Color(0xFF0D47A1)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

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
        onPressed:
            onPressed ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add action TBD'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
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

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add New Task',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColorDark ?? Colors.blue.shade800,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Home / Tasks / Add New Task',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Future<void> _submitTask() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackbar('Please fix the errors in the form');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String? taskid = _selectedTaskData?.Taskid;
    final String? subid = _selectedSubTaskData?.subtaskid;
    final String? clientId = _selectedClient;
    final String? allottedToId = _allottedToNameToIdMap[_selectedAllottedTo];
    final String? financialYearId =
        _financialYearToIdMap[_selectedFinancialYear];
    const String allottedById = "1";
    const String senderId = "1";
    const String senderType = "suparadmin";

    if (taskid == null ||
        subid == null ||
        clientId == null ||
        allottedToId == null ||
        financialYearId == null ||
        _selectedFromMonth == null ||
        _selectedToMonth == null ||
        _selectedPriority == null) {
      print("--- Validation Error ---");
      print(
        "Error: One or more required fields are not selected or mapped correctly.",
      );
      print("Selected Task: ${_selectedTaskData?.TaskName} -> ID: $taskid");
      print(
        "Selected SubTask: ${_selectedSubTaskData?.subTaskName} -> ID: $subid",
      );
      print("Selected Client: $_selectedClient -> ID: $clientId");
      print("Selected Allotted To: $_selectedAllottedTo -> ID: $allottedToId");
      print(
        "Selected Fin Year: $_selectedFinancialYear -> ID: $financialYearId",
      );
      print("Selected From Month: $_selectedFromMonth");
      print("Selected To Month: $_selectedToMonth");
      print("Selected Priority: $_selectedPriority");
      print("-----------------------");
      _showErrorSnackbar('Error: Missing required selections.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    String formattedAllottedDate = '';
    String formattedExpectedDate = '';
    try {
      final DateFormat apiDateFormat = DateFormat('yyyy-MM-dd');
      final DateFormat inputFormat = DateFormat('dd-MM-yyyy');
      if (_allottedDateController.text.isNotEmpty)
        formattedAllottedDate = apiDateFormat.format(
          inputFormat.parse(_allottedDateController.text),
        );
      if (_expectedDateController.text.isNotEmpty)
        formattedExpectedDate = apiDateFormat.format(
          inputFormat.parse(_expectedDateController.text),
        );
    } catch (e) {
      print("Error formatting dates: $e");
      _showErrorSnackbar('Error: Invalid date format entered.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final Map<String, String> requestBody = {
      "client_id": clientId,
      "task_id": taskid,
      "sub_task_id": subid,
      "alloted_to": allottedToId,
      "alloted_by": allottedById,
      "financial_year_id": financialYearId,
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

    print("--- Sending Task Data (Request Body) ---");
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    print(encoder.convert(requestBody));
    print("---------------------------------------");

    final url = Uri.parse('$baseUrl/add_new_taskcreation');

    try {
      print("--- Making POST request to: $url ---");
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      print("--- API Response Received ---");
      print("Status Code: ${response.statusCode}");

      print("Body (Raw): ${response.body}");
      print("--------------------------");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("--- Decoded Response Data ---");
        print(encoder.convert(responseData));
        print("-----------------------------");

        if (responseData['success'] == true) {
          _showSuccessSnackbar(
            responseData['message'] ?? 'Task added successfully!',
          );
        } else {
          _showErrorSnackbar(
            responseData['message'] ?? 'API Error: Failed to add task.',
          );
        }
      } else {
        _showErrorSnackbar(
          'Server Error: ${response.statusCode}. Message: ${response.body}',
        );
      }
    } catch (e) {
      print("--- API Call Failed (Exception) ---");
      print("Error Type: ${e.runtimeType}");
      print("Error: $e");
      print("----------------------------------");
      _showErrorSnackbar('An error occurred: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print("--- Loading state reset ---");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const double horizontalGap = 12.0;

    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Builder(
          builder: (appBarContext) {
            return CommonAppBar(
              logoAssetPath: 'assets/logos/logo.svg', // Your path
              onMenuPressed: () {
                Scaffold.of(appBarContext).openDrawer();
              },
              onSearchPressed: () {
                print("Search Pressed"); /* TODO: Implement Search action */
              },
              onNotificationPressed: () {
                print(
                  "Notifications Pressed",
                ); /* TODO: Implement Notif action */
              },
              onProfilePressed: () {
                print("Profile Pressed"); /* TODO: Implement Profile action */
              },
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
              Form(
                key: _formKey,
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
                              value: _selectedTaskData,
                              items:
                                  _taskList
                                      .map(
                                        (task) => DropdownMenuItem<Task>(
                                          value: task,
                                          child: Text(
                                            task.TaskName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged:
                                  _isTasksLoading
                                      ? null
                                      : (Task? newValue) {
                                        if (newValue != null &&
                                            newValue != _selectedTaskData) {
                                          setState(() {
                                            _selectedTaskData = newValue;

                                            _selectedSubTaskData = null;
                                            _subTaskList = [];
                                          });
                                          _fetchSubTasks(newValue.Taskid);
                                        }
                                      },
                              decoration: _dropdownDecoration(
                                'Select Task',
                                isLoading: _isTasksLoading,
                              ),
                              validator:
                                  (value) =>
                                      value == null ? 'Task is required' : null,
                              isExpanded: true,
                              hint:
                                  _isTasksLoading
                                      ? const Text("0")
                                      : _taskList.isEmpty
                                      ? const Text("No tasks found")
                                      : const Text("Select Task"),
                              disabledHint:
                                  _isTasksLoading ? const Text("0...") : null,
                            ),
                          ),
                          const SizedBox(width: horizontalGap),
                          Padding(
                            padding: const EdgeInsets.only(top: 0.0),
                            child: _buildAddButton(),
                          ),
                          const SizedBox(width: horizontalGap),
                          Expanded(
                            child: DropdownButtonFormField<SubTask>(
                              value: _selectedSubTaskData,
                              items:
                                  _subTaskList
                                      .map(
                                        (subTask) => DropdownMenuItem<SubTask>(
                                          value: subTask,
                                          child: Text(
                                            subTask.subTaskName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged:
                                  (_selectedTaskData == null ||
                                          _isSubTasksLoading)
                                      ? null
                                      : (SubTask? newValue) {
                                        setState(() {
                                          _selectedSubTaskData = newValue;
                                        });
                                      },
                              decoration: _dropdownDecoration(
                                _selectedTaskData == null
                                    ? 'Select Task First'
                                    : 'Select Sub Task',
                                isLoading: _isSubTasksLoading,
                              ),
                              validator:
                                  (value) =>
                                      value == null
                                          ? 'Sub Task is required'
                                          : null,
                              isExpanded: true,
                              hint:
                                  _isSubTasksLoading
                                      ? const Text("...")
                                      : _selectedTaskData == null
                                      ? const Text("Select Task First")
                                      : _subTaskList.isEmpty &&
                                          !_isSubTasksLoading
                                      ? const Text("No sub-tasks")
                                      : const Text("Select Sub Task"),
                              disabledHint:
                                  _selectedTaskData == null
                                      ? const Text("Select Task First")
                                      : _isSubTasksLoading
                                      ? const Text("...")
                                      : null,
                            ),
                          ),
                          const SizedBox(width: horizontalGap),
                          Padding(
                            padding: const EdgeInsets.only(top: 0.0),
                            child: _buildAddButton(),
                          ),
                        ],
                      ),
                    ),

                    _buildSectionCard(
                      title: 'Client',
                      child: DropdownButtonFormField<Client>(
                        value: _selectedClientData,
                        items:
                            _clientList
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
                        onChanged:
                            _isClientsLoading
                                ? null
                                : (Client? newValue) {
                                  if (newValue != null &&
                                      newValue != _selectedClientData) {
                                    setState(() {});
                                  }
                                },
                        decoration: _dropdownDecoration(
                          'Select Client',
                          isLoading: _isClientsLoading,
                        ),
                        validator:
                            (value) =>
                                value == null ? 'Client is required' : null,
                        isExpanded: true,
                        hint:
                            _isClientsLoading
                                ? const Text("0")
                                : _clientList.isEmpty
                                ? const Text("No Clients found")
                                : const Text("Select Client"),
                        disabledHint:
                            _isClientsLoading ? const Text("...") : null,
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
                                DropdownButtonFormField<String>(
                                  value: _selectedAllottedTo,
                                  items:
                                      _allottedToOptions
                                          .map(
                                            (label) => DropdownMenuItem(
                                              value: label,
                                              child: Text(
                                                label,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged:
                                      (value) => setState(
                                        () => _selectedAllottedTo = value,
                                      ),
                                  decoration: _dropdownDecoration(
                                    'Select Staff/Group',
                                  ),
                                  validator:
                                      (value) =>
                                          value == null ? 'Required' : null,
                                  isExpanded: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: horizontalGap),
                          Padding(
                            padding: const EdgeInsets.only(top: 22.0),
                            child: _buildAddButton(),
                          ),
                          const SizedBox(width: horizontalGap),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Allotted By'),
                                TextFormField(
                                  controller: _allottedByController,
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
                                child: DropdownButtonFormField<String>(
                                  value: _selectedFinancialYear,
                                  items:
                                      _financialYearOptions
                                          .map(
                                            (label) => DropdownMenuItem(
                                              value: label,
                                              child: Text(
                                                label,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged:
                                      (value) => setState(
                                        () => _selectedFinancialYear = value,
                                      ),
                                  decoration: _dropdownDecoration(
                                    'Select Financial Year',
                                  ),
                                  validator:
                                      (value) =>
                                          value == null ? 'Required' : null,
                                  isExpanded: true,
                                ),
                              ),
                              const SizedBox(width: horizontalGap),
                              Padding(
                                padding: const EdgeInsets.only(top: 0.0),
                                child: _buildAddButton(),
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
                                      value: _selectedFromMonth,
                                      items:
                                          _monthOptions
                                              .map(
                                                (label) => DropdownMenuItem(
                                                  value: label,
                                                  child: Text(
                                                    label,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                      onChanged:
                                          (value) => setState(
                                            () => _selectedFromMonth = value,
                                          ),
                                      decoration: _dropdownDecoration(
                                        'Select Month',
                                      ),
                                      validator:
                                          (value) =>
                                              value == null ? 'Required' : null,
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
                                      value: _selectedToMonth,
                                      items:
                                          _monthOptions
                                              .map(
                                                (label) => DropdownMenuItem(
                                                  value: label,
                                                  child: Text(
                                                    label,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                      onChanged:
                                          (value) => setState(
                                            () => _selectedToMonth = value,
                                          ),
                                      decoration: _dropdownDecoration(
                                        'Select Month',
                                      ),
                                      validator:
                                          (value) =>
                                              value == null ? 'Required' : null,
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
                        controller: _taskInstructionController,
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
                                  controller: _allottedDateController,
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
                                      () => _selectDate(
                                        context,
                                        _allottedDateController,
                                      ),
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
                                  controller: _expectedDateController,
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
                                      () => _selectDate(
                                        context,
                                        _expectedDateController,
                                      ),
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
                            value: _selectedPriority,
                            items:
                                _priorityOptions
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
                            onChanged:
                                (value) =>
                                    setState(() => _selectedPriority = value),
                            decoration: _dropdownDecoration('Medium'),
                            validator:
                                (value) =>
                                    value == null
                                        ? 'Priority is required'
                                        : null,
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
                              value: _isVerifiedByAdmin,
                              onChanged:
                                  (bool? value) => setState(
                                    () => _isVerifiedByAdmin = value ?? false,
                                  ),
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
                          onPressed: _isLoading ? null : _submitTask,
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
                              _isLoading
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
                          onPressed:
                              _isLoading
                                  ? null
                                  : () => Navigator.of(context).pop(),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
