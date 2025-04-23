import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:data_table_2/data_table_2.dart';

import '../../components/common_appbar.dart';
import '../../components/drawer.dart';
import '../../modal/operations/task_modal.dart';
import '../../utils/constants.dart';

class TaskHistoryScreen extends StatefulWidget {
  const TaskHistoryScreen({super.key});

  @override
  State<TaskHistoryScreen> createState() => _TaskHistoryScreenState();
}

class _TaskHistoryScreenState extends State<TaskHistoryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _pageVerticalScrollController = ScrollController();

  List<Task> _allTasks = [];
  List<Task> _filteredTasks = [];
  List<Task> _tasksForCurrentPage = [];

  int _currentPage = 1;
  int _totalPages = 1;
  late int _rowsPerPage;
  String _selectedEntriesPerPage = '10';
  final List<String> _entriesOptions = ['10', '25', '50', '100'];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _rowsPerPage = int.tryParse(_selectedEntriesPerPage) ?? 10;
    _searchController.addListener(_applyClientSideSearch);
    _fetchTaskHistory(DateTime.now());
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyClientSideSearch);
    _dateController.dispose();
    _searchController.dispose();
    _pageVerticalScrollController.dispose();

    super.dispose();
  }

  Future<void> _fetchTaskHistory(DateTime? selectedDate) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
      _allTasks = [];
      _filteredTasks = [];
      _tasksForCurrentPage = [];
      _currentPage = 1;
      _totalPages = 1;
    });

    final String formattedApiDate =
        selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(selectedDate)
            : "";
    final String dataPayload = jsonEncode({'alloted_date': formattedApiDate});
    final Map<String, String> formData = {'data': dataPayload};
    final String apiUrl = '$baseUrl/get_task_details';
    final url = Uri.parse(apiUrl);

    print("--- Fetching Task History ---");
    print("URL: $apiUrl");
    print("Body (Form Data): $formData");

    try {
      final response = await http
          .post(url, body: formData, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 60));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        print("--- Task History Response: ${response.body} ---");

        if (decodedResponse is Map &&
            decodedResponse['success'] == true &&
            decodedResponse['data'] is List) {
          final List<dynamic> taskData = decodedResponse['data'];
          final List<Task> fetchedTasks =
              taskData
                  .map((json) {
                    if (json is Map<String, dynamic>) {
                      try {
                        return Task.fromJson(json);
                      } catch (e) {
                        print("Error parsing Task JSON: $e\nJSON: $json");
                        return null;
                      }
                    }
                    print("Warning: Invalid item format: $json");
                    return null;
                  })
                  .whereType<Task>()
                  .toList();

          if (!mounted) return;
          setState(() {
            _allTasks = fetchedTasks;
            _isLoading = false;
            _error = null;
            _applyClientSideSearch(resetPage: true);
          });
          print(
            "--- Task History Fetched Successfully (${_allTasks.length}) ---",
          );
        } else {
          final message =
              decodedResponse is Map
                  ? (decodedResponse['message'] ??
                      'No data found or success false')
                  : 'Unexpected response format';
          print("--- Task History API Info: $message ---");
          if (!mounted) return;
          setState(() {
            _error =
                message.toLowerCase().contains('no data found')
                    ? 'No task history found.'
                    : "API Error: $message";
            _isLoading = false;
            _allTasks = [];
            _filteredTasks = [];
            _tasksForCurrentPage = [];
            _calculatePagination();
          });
        }
      } else {
        print(
          "--- Task History Fetch Error (HTTP ${response.statusCode}): ${response.body} ---",
        );
        if (!mounted) return;
        setState(() {
          _error = 'Server Error: ${response.statusCode}';
          _isLoading = false;
          _allTasks = [];
          _filteredTasks = [];
          _tasksForCurrentPage = [];
          _calculatePagination();
        });
      }
    } catch (e) {
      if (!mounted) return;
      print("--- Exception fetching Task History: $e ---");
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
        _allTasks = [];
        _filteredTasks = [];
        _tasksForCurrentPage = [];
        _calculatePagination();
      });
    }
  }

  void _applyClientSideSearch({bool resetPage = true}) {
    if (!mounted) return;
    String query = _searchController.text.toLowerCase().trim();
    List<Task> newlyFiltered;
    if (query.isEmpty) {
      newlyFiltered = List.from(_allTasks);
    } else {
      newlyFiltered =
          _allTasks.where((task) {
            return (task.srNo?.toLowerCase().contains(query) ?? false) ||
                (task.fileNo?.toLowerCase().contains(query) ?? false) ||
                (task.client?.toLowerCase().contains(query) ?? false) ||
                (task.taskSubTask?.toLowerCase().contains(query) ?? false) ||
                (task.allottedBy?.toLowerCase().contains(query) ?? false) ||
                (task.allottedTo?.toLowerCase().contains(query) ?? false) ||
                (task.instructions?.toLowerCase().contains(query) ?? false) ||
                (task.period?.toLowerCase().contains(query) ?? false) ||
                (task.TaskName.toLowerCase().contains(query) ?? false) ||
                (formatTaskDate(
                  task.allottedDate,
                ).toLowerCase().contains(query)) ||
                (formatTaskDate(
                  task.expectedEndDate,
                ).toLowerCase().contains(query)) ||
                (statusToString(task.status).toLowerCase().contains(query)) ||
                (priorityToString(task.priority).toLowerCase().contains(query));
          }).toList();
    }
    _filteredTasks = newlyFiltered;
    if (resetPage) {
      _currentPage = 1;
    }
    _calculatePagination();
  }

  Future<void> _selectDate(BuildContext context) async {
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
      final String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
      if (_dateController.text != formattedDate) {
        setState(() {
          _dateController.text = formattedDate;
        });
        _fetchTaskHistory(picked);
      }
    }
  }

  void _clearFilters() {
    bool needsRefetch = _dateController.text.isNotEmpty;
    _dateController.clear();
    _searchController.clear();
    setState(() {});
    if (needsRefetch) {
      _fetchTaskHistory(null);
    }

    print('Filters Cleared');
  }

  void _calculatePagination() {
    if (!mounted) return;
    _totalPages =
        (_filteredTasks.isEmpty)
            ? 1
            : (_filteredTasks.length / _rowsPerPage).ceil();
    _currentPage = max(1, min(_currentPage, _totalPages));
    _updateCurrentPageData();
  }

  void _updateCurrentPageData() {
    if (!mounted) return;
    int startIndex = (_currentPage - 1) * _rowsPerPage;
    startIndex = max(0, min(startIndex, _filteredTasks.length));
    int endIndex = min(startIndex + _rowsPerPage, _filteredTasks.length);
    final pageData = _filteredTasks.sublist(startIndex, endIndex);
    if (mounted) {
      setState(() {
        _tasksForCurrentPage = pageData;
      });
    }
    print(
      "--- Page data updated: Page $_currentPage/$_totalPages, Rows $startIndex-$endIndex ---",
    );
  }

  void _goToPage(int pageNumber) {
    if (!mounted || _isLoading) return;
    final int newPage = max(1, min(pageNumber, _totalPages));
    if (newPage != _currentPage) {
      setState(() {
        _currentPage = newPage;
      });
      _updateCurrentPageData();
      if (_pageVerticalScrollController.hasClients) {
        _pageVerticalScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
      print("--- Navigated to page: $newPage ---");
    }
  }

  void _onEntriesPerPageChanged(String? newValue) {
    if (newValue == null || !mounted) return;
    int? newRowsPerPage = int.tryParse(newValue);
    if (newRowsPerPage != null && newRowsPerPage != _rowsPerPage) {
      setState(() {
        _selectedEntriesPerPage = newValue;
        _rowsPerPage = newRowsPerPage;
        _currentPage = 1;
      });
      _calculatePagination();
      print("--- Rows per page changed to: $_rowsPerPage ---");
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _onViewPressed(Task task) {
    print("View: ${task.Taskid}");
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
                logoAssetPath: 'assets/logos/logo.svg',
                onMenuPressed: () => Scaffold.of(appBarContext).openDrawer(),
                onNotificationPressed: () => print("Notifications Pressed"),
                onProfilePressed: () => print("Profile Pressed"),
              ),
        ),
      ),
      drawer: const AnimatedDrawer(),
      body: RefreshIndicator(
        onRefresh:
            () => _fetchTaskHistory(
              _dateController.text.isEmpty
                  ? null
                  : DateFormat('dd-MM-yyyy').parseStrict(_dateController.text),
            ),
        child: Padding(
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

                Expanded(
                  child:
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _error != null
                          ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                _error!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                          : _filteredTasks.isEmpty
                          ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                _searchController.text.isNotEmpty
                                    ? "No history matches search."
                                    : "No task history found.",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                          : _buildDataTableArea(),
                ),

                if (!_isLoading && _error == null && _filteredTasks.isNotEmpty)
                  _buildPaginationControls(),
              ],
            ),
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
          'Task History',
          style: TextStyle(
            fontSize: 20,
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

  Widget _buildTopControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("Show ", style: TextStyle(color: Colors.grey)),
            SizedBox(
              height: 40,
              child: DropdownButton<String>(
                value: _selectedEntriesPerPage,
                focusColor: Colors.transparent,
                underline: Container(height: 1, color: Colors.grey.shade400),
                onChanged: _onEntriesPerPageChanged,
                items:
                    _entriesOptions.map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
            const Text(" entries", style: TextStyle(color: Colors.grey)),
            const SizedBox(width: 16),
          ],
        ),
        ElevatedButton(
          onPressed: _clearFilters,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            minimumSize: const Size(0, 40),
          ),
          child: const Text('Show All'),
        ),

        const SizedBox(width: 20),
        const Text('Date:', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        SizedBox(
          width: 150,
          height: 40,
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
        const SizedBox(height: 16),
        Row(
          children: [
            const Spacer(),
            SizedBox(
              width: 300,
              height: 40,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search history...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 10,
                  ),
                  isDense: true,
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => _searchController.clear(),
                            splashRadius: 15,
                          )
                          : null,
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDataTableArea() {
    print(
      "Building DataTable2 with page $_currentPage data (${_tasksForCurrentPage.length} rows)",
    );

    return DataTable2(
      columnSpacing: 25.0,
      horizontalMargin: 12,
      minWidth: 1800,
      border: TableBorder.all(color: Colors.grey.shade300, width: 1),
      dividerThickness: 1,
      showCheckboxColumn: false,
      showBottomBorder: true,

      headingRowHeight: 48,
      headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),

      dataRowHeight: null,

      columns: _buildDataColumns(),

      rows:
          _tasksForCurrentPage.asMap().entries.map((entry) {
            int indexOnPage = entry.key;
            Task task = entry.value;
            int globalSrNo =
                ((_currentPage - 1) * _rowsPerPage) + indexOnPage + 1;
            return _buildDataRow(task, globalSrNo, indexOnPage);
          }).toList(),

      empty: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: const Text('No data available for this page.'),
        ),
      ),
    );
  }

  List<DataColumn2> _buildDataColumns() {
    const TextStyle headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    return const [
      DataColumn2(
        label: Text('Sr no.', style: headerStyle),
        size: ColumnSize.S,
        numeric: true,
      ),
      DataColumn2(
        label: Text('File no.', style: headerStyle),
        size: ColumnSize.S,
      ),
      DataColumn2(
        label: Text('Client', style: headerStyle),
        size: ColumnSize.M,
      ),
      DataColumn2(
        label: Text('Task -- Sub Task', style: headerStyle),
        size: ColumnSize.L,
      ),
      DataColumn2(
        label: Text('Allotted By', style: headerStyle),
        size: ColumnSize.M,
      ),
      DataColumn2(
        label: Text('Allotted To', style: headerStyle),
        size: ColumnSize.M,
      ),

      DataColumn2(
        label: Text('Instructions', style: headerStyle),
        size: ColumnSize.L,
      ),

      DataColumn2(
        label: Text('Period', style: headerStyle),
        size: ColumnSize.S,
      ),
      DataColumn2(
        label: Text('Status', style: headerStyle),
        size: ColumnSize.M,
      ),
      DataColumn2(
        label: Text('Priority', style: headerStyle),
        size: ColumnSize.M,
      ),
      DataColumn2(
        label: Text('Allotted Date', style: headerStyle),
        size: ColumnSize.M,
      ),
      DataColumn2(
        label: Text('End Date', style: headerStyle),
        size: ColumnSize.M,
      ),
      DataColumn2(
        label: Text('Action', style: headerStyle),
        size: ColumnSize.S,
        fixedWidth: 100,
      ),
    ];
  }

  DataRow2 _buildDataRow(Task task, int globalSrNo, int indexOnPage) {
    const String na = 'N/A';

    return DataRow2(
      color: MaterialStateProperty.resolveWith<Color?>(
        (_) => indexOnPage.isOdd ? Colors.black.withOpacity(0.03) : null,
      ),
      cells: [
        DataCell(Text(globalSrNo.toString())),
        DataCell(Text(task.fileNo ?? na)),
        DataCell(Text(task.client ?? na)),
        DataCell(Text(task.taskSubTask ?? task.TaskName)),
        DataCell(Text(task.allottedBy ?? na)),
        DataCell(Text(task.allottedTo ?? na)),

        DataCell(
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(task.instructions ?? na, maxLines: 5),
          ),
        ),
        DataCell(Text(task.period ?? na)),
        DataCell(_buildStatusChip(task.status)),
        DataCell(_buildPriorityChip(task.priority)),
        DataCell(Text(formatTaskDate(task.allottedDate))),
        DataCell(Text(formatTaskDate(task.expectedEndDate))),
        DataCell(_buildActionCell(task)),
      ],
    );
  }

  Widget _buildStatusChip(TaskStatus? status) {
    if (status == null) return const Text('N/A');
    return Chip(
      label: Text(
        statusToString(status),
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
      backgroundColor: statusToColor(status),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildPriorityChip(TaskPriority? priority) {
    if (priority == null) return const Text('N/A');
    return Chip(
      label: Text(
        priorityToString(priority),
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
      backgroundColor: priorityToColor(priority),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildActionCell(Task task) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.remove_red_eye_outlined,
            color: Colors.blue.shade700,
            size: 20,
          ),
          onPressed: () => _onViewPressed(task),
          tooltip: 'View Details',
          splashRadius: 18,
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
      ],
    );
  }

  Widget _buildPaginationControls() {
    final buttonSplashRadius = 20.0;
    final iconColor = Colors.grey.shade700;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Showing ${(_tasksForCurrentPage.isEmpty) ? 0 : (_currentPage - 1) * _rowsPerPage + 1} to ${min(_currentPage * _rowsPerPage, _filteredTasks.length)} of ${_filteredTasks.length} entries",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.first_page, color: iconColor),
                onPressed: _currentPage <= 1 ? null : () => _goToPage(1),
                tooltip: 'First Page',
                splashRadius: buttonSplashRadius,
              ),
              IconButton(
                icon: Icon(Icons.chevron_left, color: iconColor),
                onPressed:
                    _currentPage <= 1
                        ? null
                        : () => _goToPage(_currentPage - 1),
                tooltip: 'Previous Page',
                splashRadius: buttonSplashRadius,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Text(
                  'Page $_currentPage of $_totalPages',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.black87),
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: iconColor),
                onPressed:
                    _currentPage >= _totalPages
                        ? null
                        : () => _goToPage(_currentPage + 1),
                tooltip: 'Next Page',
                splashRadius: buttonSplashRadius,
              ),
              IconButton(
                icon: Icon(Icons.last_page, color: iconColor),
                onPressed:
                    _currentPage >= _totalPages
                        ? null
                        : () => _goToPage(_totalPages),
                tooltip: 'Last Page',
                splashRadius: buttonSplashRadius,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
