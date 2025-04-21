// lib/Screens/admin/admin_verification.dart (or your path)
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart'; // For date picker

// Adjust import paths based on your project structure
import '../../components/common_appbar.dart';
import '../../components/drawer.dart';
// Ensure correct path to your model file
import '../../modal/operations/admin_verification_task_modal.dart';

class AdminVerification extends StatefulWidget {
  const AdminVerification({super.key});

  @override
  State<AdminVerification> createState() => _AdminVerificationState();
}

class _AdminVerificationState extends State<AdminVerification> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // --- State Variables ---
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedEntriesPerPage = '10'; // Default
  final List<String> _entriesOptions = ['10', '25', '50', '100'];

  bool _isAllSelected = false; // State for header checkbox
  final Set<String> _selectedTaskIds = <String>{}; // Store IDs of selected rows

  // Use late initialization or fetch in initState if data comes from API
  late List<VerificationTask> _verificationTasks;
  List<VerificationTask> _filteredTasks =
      []; // List for displaying filtered/searched data

  @override
  void initState() {
    super.initState();
    // Initialize sample data (Replace with actual data fetching)
    _verificationTasks = [
      VerificationTask(
        id: 'task1',
        srNo: '1',
        fileNo: '954',
        client: 'client-1412',
        taskSubTask: 'GST -- GSTR 1 - Jan 25',
        allottedBy: 'admin1',
        allottedTo: 'staff8',
        instruction: 'please do it as per guidlines',
        endDate: '11-02-2025',
        period: '-',
        status: TaskStatus.completed,
        priority: TaskPriority.medium,
      ),
      VerificationTask(
        id: 'task2',
        srNo: '2',
        fileNo: '1160',
        client: 'client-252',
        taskSubTask: 'ACCOUNTING -- AY 2025-26',
        allottedBy: 'admin1',
        allottedTo: 'staff5',
        instruction: 'please do it as per guidlines',
        endDate: '28-02-2025',
        period: '-',
        status: TaskStatus.completed,
        priority: TaskPriority.medium,
      ),
      VerificationTask(
        id: 'task3',
        srNo: '3',
        fileNo: '729',
        client: 'client-312',
        taskSubTask: 'ACCOUNTING -- AY 2025-26',
        allottedBy: 'admin1',
        allottedTo: 'staff5',
        instruction: 'please do it as per guidlines',
        endDate: '28-02-2025',
        period: '-',
        status: TaskStatus.completed,
        priority: TaskPriority.medium,
      ),
      VerificationTask(
        id: 'task4',
        srNo: '4',
        fileNo: '730',
        client: 'client-412',
        taskSubTask: 'ACCOUNTING -- AY 2025-26',
        allottedBy: 'admin1',
        allottedTo: 'staff5',
        instruction: 'please do it as per guidlines',
        endDate: '28-02-2025',
        period: '-',
        status: TaskStatus.completed,
        priority: TaskPriority.medium,
      ),
      // Example of a non-completed task that won't have a selectable checkbox
      // VerificationTask(id: 'task5', srNo: '5', fileNo: '800', client: 'client-500', taskSubTask: 'OTHER TASK', allottedBy: 'admin2', allottedTo: 'staff1', instruction: 'pending task', endDate: '15-03-2025', period: '-', status: TaskStatus.awaiting, priority: TaskPriority.high), // Assume awaiting exists
    ];
    _filteredTasks = List.from(_verificationTasks);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _updateHeaderCheckboxState();
        });
      }
    });
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _dateController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- Controllers ---
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  // --- Helper Functions ---

  Future<void> _selectDate(BuildContext context) async {
    DateTime initial = DateTime.now();
    try {
      if (_dateController.text.isNotEmpty) {
        initial = DateFormat('dd-MM-yyyy').parse(_dateController.text);
      }
    } catch (e) {
      print("Error parsing date: $e");
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd-MM-yyyy').format(picked);
        _filterTasks(); // Trigger filter after date selection
      });
    }
  }

  void _updateHeaderCheckboxState() {
    final List<VerificationTask> selectableTasks =
        _filteredTasks
            .where((task) => task.status == TaskStatus.completed)
            .toList();

    if (selectableTasks.isEmpty) {
      _isAllSelected = false;
    } else {
      _isAllSelected = selectableTasks.every(
        (task) => _selectedTaskIds.contains(task.id),
      );
    }
  }

  void _filterTasks() {
    String query = _searchController.text.toLowerCase();
    String selectedDate = _dateController.text;

    setState(() {
      _filteredTasks =
          _verificationTasks.where((task) {
            bool matchesQuery =
                query.isEmpty ||
                task.fileNo.toLowerCase().contains(query) ||
                task.client.toLowerCase().contains(query) ||
                task.taskSubTask.toLowerCase().contains(query) ||
                task.allottedBy.toLowerCase().contains(query) ||
                task.allottedTo.toLowerCase().contains(query);
            bool matchesDate =
                selectedDate.isEmpty || task.endDate == selectedDate;
            return matchesQuery && matchesDate;
          }).toList();
      _selectedTaskIds.removeWhere(
        (id) => !_filteredTasks.any((task) => task.id == id),
      );
      _updateHeaderCheckboxState();
    });
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
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
                print("Search Pressed");
              },
              onNotificationPressed: () {
                print("Notifications Pressed");
              },
              onProfilePressed: () {
                print("Profile Pressed");
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
              _buildTopControls(),
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
          'Admin Verification',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color:
                Theme.of(context).primaryColorDark ?? const Color(0xFF0D47A1),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Home / Admin Verification / Data',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  // Corrected Top Controls Layout (Date and Show All only)
  Widget _buildTopControls() {
    return Column(
      // Outer Column remains for potential future rows
      children: [
        // --- Row for Date Filter and Show All ---
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.center, // Align items vertically in the row
          children: [
            // Date Label
            const Text('Date', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(width: 8), // Space after label
            // Date TextField in a SizedBox
            SizedBox(
              width: 150,
              height: 40, // Ensure consistent height with button
              child: TextField(
                controller:
                    _dateController, // Assuming _dateController is defined in your State
                readOnly: true,
                onTap: () async {
                  // Assuming _selectDate and _filterTasks are defined elsewhere
                  await _selectDate(context);
                  _filterTasks();
                },
                decoration: InputDecoration(
                  hintText: 'dd-mm-yyyy',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  border: const OutlineInputBorder(),
                  suffixIcon: Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  isDense: true, // Makes the text field vertically smaller
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(width: 16), // Space between TextField and Button
            // Show All Button
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Assuming _dateController, _searchController, _filterTasks exist
                  _dateController.clear();
                  _searchController.clear();
                  _filterTasks();
                });
                print('Show All Pressed');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20, // Adjust padding as needed
                  vertical: 10,
                ),
                minimumSize: const Size(
                  0,
                  40,
                ), // Match height with TextField SizedBox
              ),
              child: const Text('Show All'),
            ),

            // If you want the 'Show All' button pushed to the far right, add Spacer:
            // const Spacer(),
          ],
        ), // End of the Row
        // This SizedBox adds space *below* the row, before the next element (like the table)
        const SizedBox(height: 16),
      ], // End of outer Column children
    ); // End of outer Column
  }

  // --- End Dummy methods ---
  Widget _buildDataTableArea() {
    return Scrollbar(
      controller: _horizontalScrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _horizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: DataTable(
          dataRowMinHeight: 75.0,
          dataRowMaxHeight: 90.0,
          columnSpacing: 20.0,
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
          border: TableBorder.all(color: Colors.grey.shade300, width: 1),
          showCheckboxColumn:
              true, // <<< Let DataTable handle checkbox column display
          columns: _buildDataColumns(), // <<< Use the corrected columns list
          rows: _filteredTasks.map((task) => _buildDataRow(task)).toList(),
        ),
      ),
    );
  }

  // --- CORRECTED: Removed header Checkbox DataColumn ---
  List<DataColumn> _buildDataColumns() {
    return [
      // Checkbox column is handled by DataTable itself now
      const DataColumn(
        label: Text('Sr no.', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      const DataColumn(
        label: Text('File no.', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      const DataColumn(
        label: Text('Client', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      const DataColumn(
        label: Text(
          'Task -- Sub Task',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      const DataColumn(
        label: Text(
          'Allotted By',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      const DataColumn(
        label: Text(
          'Allotted To',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      const DataColumn(
        label: Text(
          'Instruction',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      const DataColumn(
        label: Text('End Date', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      const DataColumn(
        label: Text('Period', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      const DataColumn(
        label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      const DataColumn(
        label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    ];
  }

  // --- CORRECTED: Removed manual Checkbox DataCell ---
  DataRow _buildDataRow(VerificationTask task) {
    bool canSelect = task.status == TaskStatus.completed;
    bool isSelected = canSelect && _selectedTaskIds.contains(task.id);

    return DataRow(
      selected: isSelected,
      onSelectChanged:
          canSelect
              ? (bool? selected) {
                setState(() {
                  task.isSelected = selected ?? false;
                  if (task.isSelected) {
                    _selectedTaskIds.add(task.id);
                  } else {
                    _selectedTaskIds.remove(task.id);
                  }
                  _updateHeaderCheckboxState();
                });
              }
              : null,
      cells: [
        // Cells now directly correspond to the DataColumns above
        DataCell(Text(task.srNo)),
        DataCell(Text(task.fileNo)),
        DataCell(Text(task.client)),
        DataCell(Text(task.taskSubTask)),
        DataCell(Text(task.allottedBy)),
        DataCell(Text(task.allottedTo)),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              task.instruction,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ),
        DataCell(Text(task.endDate)),
        DataCell(Text(task.period)),
        DataCell(_buildStatusCell(task)),
        DataCell(_buildActionCell(task)),
      ],
    );
  }

  Widget _buildStatusCell(VerificationTask task) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Chip(
          label: Text(
            statusVerificationToString(task.status),
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
          backgroundColor: statusVerificationColor,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(height: 4),
        Chip(
          label: Text(
            priorityVerificationToString(task.priority),
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
          backgroundColor: statusVerificationColor,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(height: 4),
        if (task.approvalNeeded)
          const Text(
            '(Approval Needed)',
            style: TextStyle(fontSize: 11, color: Colors.black54),
          ),
      ],
    );
  }

  Widget _buildActionCell(VerificationTask task) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.remove_red_eye_outlined,
            color: Colors.blue.shade700,
            size: 20,
          ),
          onPressed: () {
            print('View action for ${task.id}');
          },
          tooltip: 'View Details',
          splashRadius: 18,
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
        IconButton(
          icon: Icon(
            Icons.check_circle_outline,
            color: Colors.green.shade700,
            size: 20,
          ),
          onPressed: () {
            print('Approve action for ${task.id}');
          },
          tooltip: 'Approve Task',
          splashRadius: 18,
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
      ],
    );
  }
} // End of _AdminVerificationState
