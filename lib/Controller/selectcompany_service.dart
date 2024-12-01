import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lds/API_Configuration/api.dart';
import 'package:lds/Models/selectcompany_model.dart';

class SelectCompany {
// Define the API endpoint and headers
//   String apiUrl = 'https://6165-2400-adc1-484-8600-8110-9db-df88-2950.ngrok-free.app/SelectCompany';


  Future<selectcompany> fetchCompany() async {
    try {
      // Send the GET request with headers
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}SelectCompany'));

      // Log the response body for debugging purposes
      print('Response Body: ${response.body}');

      // Check for a successful response
      if (response.statusCode == 200) {
        // Parse the JSON response
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse is Map<String, dynamic>) {
          return selectcompany.fromJson(jsonResponse);
        } else {
          throw Exception('Unexpected data format: Expected a JSON object.');
        }
      } else {
        // Handle unsuccessful status codes with a custom error message
        print('Failed to load document. Status Code: ${response.statusCode}');
        throw Exception('Failed to load document: ${response
            .reasonPhrase} (Status Code: ${response.statusCode})');
      }
    } catch (error) {
      // Log any error that occurred during the request
      print('Error fetching document: $error');
      throw Exception('An error occurred while fetching the document: $error');
    }
  }
}