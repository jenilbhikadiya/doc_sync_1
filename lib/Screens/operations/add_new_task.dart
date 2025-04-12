// lib/add_new_task.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting (add dependency: flutter pub add intl)

class AddNewTaskPage extends StatefulWidget {
  const AddNewTaskPage({super.key});

  @override
  State<AddNewTaskPage> createState() => _AddNewTaskPageState();
}

class _AddNewTaskPageState extends State<AddNewTaskPage> {
  // --- State Variables ---
  String? _selectedTask;
  String? _selectedSubTask;
  String? _selectedClient;
  String? _selectedAllottedTo; // Assuming this relates to Staff/Group
  String? _selectedFinancialYear;
  String? _selectedFromMonth;
  String? _selectedToMonth;
  String? _selectedPriority = 'Medium'; // Default based on image
  bool _isVerifiedByAdmin = true; // Default based on image

  final TextEditingController _taskInstructionController =
      TextEditingController();
  final TextEditingController _allottedDateController = TextEditingController();
  final TextEditingController _expectedDateController = TextEditingController();
  final TextEditingController _allottedByController = TextEditingController(
    text: 'Pragma Admin',
  ); // Pre-filled

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // --- Dummy Data (Replace with your actual data sources) ---
  final List<String> _taskOptions = ['Task A', 'Task B', 'Task C'];
  final List<String> _subTaskOptions = ['SubTask X', 'SubTask Y', 'SubTask Z'];
  final List<String> _clientOptions = ['Client 1', 'Client 2', 'Client 3'];
  final List<String> _allottedToOptions = ['Staff A', 'Group 1', 'Staff B'];
  final List<String> _financialYearOptions = ['2024-2025', '2023-2024'];
  final List<String> _monthOptions = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final List<String> _priorityOptions = ['High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    // Set initial dates based on image
    final initialDate = DateTime(2025, 5, 4);
    _allottedDateController.text = DateFormat('dd-MM-yyyy').format(initialDate);
    _expectedDateController.text = DateFormat('dd-MM-yyyy').format(initialDate);
  }

  @override
  void dispose() {
    _taskInstructionController.dispose();
    _allottedDateController.dispose();
    _expectedDateController.dispose();
    _allottedByController.dispose();
    super.dispose();
  }

  // --- Helper Functions ---
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
      print(
        "Error parsing date: $e",
      ); // Handle parsing error if format is wrong
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  // --- Widgets ---

  // Helper for consistent section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0D47A1), // Dark blue title
        ),
      ),
    );
  }

  // Helper for '+' buttons
  Widget _buildAddButton({VoidCallback? onPressed}) {
    return SizedBox(
      width: 40, // Constrain width
      height: 40, // Constrain height to match dropdown approx
      child: ElevatedButton(
        onPressed: onPressed ?? () {}, // Provide default empty action
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE8F5E9), // Light green background
          foregroundColor: const Color(0xFF388E3C), // Darker green icon/text
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: EdgeInsets.zero, // Remove default padding
          elevation: 0, // No shadow to match image
        ),
        child: const Icon(Icons.add, size: 24),
      ),
    );
  }

  // Helper for Dropdown styling
  InputDecoration _dropdownDecoration(String hintText) {
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
        borderSide: const BorderSide(
          color: Color(0xFF0D47A1),
          width: 1.5,
        ), // Highlight focus
      ),
      filled: true,
      fillColor: Colors.white, // Background color of dropdown
      isDense: true, // Reduces vertical size slightly
    );
  }

  // Helper for Text Field styling
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

  // Helper for labels above fields
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

  // Helper for building card sections
  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white, // White background for the card area
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(title),
          const SizedBox(height: 8), // Spacing below title
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double horizontalGap =
        12.0; // Consistent gap between horizontal elements

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light background for the page
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Create New Task',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF0D47A1), // Dark blue AppBar
        elevation: 1.0, // Subtle shadow
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Task Details Section ---
                _buildSectionCard(
                  title: 'Task Details',
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align tops
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedTask,
                          items:
                              _taskOptions
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
                          onChanged: (value) {
                            setState(() {
                              _selectedTask = value;
                            });
                          },
                          decoration: _dropdownDecoration('Select Task'),
                          isExpanded: true,
                        ),
                      ),
                      const SizedBox(width: horizontalGap),
                      _buildAddButton(),
                      const SizedBox(width: horizontalGap),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedSubTask,
                          items:
                              _subTaskOptions
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
                          onChanged: (value) {
                            setState(() {
                              _selectedSubTask = value;
                            });
                          },
                          decoration: _dropdownDecoration('Select Sub...'),
                          isExpanded: true,
                        ),
                      ),
                      const SizedBox(width: horizontalGap),
                      _buildAddButton(),
                    ],
                  ),
                ),

                // --- Client Section ---
                _buildSectionCard(
                  title: 'Client',
                  child: DropdownButtonFormField<String>(
                    value: _selectedClient,
                    items:
                        _clientOptions
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
                    onChanged: (value) {
                      setState(() {
                        _selectedClient = value;
                      });
                    },
                    decoration: _dropdownDecoration('Select Client'),
                    isExpanded: true,
                  ),
                ),

                // --- Allotment Section ---
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
                              onChanged: (value) {
                                setState(() {
                                  _selectedAllottedTo = value;
                                });
                              },
                              decoration: _dropdownDecoration(
                                'Select Task',
                              ), // Hint might need change
                              isExpanded: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: horizontalGap),
                      Padding(
                        // Align button vertically slightly better
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
                              readOnly:
                                  true, // Make it read-only like the image
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

                // --- Period Section ---
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
                              onChanged: (value) {
                                setState(() {
                                  _selectedFinancialYear = value;
                                });
                              },
                              decoration: _dropdownDecoration(
                                'Select Financial Year',
                              ),
                              isExpanded: true,
                            ),
                          ),
                          const SizedBox(width: horizontalGap),
                          _buildAddButton(),
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ), // Spacing between year and months
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
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedFromMonth = value;
                                    });
                                  },
                                  decoration: _dropdownDecoration(
                                    'Select Month',
                                  ),
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
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedToMonth = value;
                                    });
                                  },
                                  decoration: _dropdownDecoration(
                                    'Select Month',
                                  ),
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

                // --- Task Instruction Section ---
                _buildSectionCard(
                  title: 'Task Instruction',
                  child: TextFormField(
                    controller: _taskInstructionController,
                    maxLines: 4, // Multi-line
                    minLines: 4,
                    style: const TextStyle(fontSize: 14),
                    decoration: _textFieldDecoration(
                      hintText: 'Enter Task Details...',
                    ).copyWith(
                      // Remove isDense effect for larger text area
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 12.0,
                      ),
                    ),
                  ),
                ),

                // --- Dates Section ---
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
                                  color:
                                      Colors.teal.shade400, // Match icon color
                                  size: 18,
                                ),
                              ),
                              onTap:
                                  () => _selectDate(
                                    context,
                                    _allottedDateController,
                                  ),
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
                                  color:
                                      Colors.teal.shade400, // Match icon color
                                  size: 18,
                                ),
                              ),
                              onTap:
                                  () => _selectDate(
                                    context,
                                    _expectedDateController,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // --- Priority & Verification Section ---
                _buildSectionCard(
                  // Title was 'Client' in image, changed for clarity
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
                        onChanged: (value) {
                          setState(() {
                            _selectedPriority = value;
                          });
                        },
                        decoration: _dropdownDecoration(
                          'Medium',
                        ), // Hint/default
                        isExpanded: true,
                      ),
                      const SizedBox(height: 10),
                      // Using CheckboxListTile for easy layout and padding
                      SizedBox(
                        height: 40, // Control height
                        child: CheckboxListTile(
                          title: const Text(
                            'Verify By Admin',
                            style: TextStyle(fontSize: 14),
                          ),
                          value: _isVerifiedByAdmin,
                          onChanged: (bool? value) {
                            setState(() {
                              _isVerifiedByAdmin = value ?? false;
                            });
                          },
                          controlAffinity:
                              ListTileControlAffinity.leading, // Checkbox first
                          contentPadding:
                              EdgeInsets.zero, // Remove extra padding
                          activeColor:
                              Colors.green.shade600, // Match check color
                          dense: true,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24), // Space before buttons
                // --- Action Buttons ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Center buttons
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Process data
                          print('Form Saved!');
                          print('Task: $_selectedTask');
                          print('Client: $_selectedClient');
                          // ... print other values
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Task Saved (Simulated)'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32), // Green color
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                    const SizedBox(width: 20), // Gap between buttons
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the page
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828), // Red color
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ],
                ),
                const SizedBox(height: 20), // Padding at the bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}
