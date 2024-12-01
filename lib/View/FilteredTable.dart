import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:lds/API_Configuration/api.dart';
import 'package:lds/Models/Documentlistbystatus.dart';

class FilteredTableScreen extends StatefulWidget {
  final String filterType; // "status" or "type"
  final String filterValue; // The value of the filter (e.g., 'Pending', 'Invoice')

  const FilteredTableScreen({super.key, required this.filterType, required this.filterValue});

  @override
  _FilteredTableScreenState createState() => _FilteredTableScreenState();
}

class _FilteredTableScreenState extends State<FilteredTableScreen> {
  late Future<List<Document>> documents;

  @override
  void initState() {
    super.initState();
    documents = _fetchDocuments(); // Fetch all documents and filter them locally
  }

  Future<List<Document>> _fetchDocuments() async {
    try {
      // API endpoint without any filters in the URL
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}DocumentsListByStatus'));  // Fetch all documents
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        // Decode the response
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        DocumentList documentList = DocumentList.fromJson(jsonResponse);

        // Filter documents based on the selected filter type and value
        List<Document> filteredDocuments = documentList.documents.where((doc) {
          // Filter by status or document type
          if (widget.filterType == 'status') {
            return doc.status == widget.filterValue;
          } else if (widget.filterType == 'type') {
            return doc.documentType == widget.filterValue;
          } else {
            return false;
          }
        }).toList();

        return filteredDocuments;
      } else {
        print("Error: ${response.statusCode}");
        return []; // Return an empty list on error
      }
    } catch (e) {
      print("Error during fetch: $e");
      return []; // Return an empty list on exception
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'clear':
        return Colors.green;  // Green color for approved status
      case 'pending':
        return Colors.blue;  // Blue color for pending status
      case 'error':
        return Colors.red;  // Red color for error status
      case 'warning':
        return Colors.orange;  // Orange color for warning status
      default:
        return Colors.grey;  // Default gray color for unknown status
    }
  }
  Color getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'invoice':
        return Colors.purple;  // Purple color for Invoice
      case 'creditnote':
        return Colors.yellow;  // Yellow color for Credit Note
      case 'prepaid':
        return Colors.blue;  // Blue color for Prepaid
      case 'debitnote':
        return Colors.orange;  // Orange color for Debit Note
      case 'draft':
        return Colors.grey;  // Grey color for Draft
      default:
        return Colors.black;  // Default black color for unknown types
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        title: Text('Documents - ${widget.filterValue}'), // Display filter value in app bar
      ),
      body: FutureBuilder<List<Document>>(
        future: documents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No documents found.'));
          } else {
            List<Document> filteredDocuments = snapshot.data!;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Allow horizontal scrolling
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Doc#')),
                  DataColumn(label: Text('Customer Name')),
                  DataColumn(label: Text('Branch')),
                  DataColumn(label: Text('Total Amount')),
                  DataColumn(label: Text('Issue Date')),
                  DataColumn(label: Text('Tax Inclusive Amount')),
                  DataColumn(label: Text('Document Type')),
                  DataColumn(label: Text('Status')),
                ],
                rows: filteredDocuments.map((doc) {
                  Color statusColor = getStatusColor(doc.status); // Function to get color based on status
                  Color typeColor = getTypeColor(doc.documentType);

                  return DataRow(cells: [
                    DataCell(Text(doc.documentno.toString())),
                    DataCell(Text(doc.customerName)),
                    DataCell(Text(doc.documentBranch)),
                    DataCell(Text(doc.totalAmount.toString())),
                    DataCell(Text(doc.issueDate)),
                    DataCell(Text(doc.taxInclusiveAmount.toString())),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: typeColor, // Set background color based on status
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          doc.documentType,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Text color
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: statusColor, // Set background color based on status
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          doc.status,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Text color
                          ),
                        ),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }
}
