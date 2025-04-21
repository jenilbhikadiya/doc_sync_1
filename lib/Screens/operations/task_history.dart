// lib/screens/task_history_screen.dart (or your preferred path)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

// Assuming these components exist in your project - replace with standard AppBar/Drawer if not
// import '../../components/common_appbar.dart';
// import '../../components/drawer.dart';
import '../../components/common_appbar.dart';
import '../../components/drawer.dart';
import '../../modal/operations/task_history_modal.dart';

class TaskHistoryScreen extends StatefulWidget {
  const TaskHistoryScreen({super.key});

  @override
  State<TaskHistoryScreen> createState() => _TaskHistoryScreenState();
}

class _TaskHistoryScreenState extends State<TaskHistoryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _dateController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  // --- Sample Data (Replace with your actual data fetching logic) ---
  final List<TaskHistoryItem> _taskHistoryData = [
    TaskHistoryItem(
      srNo: '1',
      fileNo: 'AARJ', // File number seems short in row 1
      client: 'client-111',
      taskSubTask: 'GST -- GSTR 1 - Jan 25',
      allottedBy: 'staff1',
      allottedTo: 'admin1',
      instructions:
          'Task: GST Subtask: GSTR 1 - Jan 25 Period: 2022 Month From: Mar Month To: Mar',
      period: '2022 Mar - Mar',
      status: TaskHistoryStatus.allotted,
      priority: TaskPriority.high,
    ),
    TaskHistoryItem(
      srNo: '2',
      fileNo: '1111',
      client: 'client-555',
      taskSubTask: 'GST -- GST Amendment Notice',
      allottedBy: 'staff1',
      allottedTo: 'staff2',
      instructions:
          'Task: GST Subtask: GST Amendment Notice Period: 2018-19 Month To: Mar plz do it asap Month From: Mar',
      period: '2018-19 Mar - Mar',
      status: TaskHistoryStatus.awaitingResponse,
      priority: TaskPriority.high,
    ),
    TaskHistoryItem(
      srNo: '3',
      fileNo: '1111',
      client: 'client-555',
      taskSubTask: 'GST -- GSTR 1 - Jan 25',
      allottedBy: 'Staff1', // Consistent casing?
      allottedTo: 'staff11',
      instructions: 'please do it as per guidlines',
      period: '-', // Period is '-' in the image for this row
      status: TaskHistoryStatus.reallotted,
      priority: TaskPriority.high,
    ),
  ];

  List<TaskHistoryItem> _filteredTaskHistory = [];

  @override
  void initState() {
    super.initState();
    // Initially, show all data
    _filteredTaskHistory = List.from(_taskHistoryData);
    // Add listener or logic here if you need filtering based on date immediately
  }

  @override
  void dispose() {
    _dateController.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initial = DateTime.now();
    try {
      if (_dateController.text.isNotEmpty) {
        initial = DateFormat('dd-MM-yyyy').parse(_dateController.text);
      }
    } catch (e) {
      print("Error parsing date: $e");
      // Handle error or keep initial date
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000), // Adjust range as needed
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd-MM-yyyy').format(picked);
        // --- Add Filtering Logic Here ---
        // Example: Filter tasks based on the selected date if needed
        // _filterTasksByDate(picked);
        print("Date selected: ${_dateController.text}");
        // For now, just updates the text field
      });
    }
  }

  void _showAllTasks() {
    setState(() {
      _dateController.clear();
      _filteredTaskHistory = List.from(_taskHistoryData);
      // Add logic to clear any other filters if you implement them
    });
    print("Showing all tasks");
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // --- Use your CommonAppBar or a standard AppBar ---
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
        controller: _verticalScrollController,
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPageHeader(),
              const SizedBox(height: 20),
              _buildFilterControls(), // Renamed for clarity
              const SizedBox(height: 20),
              _buildDataTableArea(),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task History',
          style: TextStyle(
            fontSize: 20, // Slightly smaller than Admin Verification example
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColorDark ?? Colors.blue.shade800,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Home / Task History / Data',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFilterControls() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Date', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        SizedBox(
          width: 150, // Adjust width as needed
          height: 40, // Control height
          child: TextField(
            controller: _dateController,
            readOnly: true,
            onTap: () => _selectDate(context),
            decoration: InputDecoration(
              hintText: 'dd-mm-yyyy',
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              border: const OutlineInputBorder(),
              suffixIcon: Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.grey.shade600,
              ),
              isDense: true,
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _showAllTasks,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            minimumSize: const Size(0, 40), // Match TextField height
          ),
          child: const Text('Show All'),
        ),
        // Add Spacer() here if you want 'Show All' pushed to the right end
        // const Spacer(),
      ],
    );
  }

  Widget _buildDataTableArea() {
    return Scrollbar(
      controller: _horizontalScrollController,
      thumbVisibility: true, // Make scrollbar always visible
      child: SingleChildScrollView(
        controller: _horizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: DataTable(
          dataRowMinHeight: 65.0, // Adjust min height for content
          dataRowMaxHeight: 85.0, // Adjust max height
          columnSpacing: 25.0, // Adjust spacing between columns
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
          border: TableBorder.all(color: Colors.grey.shade300, width: 1),
          columns: _buildDataColumns(),
          rows:
              _filteredTaskHistory.map((task) => _buildDataRow(task)).toList(),
        ),
      ),
    );
  }

  List<DataColumn> _buildDataColumns() {
    // Added const for performance where applicable
    return const [
      DataColumn(
        label: Text('Sr no.', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      DataColumn(
        label: Text('File no.', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      DataColumn(
        label: Text('Client', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      DataColumn(
        label: Text(
          'Task -- Sub Task',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      DataColumn(
        label: Text(
          'Allotted By',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      DataColumn(
        label: Text(
          'Allotted To',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      DataColumn(
        label: Text(
          'Instructions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      DataColumn(
        label: Text('Period', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      DataColumn(
        label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      DataColumn(
        label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    ];
  }

  DataRow _buildDataRow(TaskHistoryItem task) {
    return DataRow(
      cells: [
        DataCell(Text(task.srNo)),
        DataCell(Text(task.fileNo)),
        DataCell(Text(task.client)),
        DataCell(Text(task.taskSubTask)),
        DataCell(Text(task.allottedBy)),
        DataCell(Text(task.allottedTo)),
        DataCell(
          ConstrainedBox(
            // Limit width of instructions cell
            constraints: const BoxConstraints(
              maxWidth: 200,
            ), // Adjust max width
            child: Tooltip(
              // Show full text on hover/long press
              message: task.instructions,
              child: Text(
                task.instructions,
                overflow: TextOverflow.ellipsis,
                maxLines: 3, // Show multiple lines before ellipsis
              ),
            ),
          ),
        ),
        DataCell(Text(task.period)),
        DataCell(_buildStatusCell(task.status, task.priority)),
        DataCell(
          _buildActionCell(task),
        ), // Pass task object if needed for actions
      ],
    );
  }

  Widget _buildStatusCell(TaskHistoryStatus status, TaskPriority priority) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center, // Center chips vertically
      crossAxisAlignment: CrossAxisAlignment.start, // Align chips left
      children: [
        Chip(
          label: Text(
            taskHistoryStatusToString(status),
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
          backgroundColor: getStatusColor(status),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 0,
          ), // Adjust padding
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact, // Make chip smaller
        ),
        const SizedBox(height: 4), // Space between chips
        Chip(
          label: Text(
            taskPriorityToString(priority),
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
          backgroundColor: getPriorityColor(
            priority,
          ), // Consistent red color for High
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 0,
          ), // Adjust padding
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  Widget _buildActionCell(TaskHistoryItem task) {
    // Example action icons based on the image
    return Row(
      mainAxisSize: MainAxisSize.min, // Use minimum space
      children: [
        IconButton(
          icon: Icon(
            Icons.remove_red_eye_outlined,
            color: Colors.blue.shade700,
            size: 20,
          ),
          onPressed: () {
            print('View action for Sr no: ${task.srNo}');
            // Add view logic here
          },
          tooltip: 'View',
          splashRadius: 18,
          constraints: const BoxConstraints(), // Remove extra padding
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
        IconButton(
          icon: Icon(
            Icons.edit_outlined,
            color: Colors.orange.shade700,
            size: 20,
          ),
          onPressed: () {
            print('Edit action for Sr no: ${task.srNo}');
            // Add edit logic here
          },
          tooltip: 'Edit',
          splashRadius: 18,
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
        IconButton(
          icon: Icon(
            Icons.arrow_forward_outlined,
            color: Colors.red.shade600,
            size: 20,
          ),
          onPressed: () {
            print('Forward/Reassign action for Sr no: ${task.srNo}');
            // Add forward/reassign logic here
          },
          tooltip: 'Forward/Reassign', // Assuming the arrow means this
          splashRadius: 18,
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
      ],
    );
  }
}
