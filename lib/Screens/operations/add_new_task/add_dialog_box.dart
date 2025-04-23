import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/http/utils/body_decoder.dart';
import 'package:http/http.dart' as http;

import '../../../modal/operations/task_modal.dart';
import '../../../utils/constants.dart';

String _addTaskEndpoint = "$baseUrl/add_task";
String _addStaffEndpoint = "$baseUrl/staff_registration";
String _addSubTaskEndpoint = "$baseUrl/add_sub_task";

void _showSnackbar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
    ),
  );
}

class AddTaskDialog extends StatefulWidget {
  final Function(String) onSave;

  const AddTaskDialog({super.key, required this.onSave});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _taskNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _taskNameController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final taskName = _taskNameController.text.trim();
    final BuildContext currentContext = context;

    final Map<String, String> innerData = {'task_name': taskName};

    final String innerJsonValue = jsonEncode(innerData);

    final Map<String, String> formData = {'data': innerJsonValue};

    final Map<String, String> headers = {'Accept': 'application/json'};

    print("--- Sending Add Task Data (Nested JSON in Form Data) ---");
    print("Endpoint: $_addTaskEndpoint");
    print("Headers: $headers");
    print("Inner JSON being encoded: $innerData");
    print("Outer Form Data Body being sent: $formData");
    print("--------------------------------------------------");

    try {
      final response = await http.post(
        Uri.parse(_addTaskEndpoint),
        headers: headers,
        body: formData,
      );

      if (!currentContext.mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = jsonDecode(response.body);
        print("Add Task API Response: $decodedResponse");

        if (decodedResponse['success'] == true) {
          widget.onSave(taskName);
          Navigator.of(currentContext).pop();
        } else {
          _showSnackbar(
            currentContext,
            decodedResponse['response'] ??
                decodedResponse['message'] ??
                'Failed to add task (API Error)',
            isError: true,
          );
        }
      } else {
        String errorMessage =
            'Error: ${response.statusCode}. Failed to add task.';
        try {
          final Map<String, dynamic> errorResponse = jsonDecode(response.body);
          errorMessage = errorResponse['message'] ?? errorMessage;
        } catch (_) {}

        _showSnackbar(currentContext, errorMessage, isError: true);
        print(
          "Add Task API Error: Status Code ${response.statusCode}, Body: ${response.body}",
        );
      }
    } catch (e) {
      print("Add Task Exception: $e");
      if (currentContext.mounted) {
        _showSnackbar(
          currentContext,
          'An network error occurred: $e',
          isError: true,
        );
      }
    } finally {
      if (currentContext.mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Add Task',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _taskNameController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Enter Task Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Task name cannot be empty';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 12.0,
      ),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
          ),
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
          ),
          onPressed: _isLoading ? null : _saveTask,
          child:
              _isLoading
                  ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : const Text('Save'),
        ),
      ],
    );
  }
}

class AddSubTaskDialog extends StatefulWidget {
  final List<Task> availableTasks;
  final bool isTasksLoading;
  final Function(Task, String) onSave;

  const AddSubTaskDialog({
    super.key,
    required this.availableTasks,
    required this.isTasksLoading,
    required this.onSave,
  });

  @override
  State<AddSubTaskDialog> createState() => _AddSubTaskDialogState();
}

class _AddSubTaskDialogState extends State<AddSubTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _subTaskNameController = TextEditingController();
  Task? _selectedTask;
  bool _isLoading = false;

  @override
  void dispose() {
    _subTaskNameController.dispose();
    super.dispose();
  }

  Future<void> _saveSubTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedTask == null) return;

    setState(() {
      _isLoading = true;
    });

    final subTaskName = _subTaskNameController.text.trim();
    final parentTask = _selectedTask!;
    final BuildContext currentContext = context;

    final Map<String, String> innerData = {
      'task_id': parentTask.Taskid,
      'sub_task_name': subTaskName,
    };

    final String innerJsonValue = jsonEncode(innerData);

    final Map<String, String> formData = {'data': innerJsonValue};

    final Map<String, String> headers = {'Accept': 'application/json'};

    print("--- Sending Add SubTask Data (Nested JSON in Form Data) ---");
    print("Endpoint: $_addSubTaskEndpoint");
    print("Headers: $headers");
    print("Inner JSON being encoded: $innerData");
    print("Outer Form Data Body being sent: $formData");
    print("--------------------------------------------------");

    try {
      final response = await http.post(
        Uri.parse(_addSubTaskEndpoint),
        headers: headers,
        body: formData,
      );

      if (!currentContext.mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = jsonDecode(response.body);
        print("Add SubTask API Response: $decodedResponse");

        if (decodedResponse['success'] == true) {
          widget.onSave(parentTask, subTaskName);
          Navigator.of(currentContext).pop();
        } else {
          _showSnackbar(
            currentContext,
            decodedResponse['response'] ??
                decodedResponse['message'] ??
                'Failed to add sub-task (API Error)',
            isError: true,
          );
        }
      } else {
        String errorMessage =
            'Error: ${response.statusCode}. Failed to add sub-task.';
        try {
          final Map<String, dynamic> errorResponse = jsonDecode(response.body);
          errorMessage = errorResponse['message'] ?? errorMessage;
        } catch (_) {}

        _showSnackbar(currentContext, errorMessage, isError: true);
        print(
          "Add SubTask API Error: Status Code ${response.statusCode}, Body: ${response.body}",
        );
      }
    } catch (e) {
      print("Add SubTask Exception: $e");
      if (currentContext.mounted) {
        _showSnackbar(
          currentContext,
          'An network error occurred: $e',
          isError: true,
        );
      }
    } finally {
      if (currentContext.mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Add Sub Task',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<Task>(
              value: _selectedTask,
              items:
                  widget.availableTasks
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
              onChanged:
                  widget.isTasksLoading
                      ? null
                      : (Task? newValue) {
                        setState(() {
                          _selectedTask = newValue;
                        });
                      },
              decoration: _dropdownDecoration(
                'Select Parent Task',
                isLoading: widget.isTasksLoading,
              ),
              validator:
                  (value) => value == null ? 'Parent Task is required' : null,
              isExpanded: true,
              hint:
                  widget.isTasksLoading
                      ? const Text("Loading Tasks...")
                      : widget.availableTasks.isEmpty
                      ? const Text("No tasks available")
                      : const Text("Select Parent Task"),
              disabledHint:
                  widget.isTasksLoading ? const Text("Loading...") : null,
            ),
            const SizedBox(height: 16),

            const Text(
              'Sub Task Name',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _subTaskNameController,
              decoration: InputDecoration(
                hintText: 'Enter Sub Task Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Sub Task name cannot be empty';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 12.0,
      ),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
          ),
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
          ),
          onPressed: _isLoading ? null : _saveSubTask,
          child:
              _isLoading
                  ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : const Text('Save'),
        ),
      ],
    );
  }
}

class AddStaffDialog extends StatefulWidget {
  // Modify onSave if you need more data back than just the name
  // For now, keeping it consistent, passing the name on success.
  final Function(String staffName) onSave;

  const AddStaffDialog({super.key, required this.onSave});

  @override
  State<AddStaffDialog> createState() => _AddStaffDialogState();
}

class _AddStaffDialogState extends State<AddStaffDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _passwordController = TextEditingController();

  // Staff Types - Adjust if API supports more than 'staff'
  final List<String> _staffTypes = ['Staff']; // Can add 'Admin', etc. if needed
  String? _selectedType; // Start with null to force selection or default

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Default to the first type if available
    if (_staffTypes.isNotEmpty) {
      _selectedType = _staffTypes.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _textFieldDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      isDense: true,
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0, top: 10.0), // Add top padding
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black54,
        ),
      ),
    );
  }

  // In _AddStaffDialogState

  Future<void> _saveStaff() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackbar(
        context,
        "Please fill all required fields correctly.",
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final staffName = _nameController.text.trim();
    final staffEmail = _emailController.text.trim();
    final staffContact = _contactController.text.trim();
    final staffPassword = _passwordController.text;
    final staffType = _selectedType!;

    final BuildContext currentContext = context;

    final Map<String, String> innerData = {
      'name': staffName,
      'contact': staffContact,
      'email': staffEmail,
      'password': staffPassword,
      'type': staffType.toLowerCase(),
    };
    final String innerJsonValue = jsonEncode(innerData);
    final Map<String, String> formData = {'data': innerJsonValue};
    final Map<String, String> headers = {'Accept': 'application/json'};

    print("--- Sending Add Staff Data (Nested JSON in Form Data) ---");
    print("Endpoint: $_addStaffEndpoint");
    print("Headers: $headers");
    print("Inner JSON being encoded: $innerData");
    print("Outer Form Data Body being sent: $formData");
    print("--------------------------------------------------");

    try {
      final response = await http
          .post(Uri.parse(_addStaffEndpoint), headers: headers, body: formData)
          .timeout(const Duration(seconds: 20));

      if (!currentContext.mounted) return;

      // Regardless of status code, try to decode the body if it's not empty
      Map<String, dynamic>? decodedResponse;
      String responseBody = response.body;
      String apiMessage = 'Failed to add Staff'; // Default message

      try {
        if (responseBody.isNotEmpty) {
          decodedResponse = jsonDecode(responseBody);
          // Prioritize 'message', then 'response', then provide a default
          apiMessage =
              decodedResponse?['message'] ??
              decodedResponse?['response'] ??
              apiMessage;
        }
      } catch (e) {
        print("Error decoding API response body: $e");
        apiMessage = 'Received invalid response from server.';
        // Use the raw body in the detailed log
      }

      print(
        "Add Staff API Response Raw: Status ${response.statusCode}, Body: $responseBody",
      );

      if (response.statusCode == 200 &&
          decodedResponse != null &&
          decodedResponse['success'] == true) {
        // --- SUCCESS ---
        widget.onSave(staffName);
        _showSnackbar(
          currentContext,
          apiMessage,
        ); // Show success message from API
        Navigator.of(currentContext).pop();
      } else {
        // --- FAILURE (HTTP Error or API Error) ---
        String displayError;
        if (response.statusCode != 200) {
          // HTTP Error
          displayError = 'Error ${response.statusCode}: $apiMessage';
        } else {
          // API Error (e.g., success: false, duplicate entry)
          displayError =
              apiMessage; // Use the message parsed from the API response
        }

        _showSnackbar(currentContext, displayError, isError: true);
        print(
          "Add Staff API Error: Status Code ${response.statusCode}, Parsed Msg: '$apiMessage', Full Body: $responseBody",
        );
      }
    } catch (e) {
      print("Add Staff Network/Timeout Exception: $e");
      if (currentContext.mounted) {
        _showSnackbar(
          currentContext,
          'An network error occurred: $e',
          isError: true,
        );
      }
    } finally {
      if (currentContext.mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Add Staff',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
      // Make content scrollable in case of small screens
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Staff Name
              _buildLabel('Staff Name'),
              TextFormField(
                controller: _nameController,
                autofocus: true, // Focus the first field
                decoration: _textFieldDecoration('Enter Staff Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Staff name cannot be empty';
                  }
                  return null;
                },
              ),

              // Staff Email
              _buildLabel('Staff Email'),
              TextFormField(
                controller: _emailController,
                decoration: _textFieldDecoration('Enter Staff Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Staff email cannot be empty';
                  }
                  // Basic email format check
                  if (!RegExp(
                    r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),

              // Staff Contact
              _buildLabel('Staff Contact'),
              TextFormField(
                controller: _contactController,
                decoration: _textFieldDecoration('Enter Staff Contact'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Staff contact cannot be empty';
                  }
                  // Basic check for digits, adjust regex/length as needed
                  if (!RegExp(r'^[0-9]+$').hasMatch(value) ||
                      value.length < 10) {
                    return 'Please enter a valid contact number';
                  }
                  return null;
                },
              ),

              // Password
              _buildLabel('Password'),
              TextFormField(
                controller: _passwordController,
                decoration: _textFieldDecoration('Enter Password'),
                obscureText: true, // Hide password text
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    // Don't trim password here
                    return 'Password cannot be empty';
                  }
                  if (value.length < 6) {
                    // Example: Minimum length
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),

              // Type Dropdown
              _buildLabel('Type'),
              DropdownButtonFormField<String>(
                value: _selectedType,
                items:
                    _staffTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedType = newValue;
                  });
                },
                decoration: _textFieldDecoration('Select Type').copyWith(
                  // Remove hint text if a default value is always selected
                  hintText: _selectedType == null ? 'Select Type' : null,
                ),
                validator:
                    (value) => value == null ? 'Please select a type' : null,
                isExpanded: true, // Make dropdown take available width
              ),
              const SizedBox(height: 10), // Add some space at the bottom
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 12.0,
      ),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
          ),
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
          ),
          onPressed: _isLoading ? null : _saveStaff,
          child:
              _isLoading
                  ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : const Text('Save'),
        ),
      ],
    );
  }
}
