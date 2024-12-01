import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/document_model.dart';  // Import the Document model

// Define the API endpoint and headers
const String apiUrl = 'https://cosco.phase2.uat.edsgcc.com/api/app_documentAttachment/1/EDS-App-003';

const Map<String, String> headers = {
  'Authorization': 'apikeysyncdemo ECBFFE2D-8E76-4335-97FA-8502381B6EBF', // Replace with your actual token
  'COMPANY_SECRATE_KEY': '0273239B-C005-4DE3-8138-A4B8A4068A5B',         // Replace with your secret key
};

Future<Document> fetchDocument() async {
  try {
    // Send the GET request with headers
    final response = await http.get(Uri.parse(apiUrl), headers: headers);

    // Log the response body for debugging purposes
    print('Response Body: ${response.body}');

    // Check for a successful response
    if (response.statusCode == 200) {
      // Parse the JSON response
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse is Map<String, dynamic>) {
        return Document.fromJson(jsonResponse);
      } else {
        throw Exception('Unexpected data format: Expected a JSON object.');
      }
    } else {
      // Handle unsuccessful status codes with a custom error message
      print('Failed to load document. Status Code: ${response.statusCode}');
      throw Exception('Failed to load document: ${response.reasonPhrase} (Status Code: ${response.statusCode})');
    }
  } catch (error) {
    // Log any error that occurred during the request
    print('Error fetching document: $error');
    throw Exception('An error occurred while fetching the document: $error');
  }
}
