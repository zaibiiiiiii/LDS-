import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lds/API_Configuration/api.dart';
import 'package:lds/Models/rolemanage_model.dart';

class RoleManagementService {

  Future<RoleManagementResponse> fetchRoleManagementData() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}RoleManagement'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['rolemanagement'];
        return RoleManagementResponse.fromJson(data);
      } else {
        throw Exception("Failed to load data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching data: $e");
    }
  }
}
