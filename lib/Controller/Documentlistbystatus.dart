import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lds/API_Configuration/api.dart';
import 'package:lds/Models/Documentlistbystatus.dart';

class DocumentService {
  // Fetch documents by status
  Future<DocumentList> fetchDocumentsByStatus(String status) async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}DocumentsListByStatus?status=$status'));

      // Check if the response was successful (status code 200)
      if (response.statusCode == 200) {
        // Parse the JSON response
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Return the parsed DocumentList object
        return DocumentList.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load documents');
      }
    } catch (error) {
      // Handle errors (like no internet, invalid response, etc.)
      throw Exception('Error fetching documents: $error');
    }
  }
}
