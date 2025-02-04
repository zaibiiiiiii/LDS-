
import 'package:flutter/material.dart';
import '../Controller/Documentlistbystatus.dart';
import '../Models/Documentlistbystatus.dart';
import '../l10n/app_localizations.dart';

class FilteredTableScreen extends StatefulWidget {
  final String companyId;
  final DateTime periodFrom;
  final DateTime periodTo;
  final String docType;
  final String status;

  const FilteredTableScreen({
    super.key,
    required this.companyId,
    required this.periodFrom,
    required this.periodTo,
    required this.docType,
    required this.status,
  });

  @override
  State<FilteredTableScreen> createState() => _FilteredTableScreenState();
}

class _FilteredTableScreenState extends State<FilteredTableScreen> {
  late Future<List<Document>> documents;
  final DashboardDetailsService _service = DashboardDetailsService();
  String appBarTitle = "Documents";

  @override
  void initState() {
    super.initState();
    _updateAppBarTitle();

    documents = _fetchDocuments();
  }
  void _updateAppBarTitle() {
    String title = "Documents";
    if (widget.docType != '00') {
      title += " - ${widget.docType}";
    }
    if (widget.status != '00') {
      title += " - ${widget.status}";
    }
    setState(() {
      appBarTitle = title;
    });
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'clear':
        return  Colors.green;
      case 'pending':
        return const Color(0xFF0F6ECB);
      case 'error':
        return const Color(0XFFCA1E1A);
      case 'warning':
        return const Color(0xFFFF6700);
      default:
        return Colors.grey;
    }
  }
  Color getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'invoice':
        return const  Color(0xFF9B37AC);
      case 'creditnote':
        return const Color(0xFF643DA8);
      case 'prepaid':
        return const Color(0XFF298CDC);
      case 'debitnote':
        return const Color(0XFF4251A6);
      case 'draft':
        return const Color(0XFF12AABE);
      default:
        return Colors.black;
    }
  }

  // Fetch documents from the API and return a list of documents
  Future<List<Document>> _fetchDocuments() async {
    try {
      final response = await _service.fetchDocumentDetails(
        periodFrom: widget.periodFrom,
        periodTo: widget.periodTo,
        docType: widget.docType,
        status: widget.status,
      );

      if (response.status == 'OK') {
        if (response.result.isNotEmpty) {
          // Flatten the nested lists and directly add Documents to the list
          List<Document> documents = response.result
              .expand((list) => list)  // Flatten the nested list of lists
              .toList();               // Convert the flattened list to a List<Document>
          return documents;
        } else {
          return [];
        }
      } else {
        throw Exception('No Documents Found: ${response.message}');
      }
    } catch (e) {
      print('Error fetching document details: $e');
      throw Exception('No Documents Available');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        title: Text(appBarTitle), // Use dynamic title
      ),
      body: FutureBuilder<List<Document>>(
        future: documents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading indicator while the data is loading
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Show error message if the request fails
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Show message if no documents are found
            return const Center(child: Text('No documents found.'));
          } else {
            List<Document> filteredDocuments = snapshot.data!;

            // Display the data in a DataTable
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns:  [
                  DataColumn(label: Text('Doc#')),
                  DataColumn(label: Text(
                      AppLocalizations.of(context, 'Customer Name'),
                  )),
                  DataColumn(label: Text(
                    AppLocalizations.of(context, 'Branch'),
                  )),
                  DataColumn(label: Text(
                    AppLocalizations.of(context, 'Total Amount'),
                  )),
                  DataColumn(label: Text(
                    AppLocalizations.of(context, 'Issue Date'),
                  )),
                  DataColumn(label: Text(
                      AppLocalizations.of(context, 'Tax Inclusive Amount'),

                  )),
                  DataColumn(label: Text(
                      AppLocalizations.of(context,  'Document Type'),

                  )),
                  DataColumn(label: Text(
                    AppLocalizations.of(context,  'Status'),
                  )),
                  DataColumn(label: Text(
                    AppLocalizations.of(context,  'Status Message'),
                  )), // New column for Status Message
                ],
                rows: filteredDocuments.map((doc) {
                  Color statusColor = getStatusColor(doc.status);
                  Color typeColor = getTypeColor(doc.documentType);
                  return DataRow(cells: [
                    DataCell(Text(doc.documentNo)),
                    DataCell(Text(doc.customerName ?? 'NA')), // Fallback if customerName is null
                    DataCell(Text(doc.branch)),
                    DataCell(Text(doc.totalAmount.toStringAsFixed(2))),
                    DataCell(Text(doc.issueDate)),
                    DataCell(Text(doc.taxInclusiveAmount.toStringAsFixed(2))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: typeColor, // Use typeColor
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          doc.documentType,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: statusColor, // Use statusColor
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          doc.status,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),                    DataCell(Text(doc.statusMessage != null ? doc.statusMessage! : 'No Status Message')),
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
