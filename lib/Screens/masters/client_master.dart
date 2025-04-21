import 'package:flutter/material.dart';

import '../../components/common_appbar.dart';
import '../../components/drawer.dart';
import '../../modal/masters/client_master.dart';

class ClientMaster extends StatefulWidget {
  const ClientMaster({super.key});

  @override
  State<ClientMaster> createState() => _ClientMasterState();
}

class _ClientMasterState extends State<ClientMaster> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  String _selectedEntriesPerPage = '10';
  final List<String> _entriesOptions = ['10', '25', '50', '100'];

  final List<ClientMasterItem> _clientData = [
    ClientMasterItem(
      id: '1',
      srNo: '1',
      fileNo: '786',
      firmName: 'task',
      contactPerson: 'DDD',
      contact: '7845632587',
      group: 'Group-43',
      accountant: 'No Accountant Assigned',
      pan: '7878',
    ),
    ClientMasterItem(
      id: '2',
      srNo: '2',
      fileNo: '8741',
      firmName: 'client-66',
      contactPerson: 'mr.jj',
      contact: '73468374933',
      group: 'Group-90',
      accountant: 'CA 7',
      pan: '1111',
    ),
    ClientMasterItem(
      id: '3',
      srNo: '3',
      fileNo: '6732',
      firmName: 'client-90',
      contactPerson: 'Mr.aaa1',
      contact: '6.76487849874E+16',
      group: '',
      accountant: '5625362',
      pan: 'pqr111',
    ),
    ClientMasterItem(
      id: '4',
      srNo: '4',
      fileNo: 'client-15',
      firmName: '',
      contactPerson: 'Mr. Xyz',
      contact: '9876543210',
      group: 'group-40, group-40',
      accountant: 'No Accountant Assigned',
      pan: 'xyz123',
    ),
    ClientMasterItem(
      id: '5',
      srNo: '5',
      fileNo: '51',
      firmName: 'adobe',
      contactPerson: 'jerome',
      contact: '1234567890',
      group: 'Group-40',
      accountant: 'CA 3',
      pan: 'AHMEE7743B',
    ),
    ClientMasterItem(
      id: '6',
      srNo: '6',
      fileNo: '1',
      firmName: '1',
      contactPerson: '1',
      contact: '1',
      group: '',
      accountant: 'No Accountant Assigned',
      pan: '122',
    ),
  ];

  List<ClientMasterItem> _filteredClients = [];

  @override
  void initState() {
    super.initState();

    _filteredClients = List.from(_clientData);
    _searchController.addListener(_filterClients);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterClients);
    _searchController.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  void _filterClients() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredClients = List.from(_clientData);
      } else {
        _filteredClients =
            _clientData.where((client) {
              return client.fileNo.toLowerCase().contains(query) ||
                  client.firmName.toLowerCase().contains(query) ||
                  client.contactPerson.toLowerCase().contains(query) ||
                  client.contact.toLowerCase().contains(query) ||
                  client.group.toLowerCase().contains(query) ||
                  client.accountant.toLowerCase().contains(query) ||
                  client.pan.toLowerCase().contains(query);
            }).toList();
      }
    });
  }

  void _onAddPressed() {
    print("Add Client Pressed");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigate to Add Client screen (TBD)'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _onExportPressed() {
    print("Export Data Pressed");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export data action (TBD)'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _onImportPressed() {
    print("Import Data Pressed");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Import data action (TBD)'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _onViewPressed(ClientMasterItem client) {
    print("View Client: ${client.firmName} (ID: ${client.id})");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('View details for ${client.firmName} (TBD)'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _onEditPressed(ClientMasterItem client) {
    print("Edit Client: ${client.firmName} (ID: ${client.id})");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit client ${client.firmName} (TBD)'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _onDeletePressed(ClientMasterItem client) {
    print("Delete Client: ${client.firmName} (ID: ${client.id})");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text(
            'Are you sure you want to delete client "${client.firmName}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Client ${client.firmName} delete action (TBD)',
                    ),
                    duration: Duration(seconds: 1),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Builder(
          builder: (appBarContext) {
            return CommonAppBar(
              logoAssetPath: 'assets/logos/logo.svg',
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

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Client Master',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColorDark ?? Colors.blue.shade900,
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

  Widget _buildTopControls() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: _onAddPressed,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),

            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _onExportPressed,
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: const Text('Export Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _onImportPressed,
                  icon: const Icon(Icons.download_for_offline, size: 18),
                  label: const Text('Import Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            SizedBox(
              height: 40,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedEntriesPerPage,
                  items:
                      _entriesOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Text(
                              value,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedEntriesPerPage = newValue!;

                      print("Entries per page: $_selectedEntriesPerPage");
                    });
                  },
                  focusColor: Colors.transparent,
                  style: TextStyle(color: Colors.grey.shade700),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'entries per page',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),

            const Spacer(),

            SizedBox(
              width: 250,
              height: 40,
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 18,
                    color: Colors.grey.shade500,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0),
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                      width: 1.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0),
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0),
                    borderSide: BorderSide(
                      color: Colors.blue.shade700,
                      width: 1.5,
                    ),
                  ),
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDataTableArea() {
    return Scrollbar(
      controller: _horizontalScrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _horizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 30.0,
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
          border: TableBorder.all(color: Colors.grey.shade300, width: 1),
          columns: _buildDataColumns(),
          rows:
              _filteredClients.map((client) => _buildDataRow(client)).toList(),
        ),
      ),
    );
  }

  Widget _buildSortableHeader(
    String label, {
    bool sorted = false,
    bool ascending = true,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),

        Icon(
          Icons.arrow_drop_up,
          size: 16,
          color: sorted && ascending ? Colors.black : Colors.grey.shade400,
        ),
        Icon(
          Icons.arrow_drop_down,
          size: 16,
          color: sorted && !ascending ? Colors.black : Colors.grey.shade400,
        ),
      ],
    );
  }

  List<DataColumn> _buildDataColumns() {
    return [
      DataColumn(label: _buildSortableHeader('Sr no')),
      DataColumn(label: _buildSortableHeader('File No.')),
      DataColumn(label: _buildSortableHeader('Firm Name')),
      DataColumn(label: _buildSortableHeader('Contact Person')),
      DataColumn(label: _buildSortableHeader('Contact')),
      DataColumn(label: _buildSortableHeader('Group')),
      DataColumn(label: _buildSortableHeader('Accountant')),
      DataColumn(label: _buildSortableHeader('PAN')),
      const DataColumn(
        label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    ];
  }

  DataRow _buildDataRow(ClientMasterItem client) {
    return DataRow(
      cells: [
        DataCell(Text(client.srNo)),
        DataCell(Text(client.fileNo)),
        DataCell(Text(client.firmName)),
        DataCell(Text(client.contactPerson)),
        DataCell(Text(client.contact)),
        DataCell(Text(client.group)),
        DataCell(Text(client.accountant)),
        DataCell(Text(client.pan)),
        DataCell(_buildActionCell(client)),
      ],
    );
  }

  Widget _buildActionCell(ClientMasterItem client) {
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
}
