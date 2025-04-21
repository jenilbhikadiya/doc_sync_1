// lib/models/client_master_item.dart (or your preferred path)

class ClientMasterItem {
  final String srNo;
  final String fileNo;
  final String firmName;
  final String contactPerson;
  final String contact; // Phone number or other contact info
  final String group;
  final String accountant;
  final String pan;
  final String id; // Unique ID for actions/selection if needed

  ClientMasterItem({
    required this.id,
    required this.srNo,
    required this.fileNo,
    required this.firmName,
    required this.contactPerson,
    required this.contact,
    required this.group,
    required this.accountant,
    required this.pan,
  });
}
