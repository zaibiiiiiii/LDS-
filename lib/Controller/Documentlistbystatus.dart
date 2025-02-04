import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../Models/Documentlistbystatus.dart';

class DashboardDetailsService {
  final String baseUrl =
      'https://posapi.lakhanisolution.com/api/App/GetDashboardDetails';

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Fetch document details
  Future<ApiResponse> fetchDocumentDetails({
    required DateTime periodFrom,
    required DateTime periodTo,
    required String docType,
    required String status,
  }) async {
    try {
      // Retrieve token and companyId from secure storage
      final String? token = await _secureStorage.read(key: 'AccessToken');
      final String? companyId = await _secureStorage.read(key: 'Company_Id');

      if (token == null || companyId == null) {
        throw Exception('Token or Company ID not found in secure storage');
      }

      // Format dates
      final String formattedPeriodFrom = DateFormat('dd-MM-yyyy').format(periodFrom);
      final String formattedPeriodTo = DateFormat('dd-MM-yyyy').format(periodTo);

      // Build the request URL
      final Uri url = Uri.parse(
        '$baseUrl?Company_Id=$companyId&Period_From=$formattedPeriodFrom&Period_To=$formattedPeriodTo&Doc_Type=$docType&Status=$status',
      );

      // Define headers with the dynamic token
      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
      };

      print('Request URL: $url');
      print('Request Headers: $headers');

      // Make the GET request
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        print('Response Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        return ApiResponse.fromJson(json.decode(response.body));
      } else {
        print('Error Response: ${response.body}');
        throw Exception('Failed to load document details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching document details: $e');
    }
  }
}
