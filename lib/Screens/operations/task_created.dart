import 'package:doc_sync_1/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:data_table_2/data_table_2.dart';

import '../../components/common_appbar.dart';
import '../../components/drawer.dart';
import '../../modal/operations/task_modal.dart';
import 'add_new_task/add_new_task.dart';

class TaskCreated extends StatefulWidget {
  const TaskCreated({super.key});

  @override
  State<TaskCreated> createState() => _TaskCreatedState();
}

class _TaskCreatedState extends State<TaskCreated> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  List<Task> _paginatedTasks = [];

  bool _isLoading = false;
  String? _error;

  int _currentPage = 1;
  final int _rowsPerPage = 25;
  int _totalPages = 1;

  final ScrollController _verticalScrollController = ScrollController();

  final String _apiUrl = '$baseUrl/get_task_details';

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    _fetchTasks(DateTime.now());
    _searchController.addListener(() => _filterTasks());
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _dateController.dispose();
    _searchController.removeListener(() => _filterTasks());
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTasks(DateTime selectedDate) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
      _tasks = [];
      _filteredTasks = [];
      _paginatedTasks = [];
      _currentPage = 1;
      _totalPages = 1;
    });

    final String formattedApiDate = DateFormat(
      'yyyy-MM-dd',
    ).format(selectedDate);
    final String dataPayload = jsonEncode({'alloted_date': formattedApiDate});

    try {
      final response = await http
          .post(Uri.parse(_apiUrl), body: {'data': dataPayload})
          .timeout(const Duration(seconds: 60));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);

        if (decodedResponse['success'] == true &&
            decodedResponse['data'] != null) {
          final List<dynamic> taskData = decodedResponse['data'];
          final List<Task> fetchedTasks =
              taskData
                  .map((json) => Task.fromJson(json as Map<String, dynamic>))
                  .toList();

          setState(() {
            _tasks = fetchedTasks;
            _filteredTasks = List.from(_tasks);
            _isLoading = false;
            _error = null;
            _filterTasks(shouldUpdatePagination: false);
            _updatePaginationState();
          });
        } else {
          if (!mounted) return;
          setState(() {
            _error =
                decodedResponse['message'] ??
                'API Error: No data found or success false.';
            _isLoading = false;
            _tasks = [];
            _filteredTasks = [];
            _paginatedTasks = [];
            _updatePaginationState();
          });
        }
      } else {
        if (!mounted) return;
        setState(() {
          _error = 'Server Error: ${response.statusCode}';
          _isLoading = false;
          _tasks = [];
          _filteredTasks = [];
          _paginatedTasks = [];
          _updatePaginationState();
        });
      }
    } catch (e) {
      if (!mounted) return;
      print("Error fetching tasks: $e");
      setState(() {
        _error = 'Network or parsing error occurred: ${e.toString()}';
        _isLoading = false;
        _tasks = [];
        _filteredTasks = [];
        _paginatedTasks = [];
        _updatePaginationState();
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    if (!context.mounted) return;
    DateTime initial = DateTime.now();
    try {
      if (_dateController.text.isNotEmpty) {
        initial = DateFormat('dd-MM-yyyy').parseStrict(_dateController.text);
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

    if (picked != null && mounted) {
      final String formattedDisplayDate = DateFormat(
        'dd-MM-yyyy',
      ).format(picked);
      if (formattedDisplayDate != _dateController.text) {
        setState(() {
          _dateController.text = formattedDisplayDate;
        });
        await _fetchTasks(picked);
      }
    }
  }

  void _filterTasks({bool shouldUpdatePagination = true}) {
    String query = _searchController.text.toLowerCase().trim();
    List<Task> newlyFiltered;
    if (query.isEmpty) {
      newlyFiltered = List.from(_tasks);
    } else {
      newlyFiltered =
          _tasks.where((task) {
            final srNoMatch = (task.srNo ?? '').toLowerCase().contains(query);
            final fileNoMatch = (task.fileNo ?? '').toLowerCase().contains(
              query,
            );
            final clientMatch = (task.client ?? '').toLowerCase().contains(
              query,
            );
            final taskSubTaskMatch = (task.taskSubTask ?? '')
                .toLowerCase()
                .contains(query);
            final allottedByMatch = (task.allottedBy ?? '')
                .toLowerCase()
                .contains(query);
            final allottedToMatch = (task.allottedTo ?? '')
                .toLowerCase()
                .contains(query);
            final periodMatch = (task.period ?? '').toLowerCase().contains(
              query,
            );
            final statusMatch = statusToString(
              task.status,
            ).toLowerCase().contains(query);
            final priorityMatch = priorityToString(
              task.priority,
            ).toLowerCase().contains(query);
            final instructionsMatch = (task.instructions ?? '')
                .toLowerCase()
                .contains(query);
            return srNoMatch ||
                fileNoMatch ||
                clientMatch ||
                taskSubTaskMatch ||
                allottedByMatch ||
                allottedToMatch ||
                periodMatch ||
                statusMatch ||
                priorityMatch ||
                instructionsMatch;
          }).toList();
    }

    if (!mounted) return;
    setState(() {
      _filteredTasks = newlyFiltered;
      if (shouldUpdatePagination) {
        _currentPage = 1;
        _updatePaginationState();
      } else {
        _getPaginatedTasks();
      }
    });
  }

  void _updatePaginationState() {
    if (!mounted) return;
    setState(() {
      _totalPages =
          _filteredTasks.isEmpty
              ? 1
              : (_filteredTasks.length / _rowsPerPage).ceil();
      _currentPage = _currentPage.clamp(1, _totalPages);
      _getPaginatedTasks();
    });
  }

  void _getPaginatedTasks() {
    if (!mounted) return;
    final int startIndex = (_currentPage - 1) * _rowsPerPage;
    int endIndex = min(startIndex + _rowsPerPage, _filteredTasks.length);
    if (startIndex < _filteredTasks.length && startIndex <= endIndex) {
      _paginatedTasks = _filteredTasks.sublist(startIndex, endIndex);
    } else {
      _paginatedTasks = [];
    }
  }

  void _goToPage(int pageNumber) {
    if (!mounted || _isLoading) return;
    final int newPage = max(1, min(pageNumber, _totalPages));
    if (newPage != _currentPage) {
      if (!mounted) return;
      setState(() {
        _currentPage = newPage;
        _getPaginatedTasks();
      });
      if (_verticalScrollController.hasClients) {
        _verticalScrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Builder(
          builder:
              (appBarContext) => CommonAppBar(
                onMenuPressed: () => Scaffold.of(appBarContext).openDrawer(),
                onNotificationPressed: () => print("Notifications Pressed"),
                onProfilePressed: () => print("Profile Pressed"),
              ),
        ),
      ),
      drawer: const AnimatedDrawer(),
      body: Padding(
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

              Expanded(child: _buildContentArea()),

              if (!_isLoading && _error == null && _filteredTasks.isNotEmpty)
                _buildPaginationControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task List',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color:
                Theme.of(context).primaryColorDark ?? const Color(0xFF0D47A1),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Home / Tasks / Task List',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTopControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddNewTaskPage(),
                    ),
                  ),
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              label: const Text(
                'Add Task',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                minimumSize: const Size(0, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Allotted Date',
                  hintText: 'Select Date',
                  prefixIcon: const Icon(Icons.calendar_today, size: 18),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.edit_calendar_outlined, size: 20),
                    tooltip: 'Select Date',
                    onPressed: () => _selectDate(context),
                    splashRadius: 18,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ),
                onTap: () => _selectDate(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search Tasks',
                  hintText: 'Search by keyword...',
                  prefixIcon: Icon(Icons.search, size: 18),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContentArea() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed:
                    () => _fetchTasks(
                      _dateController.text.isNotEmpty
                          ? DateFormat('dd-MM-yyyy').parse(_dateController.text)
                          : DateTime.now(),
                    ),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    } else if (_filteredTasks.isEmpty) {
      final bool noDataForDate = _tasks.isEmpty;
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                noDataForDate
                    ? 'No tasks found for the selected date.'
                    : 'No tasks match your search criteria.',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    } else {
      return _buildDataTableArea();
    }
  }

  Widget _buildDataTableArea() {
    print(
      "Building DataTable2 with page $_currentPage data (${_paginatedTasks.length} rows)",
    );

    return DataTable2(
      columnSpacing: 25.0,
      horizontalMargin: 12,
      minWidth: 1400,
      headingRowHeight: 48,
      dataRowHeight: 70,
      headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
      border: TableBorder.all(color: Colors.grey.shade300, width: 1),
      dividerThickness: 1,
      showCheckboxColumn: false,
      columns: _buildDataColumns(),
      // ***** CHANGE IS HERE *****
      rows: List.generate(_paginatedTasks.length, (index) {
        // Calculate the global Sr. No. based on current page and index on page
        final int globalSrNo =
            ((_currentPage - 1) * _rowsPerPage) +
            index +
            1; // Using _rowsPerPage

        // Pass the Task and the calculated globalSrNo
        return _buildDataRow(_paginatedTasks[index], globalSrNo, index);
      }),
      // *************************
      empty: Center(
        child: Text(
          'No tasks available for this page.',
          style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
        ),
      ),
    );
  }

  List<DataColumn2> _buildDataColumns() {
    const TextStyle headingStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    return const [
      DataColumn2(
        label: Text('Sr No.', style: headingStyle),
        fixedWidth: 50,
        numeric: true,
      ),
      DataColumn2(
        label: Text('File No.', style: headingStyle),
        size: ColumnSize.S,
      ),
      DataColumn2(
        label: Text('Client', style: headingStyle),
        size: ColumnSize.M,
      ),
      DataColumn2(
        label: Text('Task -- Sub Task', style: headingStyle),
        size: ColumnSize.L,
      ),
      DataColumn2(
        label: Text('Allotted By', style: headingStyle),
        size: ColumnSize.M,
      ),
      DataColumn2(
        label: Text('Allotted To', style: headingStyle),
        size: ColumnSize.M,
      ),
      DataColumn2(
        label: Text('Instructions', style: headingStyle),
        size: ColumnSize.L,
      ),
      DataColumn2(
        label: Text('Period', style: headingStyle),
        size: ColumnSize.M,
      ),
      DataColumn2(
        label: Text('Status / Priority', style: headingStyle),
        size: ColumnSize.M,
      ),
      DataColumn2(label: Text('Action', style: headingStyle), fixedWidth: 220),
    ];
  }

  // Update the parameter name from reversedSrNo to pageSrNo
  // ***** CHANGE IS HERE: Added globalSrNo parameter *****
  DataRow2 _buildDataRow(Task task, int globalSrNo, int indexOnPage) {
    const String na = 'N/A';

    return DataRow2(
      color: MaterialStateProperty.resolveWith<Color?>((
        Set<MaterialState> states,
      ) {
        if (indexOnPage.isOdd) {
          return Colors.grey.withOpacity(0.05);
        }
        return null;
      }),
      cells: [
        // ***** CHANGE IS HERE: Use the passed globalSrNo *****
        DataCell(Text(globalSrNo.toString())),
        // *****************************************************
        DataCell(Text(task.fileNo ?? na)),
        DataCell(Text(task.client ?? na)),
        DataCell(
          Text(task.taskSubTask ?? task.TaskName),
        ), // Use TaskName as fallback
        DataCell(Text(task.allottedBy ?? na)),
        DataCell(Text(task.allottedTo ?? na)),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Tooltip(
              message: task.instructions ?? '',
              child: Text(
                task.instructions ?? na,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ),
        ),
        DataCell(Text(task.period ?? na)),
        DataCell(_buildStatusCell(task.status, task.priority)),
        DataCell(_buildActionCell(task)),
      ],
    );
  }

  Widget _buildStatusCell(TaskStatus? status, TaskPriority? priority) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Chip(
          label: Text(
            statusToString(status),
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
          backgroundColor: statusToColor(status),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(height: 4),
        Chip(
          label: Text(
            priorityToString(priority),
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
          backgroundColor: priorityToColor(priority),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  Widget _buildActionCell(Task task) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(
              Icons.currency_rupee,
              color: Colors.blue,
              size: 20,
            ),
            onPressed: () => print('Payment: ${task.Taskid}'),
            tooltip: 'Payment',
            splashRadius: 18,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          IconButton(
            icon: const Icon(
              Icons.remove_red_eye_outlined,
              color: Colors.teal,
              size: 20,
            ),
            onPressed: () => print('View: ${task.Taskid}'),
            tooltip: 'View Details',
            splashRadius: 18,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: Colors.orange,
              size: 20,
            ),
            onPressed: () => print('Edit: ${task.Taskid}'),
            tooltip: 'Edit Task',
            splashRadius: 18,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: () => print('Delete: ${task.Taskid}'),
            tooltip: 'Delete Task',
            splashRadius: 18,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls() {
    final int displayTotalPages = max(1, _totalPages);
    Widget buildNavButton({
      required IconData icon,
      required String tooltip,
      required VoidCallback? onPressed,
    }) {
      return Expanded(
        child: IconButton(
          icon: Icon(icon),
          iconSize: 22,
          tooltip: tooltip,
          onPressed: onPressed,
          splashRadius: 20,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          padding: EdgeInsets.zero,
          color:
              onPressed != null ? Theme.of(context).primaryColor : Colors.grey,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildNavButton(
            icon: Icons.first_page,
            tooltip: 'First Page',
            onPressed: _currentPage <= 1 ? null : () => _goToPage(1),
          ),
          buildNavButton(
            icon: Icons.chevron_left,
            tooltip: 'Previous Page',
            onPressed:
                _currentPage <= 1 ? null : () => _goToPage(_currentPage - 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Page $_currentPage of $displayTotalPages',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.normal),
            ),
          ),
          buildNavButton(
            icon: Icons.chevron_right,
            tooltip: 'Next Page',
            onPressed:
                _currentPage >= displayTotalPages
                    ? null
                    : () => _goToPage(_currentPage + 1),
          ),
          buildNavButton(
            icon: Icons.last_page,
            tooltip: 'Last Page',
            onPressed:
                _currentPage >= displayTotalPages
                    ? null
                    : () => _goToPage(displayTotalPages),
          ),
        ],
      ),
    );
  }
}
