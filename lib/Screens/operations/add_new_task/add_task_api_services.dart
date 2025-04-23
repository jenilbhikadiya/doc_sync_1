import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../modal/operations/financial_year.dart';
import '../../../modal/operations/staff_modal.dart';
import '../../../modal/operations/sub_task_modal.dart';
import '../../../modal/operations/task_modal.dart';
import '../../../modal/operations/client_modal.dart';
import '../../../utils/constants.dart';

class ApiService {
  final String _baseUrl = baseUrl;

  Never _handleError(http.Response response, String context) {
    String errorMessage;
    try {
      final decoded = jsonDecode(response.body);
      errorMessage = decoded['message'] ?? response.body;
    } catch (_) {
      errorMessage = response.body;
    }
    print(
      "--- API Service Error ($context): ${response.statusCode}, Body: ${response.body} ---",
    );
    throw Exception(
      'Failed to $context. Status: ${response.statusCode}. Error: $errorMessage',
    );
  }

  Never _handleException(Object e, String context) {
    print("--- API Service Exception ($context): $e ---");
    throw Exception('Failed to $context: $e');
  }

  Future<List<Task>> fetchTasks() async {
    final url = Uri.parse('$_baseUrl/get_task_list');
    print("--- Service: Fetching Tasks from $url ---");
    try {
      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (decodedData['success'] == true && decodedData['data'] is List) {
          List<Task> loadedTasks =
              (decodedData['data'] as List)
                  .map((json) => Task.fromJson(json))
                  .toList();
          loadedTasks.sort(
            (a, b) =>
                a.TaskName.toLowerCase().compareTo(b.TaskName.toLowerCase()),
          );
          print(
            "--- Service: Tasks Fetched Successfully (${loadedTasks.length}) ---",
          );
          return loadedTasks;
        } else {
          _handleError(response, 'load tasks (API Error)');
        }
      } else {
        _handleError(response, 'load tasks (HTTP Error)');
      }
    } catch (e) {
      _handleException(e, 'fetch tasks');
    }
  }

  Future<List<SubTask>> fetchSubTasks(String taskId) async {
    final url = Uri.parse('$_baseUrl/get_sub_task_list');

    final String innerJsonValue = jsonEncode({'id': taskId});
    final Map<String, String> formData = {'data': innerJsonValue};
    print("--- Service: Fetching Sub-Tasks for Task ID: $taskId from $url ---");
    print("--- Service: Sub-Task Request Body (Form Data): $formData ---");

    try {
      final response = await http
          .post(url, headers: {'Accept': 'application/json'}, body: formData)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        print("--- Service: Sub-Task Response Body: ${response.body} ---");

        if (decodedData['success'] == true && decodedData['data'] is List) {
          List<SubTask> loadedSubTasks =
              (decodedData['data'] as List)
                  .map((json) => SubTask.fromJson(json))
                  .toList();
          loadedSubTasks.sort(
            (a, b) => a.subTaskName.toLowerCase().compareTo(
              b.subTaskName.toLowerCase(),
            ),
          );
          print(
            "--- Service: Sub-Tasks Fetched Successfully (${loadedSubTasks.length}) ---",
          );
          return loadedSubTasks;
        } else if (decodedData['success'] == false &&
            (decodedData['message'] as String?)?.toLowerCase().contains(
                  'no data found',
                ) ==
                true) {
          print(
            "--- Service: No Sub-Tasks found for Task ID: $taskId (API Response Handled) ---",
          );
          return [];
        } else {
          final String errorMessage =
              decodedData['message'] ??
              decodedData['response'] ??
              'Unknown API logic error';
          print(
            "--- Service Error (fetchSubTasks - API Logic Error): $errorMessage ---",
          );

          throw Exception('Failed to load sub-tasks: $errorMessage');
        }
      } else {
        print(
          "--- Service Error (fetchSubTasks - HTTP Error): Status ${response.statusCode} ---",
        );

        throw Exception(
          'Failed to load sub-tasks. Server responded with status ${response.statusCode}',
        );
      }
    } catch (e) {
      print("--- Service Exception (fetchSubTasks): ${e.runtimeType} - $e ---");

      throw Exception('Failed to fetch sub-tasks: $e');
    }
  }

  Future<List<Client>> fetchClients() async {
    final url = Uri.parse('$_baseUrl/get_client_list');
    print("--- Service: Fetching Clients from $url ---");
    try {
      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (decodedData['success'] == true && decodedData['data'] is List) {
          List<Client> loadedClients =
              (decodedData['data'] as List)
                  .map((json) => Client.fromJson(json))
                  .toList();
          loadedClients.sort(
            (a, b) =>
                a.firm_name.toLowerCase().compareTo(b.firm_name.toLowerCase()),
          );
          print(
            "--- Service: Clients Fetched Successfully (${loadedClients.length}) ---",
          );
          return loadedClients;
        } else {
          _handleError(response, 'load clients (API Error)');
        }
      } else {
        _handleError(response, 'load clients (HTTP Error)');
      }
    } catch (e) {
      _handleException(e, 'fetch clients');
    }
  }

  Future<List<Staff>> fetchStaff() async {
    final url = Uri.parse('$_baseUrl/get_staff_list');
    print("--- Service: Fetching Staff from $url ---");
    try {
      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (decodedData['success'] == true && decodedData['data'] is List) {
          List<Staff> loadedStaff =
              (decodedData['data'] as List)
                  .map((json) => Staff.fromJson(json))
                  .toList();
          loadedStaff.sort(
            (a, b) => a.staff_name.toLowerCase().compareTo(
              b.staff_name.toLowerCase(),
            ),
          );
          print(
            "--- Service: Staff Fetched Successfully (${loadedStaff.length}) ---",
          );
          return loadedStaff;
        } else {
          _handleError(response, 'load staff (API Error)');
        }
      } else {
        _handleError(response, 'load staff (HTTP Error)');
      }
    } catch (e) {
      _handleException(e, 'fetch staff');
    }
  }

  Future<List<FinancialYear>> fetchFinancialYears() async {
    final url = Uri.parse('$_baseUrl/get_financial_year_list');
    print("--- Service: Fetching Financial Years from $url ---");
    try {
      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (decodedData['success'] == true && decodedData['data'] is List) {
          List<FinancialYear> loadedFYears =
              (decodedData['data'] as List)
                  .map((json) => FinancialYear.fromJson(json))
                  .toList();
          loadedFYears.sort(
            (a, b) => a.financial_year.toLowerCase().compareTo(
              b.financial_year.toLowerCase(),
            ),
          );
          print(
            "--- Service: Financial Years Fetched Successfully (${loadedFYears.length}) ---",
          );
          return loadedFYears;
        } else {
          _handleError(response, 'load financial years (API Error)');
        }
      } else {
        _handleError(response, 'load financial years (HTTP Error)');
      }
    } catch (e) {
      _handleException(e, 'fetch financial years');
    }
  }

  Future<String> submitTask(Map<String, String> taskData) async {
    final url = Uri.parse('$_baseUrl/add_new_taskcreation');
    final String innerJsonPayload = jsonEncode(taskData);
    final Map<String, String> formData = {'data': innerJsonPayload};

    print("--- Service: Submitting Task to $url ---");
    print(
      "--- Service: Task Request Body (Form Data with nested JSON): $formData ---",
    );

    try {
      final response = await http
          .post(url, headers: {'Accept': 'application/json'}, body: formData)
          .timeout(const Duration(seconds: 30));

      print("--- Service: Submit Task API Response Received ---");
      print("Status Code: ${response.statusCode}");
      print("Body (Raw): ${response.body}");
      print("--------------------------------------------");

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (decodedData['success'] == true) {
          return decodedData['message'] ?? 'Task submitted successfully!';
        } else {
          _handleError(response, 'submit task (API Error)');
        }
      } else {
        _handleError(response, 'submit task (HTTP Error)');
      }
    } catch (e) {
      _handleException(e, 'submit task');
    }
  }
}
