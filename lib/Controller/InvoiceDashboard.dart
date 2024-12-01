import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lds/API_Configuration/api.dart';
import 'package:lds/Models/InvoiceDashboard.dart';

class InvoiceDashboardService {
  // Removed extra space at the beginning of _baseUrl

  Future<InvoiceDashboard?> fetchInvoiceDashboard() async {

    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}InvoiceDashboard'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return InvoiceDashboard.fromJson(jsonData);
      } else {
        print("Failed to load data: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching data: $e");
      return null;
    }
  }
}
