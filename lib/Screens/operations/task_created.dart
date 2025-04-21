// // lib/Screens/operations/task_created.dart (adjust path)
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:intl/intl.dart'; // For date picker
//
// // Adjust import paths based on your project structure
// import '../../components/common_appbar.dart';
// import '../../components/drawer.dart';
// import '../../modal/operations/task_modal.dart'; // Use the original Task model
// // Import the page to navigate to for adding tasks
// import 'add_new_task.dart';
//
// class TaskCreated extends StatefulWidget {
//   const TaskCreated({super.key});
//
//   @override
//   State<TaskCreated> createState() => _TaskCreatedState();
// }
//
// class _TaskCreatedState extends State<TaskCreated> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//
//   // --- State Variables ---
//   final TextEditingController _dateController = TextEditingController();
//   final TextEditingController _searchController = TextEditingController();
//   String _selectedEntriesPerPage = '10'; // Default
//   final List<String> _entriesOptions = ['10', '25', '50', '100'];
//
//   // --- Original Task Data ---
//   late List<Task> _tasks; // All tasks from source
//   List<Task> _filteredTasks = []; // Tasks currently displayed
//
//   @override
//   void initState() {
//     super.initState();
//     // Initialize sample data (Replace with actual data fetching)
//     _tasks = [
//       Task(
//         srNo: '1',
//         fileNo: 'AARJ',
//         client: 'client-111',
//         taskSubTask: 'GST -- GSTR 1 - Jan 25',
//         allottedBy: 'Pragma Admin',
//         allottedTo: 'admin1',
//         instructions:
//             'Task: GST Subtask: GSTR 1 - Jan 25 Period: 2022 Month From: Mar Month To: Mar',
//         period: '2022 Mar - Mar',
//         status: TaskStatus.allotted,
//         priority: TaskPriority.high,
//       ),
//       Task(
//         srNo: '2',
//         fileNo: '1497',
//         client: 'client-34',
//         taskSubTask: 'GST -- GSTR 1 DEC 24',
//         allottedBy: 'Pragma Admin',
//         allottedTo: 'Staff1',
//         instructions:
//             'Task: GST Subtask: GSTR 1 DEC 24 Period: 2022-23 Month To: Apr Month From: Jan plz do it asap',
//         period: '2022-23 Jan - Apr',
//         status: TaskStatus.completed,
//         priority: TaskPriority.high,
//       ),
//       Task(
//         srNo: '3',
//         fileNo: '51',
//         client: 'adobe',
//         taskSubTask: 'INCOME TAX -- ITR FILING',
//         allottedBy: 'Pragma Admin',
//         allottedTo: 'Staff1',
//         instructions:
//             'Task: INCOME TAX Subtask: ITR FILING Period: 2024-25 Month To: Mar Month From: Mar',
//         period: '2024-25 Mar - Mar',
//         status: TaskStatus.allotted,
//         priority: TaskPriority.medium,
//       ),
//       Task(
//         srNo: '4',
//         fileNo: '1111',
//         client: 'client-555',
//         taskSubTask: 'GST -- GST Amendment Notice',
//         allottedBy: 'Pragma Admin',
//         allottedTo: 'staff2',
//         instructions:
//             'Task: GST Subtask: GST Amendment Notice Period: 2018-19 Month To: Mar plz do it asap Month From: Mar',
//         period: '2018-19 Mar - Mar',
//         status: TaskStatus.awaiting,
//         priority: TaskPriority.high,
//       ),
//       Task(
//         srNo: '5',
//         fileNo: '1111',
//         client: 'client-555',
//         taskSubTask: 'GST -- GSTR 1 - Jan 25',
//         allottedBy: 'Staff1',
//         allottedTo: 'staff9',
//         instructions: 'please do it as per guidlines',
//         period: '-',
//         status: TaskStatus.reallotted,
//         priority: TaskPriority.high,
//       ),
//       Task(
//         srNo: '6',
//         fileNo: '1112',
//         client: 'client-XYZ',
//         taskSubTask: 'GST -- GSTR 1 - Feb 25',
//         allottedBy: 'Pragma Admin',
//         allottedTo: 'staff3',
//         instructions: 'Another task description here.',
//         period: '2024 Feb - Feb',
//         status: TaskStatus.completed,
//         priority: TaskPriority.low,
//       ),
//     ];
//     // Initialize filtered list
//     _filteredTasks = List.from(_tasks);
//   }
//
//   @override
//   void dispose() {
//     _horizontalScrollController.dispose();
//     _verticalScrollController.dispose();
//     _dateController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   // --- Controllers ---
//   final ScrollController _horizontalScrollController = ScrollController();
//   final ScrollController _verticalScrollController = ScrollController();
//
//   // --- Helper Functions ---
//
//   // Date Picker
//   Future<void> _selectDate(BuildContext context) async {
//     DateTime initial = DateTime.now();
//     try {
//       if (_dateController.text.isNotEmpty) {
//         initial = DateFormat('dd-MM-yyyy').parse(_dateController.text);
//       }
//     } catch (e) {
//       print("Error parsing date: $e");
//     }
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: initial,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null) {
//       setState(() {
//         _dateController.text = DateFormat('dd-MM-yyyy').format(picked);
//         _filterTasks(); // Trigger filter after date selection
//       });
//     }
//   }
//
//   // Filter Logic (Adapt based on relevant Task fields)
//   void _filterTasks() {
//     String query = _searchController.text.toLowerCase();
//     String selectedDateStr = _dateController.text;
//     // TODO: Decide how date filtering should work for TaskCreated.
//     // Does it filter by 'period' containing the date? Or an unshown 'allottedDate'?
//     // For now, date filter is ignored in this example. Add logic if needed.
//
//     setState(() {
//       _filteredTasks =
//           _tasks.where((task) {
//             // Basic Search Logic - adapt fields as needed
//             bool matchesQuery =
//                 query.isEmpty ||
//                 task.srNo.toLowerCase().contains(query) ||
//                 task.fileNo.toLowerCase().contains(query) ||
//                 task.client.toLowerCase().contains(query) ||
//                 task.taskSubTask.toLowerCase().contains(query) ||
//                 task.allottedBy.toLowerCase().contains(query) ||
//                 task.allottedTo.toLowerCase().contains(query) ||
//                 task.period.toLowerCase().contains(query) ||
//                 statusToString(task.status).toLowerCase().contains(query);
//
//             // TODO: Implement date matching logic if required for TaskCreated
//             bool matchesDate = true; // Always true for now
//             // Example: bool matchesDate = selectedDateStr.isEmpty || task.period.contains(selectedDateStr); // Crude example
//
//             return matchesQuery && matchesDate;
//           }).toList();
//       // No checkbox state to update here
//     });
//   }
//
//   // --- Main Build Method ---
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(kToolbarHeight),
//         child: Builder(
//           builder: (appBarContext) {
//             return CommonAppBar(
//               logoAssetPath: 'assets/logos/logo.svg', // Your path
//               onMenuPressed: () {
//                 Scaffold.of(appBarContext).openDrawer();
//               },
//               onSearchPressed: () {
//                 print("Search Pressed"); /* TODO: Implement Search action */
//               },
//               onNotificationPressed: () {
//                 print(
//                   "Notifications Pressed",
//                 ); /* TODO: Implement Notif action */
//               },
//               onProfilePressed: () {
//                 print("Profile Pressed"); /* TODO: Implement Profile action */
//               },
//             );
//           },
//         ),
//       ),
//       drawer: const AnimatedDrawer(),
//       body: SingleChildScrollView(
//         controller: _verticalScrollController,
//         padding: const EdgeInsets.all(16.0),
//         child: Container(
//           // Background container like AdminVerification
//           padding: const EdgeInsets.all(16.0),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(8.0),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.1),
//                 spreadRadius: 1,
//                 blurRadius: 3,
//                 offset: const Offset(0, 1),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildPageHeader(), // Modified Header
//               const SizedBox(height: 20),
//               _buildTopControls(), // Modified Controls
//               const SizedBox(height: 20),
//               _buildDataTableArea(), // Modified Table
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // --- Helper Widgets ---
//
//   // Modified Page Header
//   Widget _buildPageHeader() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Task Creation', // <<< Changed Title
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color:
//                 Theme.of(context).primaryColorDark ?? const Color(0xFF0D47A1),
//           ),
//         ),
//         const SizedBox(height: 4),
//         const Text(
//           'Home / Task Creation / Data', // <<< Changed Breadcrumb
//           style: TextStyle(color: Colors.grey, fontSize: 12),
//         ),
//       ],
//     );
//   }
//
//   // Modified Top Controls (Added 'Add' Button)
//   Widget _buildTopControls() {
//     return Column(
//       children: [
//         Row(
//           // Date, Show All, Add Row
//           children: [
//             const Text('Date', style: TextStyle(fontWeight: FontWeight.w500)),
//             const SizedBox(width: 8),
//             SizedBox(
//               width: 150,
//               height: 40,
//               child: TextField(
//                 controller: _dateController,
//                 readOnly: true,
//                 onTap: () async {
//                   await _selectDate(context);
//                   _filterTasks();
//                 },
//                 decoration: InputDecoration(
//                   hintText: 'dd-mm-yyyy',
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 10),
//                   border: const OutlineInputBorder(),
//                   suffixIcon: Icon(
//                     Icons.calendar_today,
//                     size: 16,
//                     color: Colors.grey.shade600,
//                   ),
//                   isDense: true,
//                 ),
//                 style: const TextStyle(fontSize: 14),
//               ),
//             ),
//             const SizedBox(width: 16),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   _dateController.clear();
//                   _searchController.clear();
//                   _filterTasks();
//                 });
//                 print('Show All Pressed');
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green.shade600,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 10,
//                 ),
//                 minimumSize: const Size(0, 40),
//               ),
//               child: const Text('Show All'),
//             ),
//             const Spacer(), // Push Add button to the right
//             // ElevatedButton.icon(
//             //   // <<< Added ADD Button
//             //   onPressed: () {
//             //     Navigator.push(
//             //       context,
//             //       MaterialPageRoute(
//             //         builder: (context) => const AddNewTaskPage(),
//             //       ),
//             //     );
//             //   },
//             //   icon: const Icon(Icons.add, size: 18),
//             //   label: const Text('Add'),
//             //   style: ElevatedButton.styleFrom(
//             //     backgroundColor: Colors.blue.shade700, // Or green
//             //     foregroundColor: Colors.white,
//             //     padding: const EdgeInsets.symmetric(
//             //       horizontal: 20,
//             //       vertical: 10,
//             //     ),
//             //     minimumSize: const Size(0, 40), // Match height
//             //   ),
//             // ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         Row(
//           // Entries & Search Row (same as AdminVerification)
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 SizedBox(
//                   width: 70,
//                   height: 40,
//                   child: DropdownButtonFormField<String>(
//                     value: _selectedEntriesPerPage,
//                     items:
//                         _entriesOptions
//                             .map(
//                               (String value) => DropdownMenuItem<String>(
//                                 value: value,
//                                 child: Text(
//                                   value,
//                                   style: const TextStyle(fontSize: 14),
//                                 ),
//                               ),
//                             )
//                             .toList(),
//                     onChanged: (String? newValue) {
//                       setState(() {
//                         _selectedEntriesPerPage =
//                             newValue!; /* TODO: Pagination */
//                       });
//                     },
//                     decoration: const InputDecoration(
//                       border: OutlineInputBorder(),
//                       contentPadding: EdgeInsets.symmetric(horizontal: 10),
//                       isDense: true,
//                     ),
//                     isExpanded: true,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 const Text('entries per page', style: TextStyle(fontSize: 14)),
//               ],
//             ),
//             const Spacer(),
//             SizedBox(
//               width: 250,
//               height: 40,
//               child: TextField(
//                 controller: _searchController,
//                 decoration: const InputDecoration(
//                   hintText: 'Search...',
//                   prefixIcon: Icon(Icons.search, size: 18),
//                   border: OutlineInputBorder(),
//                   contentPadding: EdgeInsets.symmetric(horizontal: 10),
//                   isDense: true,
//                 ),
//                 style: const TextStyle(fontSize: 14),
//                 onChanged: (value) {
//                   _filterTasks();
//                 },
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   // Modified DataTable Area
//   Widget _buildDataTableArea() {
//     return Scrollbar(
//       controller: _horizontalScrollController,
//       thumbVisibility: true,
//       child: SingleChildScrollView(
//         controller: _horizontalScrollController,
//         scrollDirection: Axis.horizontal,
//         child: DataTable(
//           dataRowMinHeight: 65.0, // Adjusted back for TaskCreated status cell
//           dataRowMaxHeight: 75.0, // Adjusted back
//           columnSpacing: 25.0, // Original spacing
//           headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
//           border: TableBorder.all(color: Colors.grey.shade300, width: 1),
//           showCheckboxColumn: false, // <<< No Checkboxes needed here
//           columns: _buildDataColumns(), // <<< Use TaskCreated columns
//           rows:
//               _filteredTasks
//                   .map((task) => _buildDataRow(task))
//                   .toList(), // Map filtered Task data
//         ),
//       ),
//     );
//   }
//
//   // --- TaskCreated Specific Data Columns ---
//   List<DataColumn> _buildDataColumns() {
//     return const [
//       DataColumn(
//         label: Text('Sr no.', style: TextStyle(fontWeight: FontWeight.bold)),
//       ),
//       DataColumn(
//         label: Text('File no.', style: TextStyle(fontWeight: FontWeight.bold)),
//       ),
//       DataColumn(
//         label: Text('Client', style: TextStyle(fontWeight: FontWeight.bold)),
//       ),
//       DataColumn(
//         label: Text(
//           'Task -- Sub Task',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//       ),
//       DataColumn(
//         label: Text(
//           'Allotted By',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//       ),
//       DataColumn(
//         label: Text(
//           'Allotted To',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//       ),
//       DataColumn(
//         label: Text(
//           'Instructions',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//       ),
//       DataColumn(
//         label: Text('Period', style: TextStyle(fontWeight: FontWeight.bold)),
//       ),
//       DataColumn(
//         label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
//       ),
//       DataColumn(
//         label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold)),
//       ),
//     ];
//   }
//
//   // --- TaskCreated Specific Data Row ---
//   DataRow _buildDataRow(Task task) {
//     return DataRow(
//       // No selection properties needed
//       cells: [
//         DataCell(Text(task.srNo)),
//         DataCell(Text(task.fileNo)),
//         DataCell(Text(task.client)),
//         DataCell(Text(task.taskSubTask)),
//         DataCell(Text(task.allottedBy)),
//         DataCell(Text(task.allottedTo)),
//         DataCell(
//           ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 200),
//             child: Text(
//               task.instructions,
//               overflow: TextOverflow.ellipsis,
//               maxLines: 2,
//             ),
//           ),
//         ),
//         DataCell(Text(task.period)),
//         // Use the ORIGINAL status/action cells for TaskCreated
//         DataCell(_buildStatusCell(task.status, task.priority)),
//         DataCell(_buildActionCell(task)),
//       ],
//     );
//   }
//
//   // --- ORIGINAL TaskCreated Status Cell ---
//   Widget _buildStatusCell(TaskStatus status, TaskPriority priority) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Chip(
//           label: Text(
//             statusToString(status),
//             style: const TextStyle(color: Colors.white, fontSize: 11),
//           ),
//           backgroundColor: statusToColor(status),
//           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
//           materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//           visualDensity: VisualDensity.compact,
//         ),
//         const SizedBox(height: 4),
//         Chip(
//           label: Text(
//             priorityToString(priority),
//             style: const TextStyle(color: Colors.white, fontSize: 11),
//           ),
//           backgroundColor: priorityToColor(priority),
//           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
//           materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//           visualDensity: VisualDensity.compact,
//         ),
//       ],
//     );
//   }
//
//   // --- ORIGINAL TaskCreated Action Cell ---
//   Widget _buildActionCell(Task task) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         IconButton(
//           icon: const Icon(Icons.currency_rupee, color: Colors.blue, size: 20),
//           onPressed: () {
//             print('Rupee action for ${task.srNo}');
//           },
//           tooltip: 'Payment',
//           splashRadius: 18,
//           constraints: const BoxConstraints(),
//           padding: const EdgeInsets.symmetric(horizontal: 4),
//         ),
//         IconButton(
//           icon: const Icon(
//             Icons.remove_red_eye_outlined,
//             color: Colors.blue,
//             size: 20,
//           ),
//           onPressed: () {
//             print('View action for ${task.srNo}');
//           },
//           tooltip: 'View Details',
//           splashRadius: 18,
//           constraints: const BoxConstraints(),
//           padding: const EdgeInsets.symmetric(horizontal: 4),
//         ),
//         IconButton(
//           icon: const Icon(Icons.edit_outlined, color: Colors.green, size: 20),
//           onPressed: () {
//             print('Edit action for ${task.srNo}'); /* TODO: Navigate to Edit? */
//           },
//           tooltip: 'Edit Task',
//           splashRadius: 18,
//           constraints: const BoxConstraints(),
//           padding: const EdgeInsets.symmetric(horizontal: 4),
//         ),
//         IconButton(
//           icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
//           onPressed: () {
//             print(
//               'Delete action for ${task.srNo}',
//             ); /* TODO: Show confirmation */
//           },
//           tooltip: 'Delete Task',
//           splashRadius: 18,
//           constraints: const BoxConstraints(),
//           padding: const EdgeInsets.symmetric(horizontal: 4),
//         ),
//       ],
//     );
//   }
// } // End of _TaskCreatedState
