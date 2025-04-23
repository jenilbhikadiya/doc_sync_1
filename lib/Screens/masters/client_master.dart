// client_master.dart
import 'dart:convert'; // For jsonDecode
import 'dart:math'; // For min/max functions
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For http calls
import 'package:data_table_2/data_table_2.dart'; // Use DataTable2
import 'package:intl/intl.dart'; // For DateFormat

// Import necessary components and models
import '../../components/common_appbar.dart'; // Adjust path if needed
import '../../components/drawer.dart'; // Adjust path if needed
import '../../modal/operations/client_modal.dart'; // Adjust path if needed
import '../../utils/constants.dart'; // Adjust path if needed for baseUrl

class ClientMaster extends StatefulWidget {
  const ClientMaster({super.key});

  @override
  State<ClientMaster> createState() => _ClientMasterState();
}

class _ClientMasterState extends State<ClientMaster> {
  // --- Keys and Controllers ---
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _dateController =
      TextEditingController(); // For date filter
  // Scroll controllers managed by DataTable2 internally

  // --- State Variables ---
  bool _isLoading = true; // For initial fetch indicator
  List<Client> _allClients = []; // Holds ALL fetched clients from the API
  List<Client> _clientsForCurrentPage =
      []; // Holds the subset for the current page

  // --- Pagination State Variables ---
  final int _rowsPerPage = 100; // Number of rows per page << ADJUST AS NEEDED
  int _currentPage = 1; // Current page number (1-based)
  int _totalPages = 1; // Total number of pages, calculated based on _allClients

  @override
  void initState() {
    super.initState();
    _fetchClients(); // Fetch initial data
  }

  @override
  void dispose() {
    _dateController.dispose(); // Dispose the date controller
    super.dispose();
  }

  // --- Data Fetching & Initial Processing ---
  Future<void> _fetchClients() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _allClients = [];
      _clientsForCurrentPage = []; // Clear lists
      _currentPage = 1; // Reset to first page
      _totalPages = 1; // Reset total pages
      _dateController.clear(); // Clear date filter on refresh
    });

    final String fetchUrl = '$baseUrl/get_client_list';
    final url = Uri.parse(fetchUrl);
    print("--- ClientMaster: Fetching Clients from $url ---");

    try {
      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 60));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (decodedData['data'] is List) {
          _allClients =
              (decodedData['data'] as List)
                  .map((json) => Client.fromJson(json))
                  .toList();
          _allClients.sort(
            (a, b) =>
                a.firm_name.toLowerCase().compareTo(b.firm_name.toLowerCase()),
          );
          _totalPages =
              (_allClients.isEmpty)
                  ? 1
                  : (_allClients.length / _rowsPerPage).ceil();
          _updateCurrentPageData(); // Initial population for page 1
          print(
            "--- ClientMaster: Clients Fetched Successfully (${_allClients.length}) ---",
          );
        } else {
          throw Exception('Failed to load clients: Invalid data format.');
        }
      } else {
        throw Exception(
          'Failed to load clients. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print("--- ClientMaster Exception: $e ---");
      if (mounted) {
        _showErrorSnackbar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- Update Display Subset based on _currentPage and _allClients ---
  void _updateCurrentPageData() {
    if (!mounted) return;
    // NOTE: This logic assumes NO filtering is applied other than pagination.
    // If date filtering is implemented, it should filter _allClients first,
    // recalculate _totalPages based on filtered results, THEN get the sublist.
    int startIndex = (_currentPage - 1) * _rowsPerPage;
    startIndex = max(
      0,
      min(startIndex, _allClients.length),
    ); // Clamp start index
    int endIndex = min(
      startIndex + _rowsPerPage,
      _allClients.length,
    ); // Clamp end index

    print(
      "--- Updating page data: Page $_currentPage of $_totalPages, Indices $startIndex-$endIndex ---",
    );
    setState(() {
      _clientsForCurrentPage = _allClients.sublist(startIndex, endIndex);
    });
  }

  // --- Go To Specific Page ---
  void _goToPage(int pageNumber) {
    if (!mounted || _isLoading) return;
    final int newPage = max(1, min(pageNumber, _totalPages));

    if (newPage != _currentPage) {
      print("--- Going to page: $newPage ---");
      setState(() {
        _currentPage = newPage;
      });
      _updateCurrentPageData(); // Update the data for the new page
    }
  }

  // --- Date Picker ---
  Future<void> _selectDate(BuildContext context) async {
    // Make sure context is valid
    if (!context.mounted) return;

    DateTime initial = DateTime.now();
    try {
      if (_dateController.text.isNotEmpty) {
        initial = DateFormat('dd-MM-yyyy').parse(_dateController.text);
      }
    } catch (e) {
      print("Error parsing date: $e - using today.");
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && mounted) {
      setState(() {
        _dateController.text = DateFormat('dd-MM-yyyy').format(picked);
        // --- TODO: Implement filtering based on the selected date ---
        // This would involve:
        // 1. Filtering _allClients based on the date logic.
        // 2. Storing the result in a separate _filteredClientsByDate list.
        // 3. Recalculating _totalPages based on the filtered list.
        // 4. Resetting _currentPage = 1.
        // 5. Updating _clientsForCurrentPage using the filtered list and new pagination state.
        print("Date selected: ${_dateController.text} - Filtering logic TBD");
      });
    }
  }

  // --- Show All (clears date filter and resets view) ---
  void _showAll() {
    if (!mounted) return;
    setState(() {
      _dateController.clear(); // Clear the date field
      // --- TODO: Remove any date filter applied to _allClients ---
      // Assuming for now _allClients always holds the full fetched list
      _currentPage = 1; // Reset to first page
      _totalPages =
          (_allClients.isEmpty)
              ? 1
              : (_allClients.length / _rowsPerPage).ceil();
      _updateCurrentPageData(); // Update display based on full list, page 1
      print("Showing all clients (date filter cleared)");
    });
  }

  // --- Snackbar Helper ---
  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final displayMessage =
        message.startsWith('Failed to') ? message : 'Error: $message';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(displayMessage),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // --- Action Handlers ---
  void _onAddPressed() {
    print("Add Client Pressed");
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Add action TBD')));
  }

  void _onViewPressed(Client client) {
    print("View Client: ${client.firm_name} (ID: ${client.client_id})");
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('View action TBD')));
  }

  void _onEditPressed(Client client) {
    print("Edit Client: ${client.firm_name} (ID: ${client.client_id})");
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Edit action TBD')));
  }

  void _onDeletePressed(Client client) {
    print("Delete Client: ${client.firm_name} (ID: ${client.client_id})");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text(
            'Are you sure you want to delete client "${client.firm_name}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Delete action TBD'),
                    backgroundColor: Colors.orange,
                  ),
                );
                // TODO: Implement API delete call then call _fetchClients();
              },
            ),
          ],
        );
      },
    );
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Builder(
          builder:
              (appBarContext) => CommonAppBar(
                logoAssetPath: 'assets/logos/logo.svg', // Your path
                onMenuPressed: () => Scaffold.of(appBarContext).openDrawer(),
                onSearchPressed: () => print("Search Action TBD"),
                onNotificationPressed: () => print("Notifications Pressed"),
                onProfilePressed: () => print("Profile Pressed"),
              ),
        ),
      ),
      drawer: const AnimatedDrawer(),
      body: RefreshIndicator(
        onRefresh: _fetchClients,
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
                _buildTopControls(), // Uses the TaskHistory Style Controls
                const SizedBox(height: 20),
                Expanded(
                  child:
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _allClients.isEmpty
                          ? const Center(
                            child: Text("No client data available."),
                          )
                          : _buildDataTableArea(),
                ),
                if (!_isLoading && _allClients.isNotEmpty)
                  _buildPaginationControls(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI Helper Widgets ---

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Client Master',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColorDark ?? Colors.blue.shade800,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Home / Client List / Data',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  // --- Top Controls like Task History (Date Filter, Show All, Add) ---
  Widget _buildTopControls() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: _onAddPressed,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // Example color
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            minimumSize: const Size(0, 40), // Match height
          ),
        ),
      ],
    );
  }

  // --- DataTable2 Implementation (Styled like Task History) ---
  Widget _buildDataTableArea() {
    final borderSide = BorderSide(
      color: Colors.grey.shade300,
      width: 1,
    ); // Match Task History border
    print(
      "--- Building DataTable2 with page $_currentPage data (${_clientsForCurrentPage.length} rows) ---",
    );

    return DataTable2(
      columnSpacing: 25.0, // Match Task History Spacing
      headingRowHeight: 48, // Match Task History (Adjust if needed)
      dividerThickness: 1,
      headingRowColor: MaterialStateProperty.all(
        Colors.grey.shade100,
      ), // Header BG
      border: TableBorder.all(
        color: Colors.grey.shade300,
        width: 1,
      ), // Table border
      showCheckboxColumn: false,
      minWidth: 1200, // Adjust required width

      columns: _buildDataColumns(),
      rows:
          _clientsForCurrentPage.asMap().entries.map((entry) {
            int indexOnPage = entry.key;
            Client client = entry.value;
            int globalSrNo =
                ((_currentPage - 1) * _rowsPerPage) + indexOnPage + 1;
            return _buildDataRow(
              client,
              globalSrNo,
              indexOnPage,
            ); // Pass index for alternating color
          }).toList(),

      empty: const Center(child: Text('No data for this page.')),
    );
  }

  List<DataColumn> _buildDataColumns() {
    return const [
      DataColumn2(
        label: Text('Sr no.', style: TextStyle(fontWeight: FontWeight.bold)),
        size: ColumnSize.S,
        numeric: true,
      ),
      DataColumn2(
        label: Text('File No.', style: TextStyle(fontWeight: FontWeight.bold)),
        size: ColumnSize.M,
      ),
      DataColumn2(
        label: Text('Firm Name', style: TextStyle(fontWeight: FontWeight.bold)),
        size: ColumnSize.L,
      ),
      DataColumn2(
        label: Text(
          'Contact Person',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        size: ColumnSize.M,
      ),
      DataColumn2(
        label: Text(
          'Contact No.',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        size: ColumnSize.M,
      ),
      DataColumn2(
        label: Text(
          'Accountant ID',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        size: ColumnSize.M,
      ),
      DataColumn2(
        label: Text('PAN', style: TextStyle(fontWeight: FontWeight.bold)),
        size: ColumnSize.M,
      ),
      DataColumn2(
        label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold)),
        size: ColumnSize.L,
        fixedWidth: 180,
      ),
    ];
  }

  // Builds row with alternating color
  DataRow _buildDataRow(Client client, int globalSrNo, int indexOnPage) {
    return DataRow2(
      key: ValueKey(client.client_id),
      // Add alternating row color
      color: MaterialStateProperty.resolveWith<Color?>((
        Set<MaterialState> states,
      ) {
        if (indexOnPage.isOdd) {
          return Colors.grey.withOpacity(0.05); // Light grey for odd rows
        }
        return null; // Default for even rows
      }),
      cells: [
        DataCell(Text(globalSrNo.toString())),
        DataCell(Text(client.file_no)),
        DataCell(Text(client.firm_name)),
        DataCell(Text(client.contact_person)),
        DataCell(Text(client.contact_no)),
        DataCell(Text(client.accountant_id)),
        DataCell(Text(client.pan)),
        DataCell(_buildActionCell(client)),
      ],
    );
  }

  // Action Cell Builder
  Widget _buildActionCell(Client client) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'View Client',
          child: IconButton(
            icon: Icon(
              Icons.remove_red_eye_outlined,
              color: Colors.blue.shade700,
              size: 20,
            ),
            onPressed: () => _onViewPressed(client),
            splashRadius: 18,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        ),
        Tooltip(
          message: 'Edit Client',
          child: IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: Colors.green.shade700,
              size: 20,
            ),
            onPressed: () => _onEditPressed(client),
            splashRadius: 18,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        ),
        Tooltip(
          message: 'Delete Client',
          child: IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red.shade600,
              size: 20,
            ),
            onPressed: () => _onDeletePressed(client),
            splashRadius: 18,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        ),
      ],
    );
  }

  // Pagination Controls
  Widget _buildPaginationControls() {
    final int displayTotalPages = max(1, _totalPages);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Flexible(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.first_page),
              onPressed: _currentPage <= 1 ? null : () => _goToPage(1),
              tooltip: 'First Page',
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed:
                  _currentPage <= 1 ? null : () => _goToPage(_currentPage - 1),
              tooltip: 'Previous Page',
            ),
            // const SizedBox(width: 16),
            Text(
              'Page $_currentPage of $displayTotalPages',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            // const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed:
                  _currentPage >= displayTotalPages
                      ? null
                      : () => _goToPage(_currentPage + 1),
              tooltip: 'Next Page',
            ),
            IconButton(
              icon: const Icon(Icons.last_page),
              onPressed:
                  _currentPage >= displayTotalPages
                      ? null
                      : () => _goToPage(displayTotalPages),
              tooltip: 'Last Page',
            ),
          ],
        ),
      ),
    );
  }
}
