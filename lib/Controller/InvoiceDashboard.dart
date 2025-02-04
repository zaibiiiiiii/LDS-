import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../Models/Documentlistbystatus.dart';

class DashboardService {
  final String baseUrl = 'https://posapi.lakhanisolution.com/api/App/GetDashboardDetails';
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Headers without the Authorization, which will be set dynamically
  final Map<String, String> headers = {};

  Future<Map<String, int>> fetchDashboardCounts({
    required String companyId,
    required DateTime periodFrom,
    required DateTime periodTo,
    String status = "00", // Default to "00" if not provided
    String docType = "00", // Default to "00" if not provided
  }) async {
    final String formattedPeriodFrom = DateFormat('dd-MM-yyyy').format(periodFrom);
    final String formattedPeriodTo = DateFormat('dd-MM-yyyy').format(periodTo);

    final Uri url = Uri.parse(
      '$baseUrl?Company_Id=$companyId&Period_From=$formattedPeriodFrom&Period_To=$formattedPeriodTo&Doc_Type=$docType&Status=$status',
    );

    try {
      // Retrieve AccessToken and Company_Id from secure storage
      final String? accessToken = await _secureStorage.read(key: 'AccessToken');
      final String? companyId = await _secureStorage.read(key: 'Company_Id');

      if (accessToken == null || companyId == null) {
        throw Exception('AccessToken or Company Id is not available in secure storage');
      }

      // Set the Authorization header with the AccessToken
      headers['Authorization'] = 'Bearer $accessToken';

      // Make the HTTP request with the dynamic Authorization header
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(json.decode(response.body));

        if (apiResponse.message == "No Data Found!") {
          // Return an empty map or any other value to indicate no data
          return {}; // No data case
        }

        if (apiResponse.status == 'OK') {
          // Initialize the counts for both Status and DocumentType
          Map<String, int> statusCounts = {
            "Pending": 0,
            "Error": 0,
            "Warning": 0,
            "Clear": 0,
          };

          Map<String, int> docTypeCounts = {
            "Invoice": 0,
            "CreditNote": 0,
            "DebitNote": 0,
            "Draft": 0,
            "Prepaid": 0,
          };

          // Loop through the result and count status and document type
          for (var documentList in apiResponse.result) {
            for (var doc in documentList) {
              // Count based on document's status
              if (statusCounts.containsKey(doc.status)) {
                statusCounts[doc.status] = (statusCounts[doc.status] ?? 0) + 1;
              }

              // Count based on document's documentType
              if (docTypeCounts.containsKey(doc.documentType)) {
                docTypeCounts[doc.documentType] = (docTypeCounts[doc.documentType] ?? 0) + 1;
              }
            }
          }

          // Combine both status and document type counts into one map
          Map<String, int> finalCounts = {
            ...statusCounts,
            ...docTypeCounts,
          };

          return finalCounts;
        } else {
          throw Exception('Failed to load document details: ${apiResponse.message}');
        }
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching dashboard counts: $e');
    }
  }
}
