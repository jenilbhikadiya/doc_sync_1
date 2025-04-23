import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math'; // For min/max
import 'dart:convert'; // For jsonDecode/Encode
import 'package:http/http.dart' as http; // Import http package

// --- Import your project-specific components and models ---
// --- PLEASE ADJUST THESE PATHS TO MATCH YOUR PROJECT STRUCTURE ---
import '../../components/common_appbar.dart'; // Path to your CommonAppBar widget
import '../../components/drawer.dart'; // Path to your AnimatedDrawer widget
import '../../modal/operations/admin_verification_task_modal.dart'; // Path to your UPDATED model
import '../../utils/constants.dart'; // Path to your constants file (ensure baseUrl is defined)
// -----------------------------------------------------------------

class AdminVerification extends StatefulWidget {
  const AdminVerification({super.key});

  @override
  State<AdminVerification> createState() => _AdminVerificationState();
}

class _AdminVerificationState extends State<AdminVerification> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // --- Controllers ---
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _pageVerticalScrollController = ScrollController();

  // --- Data State ---
  List<VerificationTask> _verificationTasks =
      []; // Holds ALL tasks *fetched for the current date filter*
  List<VerificationTask> _filteredTasks =
      []; // Holds tasks after client-side search filtering
  List<VerificationTask> _tasksForCurrentPage =
      []; // Holds tasks for the current page view

  // --- Selection State ---
  final Set<String> _selectedTaskIds =
      <String>{}; // Store IDs of selected rows across all pages

  // --- Pagination State ---
  int _currentPage = 1;
  int _totalPages = 1;
  late int _rowsPerPage;
  String _selectedEntriesPerPage = '10'; // Default value for the dropdown
  final List<String> _entriesOptions = [
    '10',
    '25',
    '50',
    '100',
  ]; // Dropdown options

  // --- Loading and Error State ---
  bool _isLoading = true; // Start loading initially
  String? _errorMessage; // To store any error message during fetch

  @override
  void initState() {
    super.initState();
    _rowsPerPage = int.tryParse(_selectedEntriesPerPage) ?? 10;

    // Optional: Set initial date filter (e.g., today)
    // _dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());

    // Add listener for search changes (for client-side filtering)
    _searchController.addListener(_applyClientSideSearch);

    // Fetch initial data (using the default or empty date filter)
    _fetchVerificationTasks(filterDate: _dateController.text);
  }

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    _searchController.removeListener(_applyClientSideSearch);
    _horizontalScrollController.dispose();
    _pageVerticalScrollController.dispose();
    _dateController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchVerificationTasks({String? filterDate}) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _verificationTasks = [];
      _filteredTasks = [];
      _tasksForCurrentPage = [];
      _selectedTaskIds.clear();
      _currentPage = 1;
      _totalPages = 1;
    });

    String apiFilterDate = '';
    if (filterDate != null && filterDate.isNotEmpty) {
      try {
        DateTime parsedDate = DateFormat('dd-MM-yyyy').parseStrict(filterDate);
        apiFilterDate = DateFormat('yyyy-MM-dd').format(parsedDate);
      } catch (e) {
        print("Error parsing filter date '$filterDate' for API: $e");
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = "Invalid date format selected.";
          });
        }
        return;
      }
    } else {
      print("No date filter provided.");
    }

    final String apiUrl = '$baseUrl/get_admin_verification';
    final url = Uri.parse(apiUrl);

    // --- Prepare Request Body for Form Encoding ---
    // 1. Create the inner payload map
    final Map<String, dynamic> requestPayload = {
      "filter_task_date": apiFilterDate,
    };
    // 2. Encode the inner payload map into a JSON *string*
    final String innerJsonValue = jsonEncode(requestPayload);
    // 3. Create the final Map<String, String> for the form body
    final Map<String, String> requestBody = {'data': innerJsonValue};
    // --------------------------------------------

    print("--- Fetching Admin Verification Tasks (Form Encoded) ---");
    print("URL: $apiUrl");
    print("Body (Form Data): $requestBody"); // Log the form data map

    try {
      final response = await http
          .post(
            url,
            headers: {
              // Set Accept header, Content-Type will be added automatically
              // for form encoding by the http package.
              'Accept': 'application/json',
              // DO NOT set 'Content-Type': 'application/json...' here
            },
            // Pass the Map<String, String> directly to body for form encoding
            body: requestBody,
          )
          .timeout(const Duration(seconds: 60));

      if (!mounted) return;

      // --- Process Response (Keep the rest the same) ---
      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        print(
          "--- API Response Body: ${response.body} ---",
        ); // Log successful response body

        if (decodedData is Map &&
            decodedData['success'] == true &&
            decodedData['data'] is List) {
          List<VerificationTask> fetchedTasks =
              (decodedData['data'] as List)
                  .map((jsonItem) {
                    if (jsonItem is Map<String, dynamic>) {
                      try {
                        return VerificationTask.fromJson(jsonItem);
                      } catch (e) {
                        print("Error parsing task JSON: $e\nJSON: $jsonItem");
                        return null;
                      }
                    } else {
                      print("Warning: Invalid item format: $jsonItem");
                      return null;
                    }
                  })
                  .whereType<VerificationTask>()
                  .toList();

          for (int i = 0; i < fetchedTasks.length; i++) {
            fetchedTasks[i].srNo = (i + 1).toString();
          }

          setState(() {
            _verificationTasks = fetchedTasks;
            _applyClientSideSearch();
          });
          print(
            "--- Tasks Fetched Successfully (${_verificationTasks.length}) ---",
          );
        } else {
          final message =
              decodedData is Map
                  ? decodedData['message']?.toString()
                  : 'Invalid response format.';
          print("--- API Error (Logic): $message ---");
          throw Exception(
            message ?? 'Failed to load tasks: Invalid data from API.',
          );
        }
      } else {
        print(
          "--- API Error (HTTP): Status ${response.statusCode}, Body: ${response.body} ---",
        );
        throw Exception(
          'Failed to load tasks. Server Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      print("--- Exception during fetch: $e ---");
      if (mounted) {
        setState(() {
          _errorMessage = "Error: ${e.toString()}";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  } // --- Client-Side Search and Pagination Logic ---

  // Applies ONLY the client-side text search to the fetched `_verificationTasks`
  void _applyClientSideSearch() {
    if (!mounted) return;
    String query = _searchController.text.toLowerCase().trim();

    // Filter based on the current `_verificationTasks` (results from API for the selected date)
    if (query.isEmpty) {
      _filteredTasks = List.from(_verificationTasks); // No search query
    } else {
      _filteredTasks =
          _verificationTasks.where((task) {
            // --- Add ALL fields you want to search client-side ---
            return task.srNo.toLowerCase().contains(query) ||
                task.fileNo.toLowerCase().contains(query) ||
                task.client.toLowerCase().contains(query) ||
                task.taskSubTask.toLowerCase().contains(query) ||
                task.allottedBy.toLowerCase().contains(query) ||
                task.allottedTo.toLowerCase().contains(query) ||
                task.instruction.toLowerCase().contains(query) ||
                task.endDate.toLowerCase().contains(
                  query,
                ) || // Search formatted end date
                task.allottedDate.toLowerCase().contains(
                  query,
                ) || // Search formatted allotted date
                (task.monthFrom?.toLowerCase().contains(query) ?? false) ||
                (task.monthTo?.toLowerCase().contains(query) ?? false) ||
                task.financialYear.toLowerCase().contains(query) ||
                statusVerificationToString(
                  task.status,
                ).toLowerCase().contains(query) ||
                priorityVerificationToString(
                  task.priority,
                ).toLowerCase().contains(query);
            // --------------------------------------------------
          }).toList();
    }

    // Clean up selected IDs no longer relevant
    _selectedTaskIds.removeWhere(
      (id) => !_filteredTasks.any((task) => task.id == id),
    );

    // Reset pagination and update UI *after* client-side filtering
    // No need to call setState here as _calculatePagination calls _updateCurrentPageData which calls setState
    _currentPage = 1;
    _calculatePagination();
  }

  // --- Pagination Logic ---
  void _calculatePagination() {
    if (!mounted) return;
    _totalPages =
        (_filteredTasks.isEmpty)
            ? 1
            : (_filteredTasks.length / _rowsPerPage).ceil();
    _currentPage = max(1, min(_currentPage, _totalPages));
    _updateCurrentPageData(); // Update data for the (potentially adjusted) current page
  }

  void _updateCurrentPageData() {
    if (!mounted) return;
    int startIndex = (_currentPage - 1) * _rowsPerPage;
    startIndex = max(0, min(startIndex, _filteredTasks.length));
    int endIndex = min(startIndex + _rowsPerPage, _filteredTasks.length);
    final pageData = _filteredTasks.sublist(startIndex, endIndex);

    // Check mount status again before final setState
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
      }); // Update page first
      _updateCurrentPageData(); // Then update data for that page
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
        _currentPage = 1; // Reset to first page
      });
      _calculatePagination(); // Recalculate and update data
      print("--- Rows per page changed to: $_rowsPerPage ---");
    }
  }

  // --- Checkbox Logic ---
  void _handleSelectAllOnPage(bool? selectAll) {
    if (!mounted) return;
    final bool select = selectAll ?? false;
    setState(() {
      for (var task in _tasksForCurrentPage) {
        if (task.status == TaskStatus.completed) {
          // Only select 'completed' tasks
          if (select) {
            _selectedTaskIds.add(task.id);
          } else {
            _selectedTaskIds.remove(task.id);
          }
        }
      }
    });
    print(
      "--- Handled select all on page: $select. Total selected: ${_selectedTaskIds.length} ---",
    );
  }

  // --- UI Trigger Logic ---
  Future<void> _selectDate(BuildContext context) async {
    DateTime initial = DateTime.now();
    try {
      if (_dateController.text.isNotEmpty) {
        initial = DateFormat('dd-MM-yyyy').parseStrict(_dateController.text);
      }
    } catch (e) {
      print("Error parsing date from controller: $e");
    } // Use parseStrict

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && mounted) {
      final String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
      // Check if date actually changed before fetching
      if (_dateController.text != formattedDate) {
        setState(() {
          _dateController.text = formattedDate;
        });
        _fetchVerificationTasks(filterDate: formattedDate); // Fetch new data
      }
    }
  }

  void _clearFilters() {
    bool needsRefetch =
        _dateController.text.isNotEmpty; // Check if date needs clearing
    setState(() {
      _dateController.clear();
      _searchController
          .clear(); // Will trigger _applyClientSideSearch via listener
    });
    if (needsRefetch) {
      _fetchVerificationTasks(); // Fetch all data (pass null/empty date)
    } else {
      // If only search was cleared, just re-apply client side search
      _applyClientSideSearch();
    }
    print('Filters Cleared.');
  }

  // --- Error Snackbar ---
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

  // --- Action Button Handlers ---
  void _onAddPressed() {
    print("Add Pressed");
  }

  void _onViewPressed(VerificationTask task) {
    print("View: ${task.id}");
  }

  void _onEditPressed(VerificationTask task) {
    print("Edit: ${task.id}");
  }

  void _onDeletePressed(VerificationTask task) {
    print("Delete: ${task.id}");
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    // Determine if header checkbox should be checked based on current page selections
    final selectableTasksOnPage = _tasksForCurrentPage.where(
      (t) => t.status == TaskStatus.completed,
    );
    final bool allSelectableOnPageAreSelected =
        selectableTasksOnPage.isNotEmpty &&
        selectableTasksOnPage.every((t) => _selectedTaskIds.contains(t.id));

    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Builder(
          builder:
              (appBarContext) => CommonAppBar(
                logoAssetPath: 'assets/logos/logo.svg', // Adjust path
                onMenuPressed: () => Scaffold.of(appBarContext).openDrawer(),
                onNotificationPressed: () => print("Notifications Pressed"),
                onProfilePressed: () => print("Profile Pressed"),
              ),
        ),
      ),
      drawer: const AnimatedDrawer(),
      body: RefreshIndicator(
        // Allow pull-to-refresh
        onRefresh:
            () => _fetchVerificationTasks(filterDate: _dateController.text),
        child: SingleChildScrollView(
          // For overall page vertical scrolling
          controller: _pageVerticalScrollController,
          padding: const EdgeInsets.all(16.0),
          physics:
              const AlwaysScrollableScrollPhysics(), // Ensure scroll works with RefreshIndicator
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
              // Main content column
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPageHeader(),
                const SizedBox(height: 20),
                _buildTopControls(),
                const SizedBox(height: 20),
                // --- Main Content Area ---
                _isLoading
                    ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 50),
                        child: CircularProgressIndicator(),
                      ),
                    )
                    : _errorMessage != null
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 50),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                    // Check _filteredTasks (after client search) for empty message
                    : _filteredTasks.isEmpty
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 50),
                        child: Text(
                          _searchController.text.isNotEmpty
                              ? "No tasks match your search for the selected date."
                              : "No tasks found for the selected date.",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                    : _buildDataTableArea(
                      allSelectableOnPageAreSelected,
                    ), // Build table
                const SizedBox(height: 10),
                // Show pagination only if not loading, no error, and there are FILTERED tasks to paginate
                if (!_isLoading &&
                    _errorMessage == null &&
                    _filteredTasks.isNotEmpty)
                  _buildPaginationControls(),
              ],
            ),
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
            const SizedBox(width: 20),
            const Text('Date:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
          ],
        ),
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
        ElevatedButton(
          onPressed: _clearFilters,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            minimumSize: const Size(0, 40),
          ),
          child: const Text('Show All'),
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
                  hintText: 'Search within results...',
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

  // Builds the DataTable Area
  Widget _buildDataTableArea(bool allSelectableOnPageAreSelected) {
    return Scrollbar(
      controller: _horizontalScrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _horizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20.0,
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
          border: TableBorder.all(color: Colors.grey.shade300, width: 1),
          showCheckboxColumn:
              true, // Let DataTable manage checkbox column space
          onSelectAll:
              _handleSelectAllOnPage, // Handler for header checkbox tap
          columns: _buildDataColumns(),
          rows:
              _tasksForCurrentPage.map((task) => _buildDataRow(task)).toList(),
        ),
      ),
    );
  }

  // Builds the Data Columns - *MUST* match the number of cells in _buildDataRow
  List<DataColumn> _buildDataColumns() {
    // Define only your DATA columns (11 of them)
    // DataTable handles the first checkbox column automatically when showCheckboxColumn=true
    return [
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
      // const DataColumn( label: Text('Period', style: TextStyle(fontWeight: FontWeight.bold)),), // Removed 'period' based on model update? Add back if needed.
      const DataColumn(
        label: Text(
          'Financial Year',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ), // Example using new field
      const DataColumn(
        label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      const DataColumn(
        label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    ];
  }

  // Builds a single DataRow - *MUST* provide cells matching DataColumns
  DataRow _buildDataRow(VerificationTask task) {
    bool canSelect = task.status == TaskStatus.completed;
    bool isSelected = canSelect && _selectedTaskIds.contains(task.id);

    return DataRow(
      selected: isSelected,
      // Provide onSelectChanged to enable row checkbox rendering AND interaction
      onSelectChanged:
          canSelect
              ? (bool? selected) {
                setState(() {
                  if (selected ?? false) {
                    _selectedTaskIds.add(task.id);
                  } else {
                    _selectedTaskIds.remove(task.id);
                  }
                });
              }
              : null,
      // Provide exactly the same number of DataCells as DataColumns defined above
      cells: [
        // No DataCell for checkbox - DataTable handles it
        DataCell(Text(task.srNo)), // Use the assigned srNo
        DataCell(Text(task.fileNo)),
        DataCell(Text(task.client)),
        DataCell(Text(task.taskSubTask)),
        DataCell(Text(task.allottedBy)),
        DataCell(Text(task.allottedTo)),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Tooltip(
              message: task.instruction,
              child: Text(
                task.instruction,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ),
        ),
        DataCell(Text(task.endDate)),
        // DataCell(Text(task.period)), // Removed 'period'? Add back if needed.
        DataCell(Text(task.financialYear)), // Example using new field
        DataCell(_buildStatusCell(task)),
        DataCell(_buildActionCell(task)),
      ],
    );
  }

  // Builds the Status Cell
  Widget _buildStatusCell(VerificationTask task) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Chip(
            label: Text(
              statusVerificationToString(task.status),
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            backgroundColor: statusVerificationColor(task.status),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            labelPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 4),
          Chip(
            label: Text(
              priorityVerificationToString(task.priority),
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            backgroundColor: priorityVerificationColor(task.priority),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            labelPadding: EdgeInsets.zero,
          ),
          if (task.approvalNeeded) ...[
            const SizedBox(height: 4),
            const Text(
              '(Approval Needed)',
              style: TextStyle(
                fontSize: 10,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Builds the Action Cell
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
          onPressed: () => _onViewPressed(task), // Pass task
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
          onPressed:
              () => _onEditPressed(task), // Example: Use edit for approve?
          tooltip: 'Approve Task',
          splashRadius: 18,
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
        // Add delete button if needed
        // IconButton( icon: Icon( Icons.delete_outline, color: Colors.red.shade600, size: 20,), onPressed: () => _onDeletePressed(task), tooltip: 'Delete Task', ... ),
      ],
    );
  }

  // Build Pagination Controls Widget
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
} // End of _AdminVerificationState
