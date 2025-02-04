  import 'dart:convert';
  import 'dart:io';
  import 'dart:typed_data';
import 'dart:ui';
  import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lds/View/ViewPdf.dart';
  import 'package:path_provider/path_provider.dart';
  import 'package:flutter_pdfview/flutter_pdfview.dart';
  import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
  import 'package:permission_handler/permission_handler.dart';
  import 'package:share_plus/share_plus.dart';
  import '../Models/document_model.dart';
  import 'package:qr_flutter/qr_flutter.dart';
  import 'package:pdf/widgets.dart' as pw;

import '../l10n/app_localizations.dart';
  class DocumentPage extends StatefulWidget {
  const DocumentPage({super.key});

    @override
    _DocumentPageState createState() => _DocumentPageState();
  }

  class _DocumentPageState extends State<DocumentPage> {
    Document? document;
    String documentId = '';
    bool isPermissionDenied = false;
    bool isLoading = false;
    String decodedQRCodeContent = ''; // This will store the decoded QR code content
    @override
    void initState() {
      super.initState();

    }
    void decodeQRCode() {
      if (document?.qrCode.isNotEmpty ?? false) {
        try {
          // Debug: Check the qrCode before decoding
          print('QR Code (Base64): ${document!.qrCode}');

          // Decode base64 to raw bytes
          Uint8List decodedBytes = base64Decode(document!.qrCode);

          // Try to decode it as a string (UTF-8)
          String decodedString = utf8.decode(decodedBytes, allowMalformed: true);

          // Check if decodedString looks like a JSON
          if (isJson(decodedString)) {
            // Try parsing JSON if the decoded string is JSON-like
            var decodedJson = jsonDecode(decodedString);

            setState(() {
              decodedQRCodeContent = _formatJson(decodedJson); // Formatting it for display
            });
          } else {
            // If not JSON, format the plain text
            setState(() {
              decodedQRCodeContent = formatDecodedData(decodedString);
            });
          }

          // Debug: Print the decoded content
          print('Decoded QR Code Content: $decodedQRCodeContent');
        } catch (e) {
          print('Error decoding QR code: $e');
          setState(() {
            decodedQRCodeContent = 'Failed to decode QR code.';
          });
        }
      } else {
        setState(() {
          decodedQRCodeContent = 'QR Code data is empty.';
        });
      }
    }

// Function to check if the string is a valid JSON format
    bool isJson(String str) {
      try {
        jsonDecode(str);
        return true;
      } catch (e) {
        return false;
      }
    }

// Function to format the JSON in a more readable manner
    String _formatJson(dynamic json) {
      var jsonPretty = JsonEncoder.withIndent('  ').convert(json);
      return jsonPretty;
    }

// Function to format plain text for better readability
    String formatDecodedData(String rawData) {
      // Debugging: Print the raw data for analysis
      print("Raw Data: $rawData");

      // Step 1: Clean up the raw data by replacing non-printable characters.
      String cleanedData = rawData.replaceAll(RegExp(r'[^\x20-\x7E]'), '\n').trim();

      // Debugging: Print the cleaned data
      print("Cleaned Data: $cleanedData");

      // Step 2: Extract the seller name (first line of text or first non-numeric string).
      final sellerNameMatch = RegExp(r"^[^0-9\n]+").firstMatch(cleanedData);
      String sellerName = sellerNameMatch != null ? sellerNameMatch.group(0)!.trim() : "Seller Name not found";

      // Step 3: Extract the seller TRN (15-digit number).
      final trnMatch = RegExp(r"\b\d{15}\b").firstMatch(cleanedData);
      String sellerTRN = trnMatch != null ? trnMatch.group(0)!.trim() : "TRN not found";

      // Step 4: Extract the invoice date/time (ISO format: YYYY-MM-DDTHH:MM:SS).
      final dateMatch = RegExp(r"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}").firstMatch(cleanedData);
      String invoiceDateTime = dateMatch != null
          ? _formatDateTime(dateMatch.group(0)!)
          : "Invoice Date/Time not found";

      // Step 5: Extract invoice total and VAT total (floating-point numbers).
      final amounts = RegExp(r"\b\d+\.\d{2}\b").allMatches(cleanedData).toList();
      String invoiceTotal = amounts.isNotEmpty ? "\SAR ${amounts[0].group(0)}" : "Invoice Total not found";
      String vatTotal = amounts.length > 1 ? "\SAR ${amounts[1].group(0)}" : "VAT Total not found";

      // Step 6: Format the output for display.
      return """
Seller Name: $sellerName

Seller TRN: $sellerTRN

Invoice Date: $invoiceDateTime

Invoice Total: $invoiceTotal

VAT Total: $vatTotal

""".trim();
    }
    String _extractValue(String content, String label) {
      RegExp regex = RegExp("$label\\s*(.+?)\\n"); // Matches the label and captures the value until the next newline
      Match? match = regex.firstMatch(content);
      return match?.group(1)?.trim() ?? ""; // Returns the captured value or an empty string if not found.
    }
// Helper function to format date and time.
    String _formatDateTime(String dateTime) {
      DateTime parsedDate = DateTime.parse(dateTime);
      return "${parsedDate.day} ${_monthName(parsedDate.month)} ${parsedDate.year}, ${parsedDate.hour}:${parsedDate.minute.toString().padLeft(2, '0')}:${parsedDate.second.toString().padLeft(2, '0')}";
    }

// Helper function to get month names.
    String _monthName(int month) {
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return months[month - 1];
    }
    Future<File?> generatePDF(String invoiceDetails) async { // Return the File?
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Text(invoiceDetails),
            );
          },
        ),
      );

      try {
        final pdfBytes = await pdf.save(); // Use pdf package's save method


        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/invoice.pdf');
        await file.writeAsBytes(pdfBytes as List<int>);
        return file; // Return the File object
      } catch (e) {
        print('Error generating PDF: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF')),
        );
        return null; // Return null if there's an error
      }
    }

    void sharePDF(File file) async {
      try {
        await Share.shareXFiles([XFile(file.path)], text: 'Invoice Details'); // Specify mimeType
      } catch (e) {
        print('Error sharing PDF: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing PDF')),
        );
      }
    }

    void DownloadPDF(File file) async {
      try {
        final directory = Directory('/storage/emulated/0/Download'); // Downloads folder
        String filePath = '${directory.path}/invoice.pdf';
        final newFile = await file.copy(filePath); // Copy to Downloads

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF downloaded to Downloads')),
        );
      } catch (e) {
        print('Error downloading PDF: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading PDF')),
        );
      }
    }

    Future<void> fetchDocumentDetails() async {
        if (documentId.isEmpty) {
          // Show a snackbar if the Document ID field is empty
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please fill in the Document ID field'),
              backgroundColor: Colors.red,
            ),
          );
          return;  // Prevent API call if the Document ID is empty
        }      setState(() {
        isLoading = true;
      });

      final String apiUrl = 'https://cosco.phase2.uat.edsgcc.com/api/app_documentAttachment/1164/$documentId';

      try {
        final response = await http.get(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'apikeysyncdemo 308A1AA3-0D45-4646-A74F-F51748D1D019',
            'COMPANY_SECRATE_KEY': 'AE1872F3-6EAD-4BDF-9C78-1747871C11AA',
          },
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          setState(() {
            document = Document.fromJson(jsonDecode(response.body));
          });
          decodeQRCode();
        } else {
          print('Failed to load document details. Status code: ${response
              .statusCode}');
        }
      } catch (e) {
        print('Error fetching document details: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
      Future<String> convertBase64ToFile(String base64String,
        String filename) async {
      try {
        Uint8List bytes = base64Decode(base64String);

        // Request permission to access external storage on Android
        if (isPermissionDenied) {
          throw Exception("Storage permission denied");
        }

        final directory = await getExternalStorageDirectory();
        final file = File('${directory?.path}/$filename');
        await file.writeAsBytes(bytes);
        return file.path;
      } catch (e) {
        print('Error saving PDF file: $e');
        throw Exception('Failed to save PDF file.');
      }
    }
    Future<void> openPDF(String filePath, BuildContext context) async {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerPage(pdfPath: filePath),
        ),
      );
    }
    Future<void> requestStoragePermission() async {
      if (Platform.isAndroid) {
        if (await Permission.storage.request().isGranted) {
          return;
        } else if (Platform.isAndroid && await Permission.manageExternalStorage.request().isGranted) {
          return;
        } else {
          openAppSettings();
        }
      }
    }
    Future<void> downloadXML(String xmlContent, BuildContext context) async {
      try {
        if (xmlContent.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid or empty XML content'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Request storage permissions
        await requestStoragePermission();

        // Check if permission is granted before proceeding
        if (await Permission.storage.isGranted || await Permission.manageExternalStorage.isGranted) {
          final directory = Directory('/storage/emulated/0/Download');
          String filePath = '${directory.path}/invoice.xml';

          final file = File(filePath);
          await file.writeAsString(xmlContent);

          print('File saved to: $filePath');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('XML file downloaded successfully to Downloads'),
              backgroundColor: Colors.green,
            ),
          );

          // Show download notification
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Storage permission denied'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print('Error occurred: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred while downloading the file'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    // Add this function to download the PDF to the Downloads folder
    Future<void> downloadPDF(String base64String, BuildContext context) async {
      try {
        // Decode the Base64 string
        Uint8List pdfBytes = base64Decode(base64String);

        // Request storage permissions if not granted
        await requestStoragePermission();

        if (await Permission.storage.isGranted || await Permission.manageExternalStorage.isGranted) {
          final directory = Directory('/storage/emulated/0/Download'); // Downloads folder
          String filePath = '${directory.path}/document.pdf'; // File path with filename

          final file = File(filePath);
          await file.writeAsBytes(pdfBytes);

          print('PDF file saved to: $filePath');

          // Show a snackbar to indicate successful download
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF downloaded successfully to Downloads folder'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Storage permission denied'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print('Error downloading PDF: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to download PDF'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    Future<void> oPpenPDF(String filePath, BuildContext context) async {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerPage(pdfPath: filePath),
        ),
      );
    }
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title:  Text(
          AppLocalizations.of(context, 'Document Details'),
        ),
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue[900],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  AppLocalizations.of(context, 'Enter Document ID'),
                  onChanged: (value) {
                    setState(() {
                      documentId = value;  // Update the documentId when the text changes
                    });
                  },
                ),

                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: fetchDocumentDetails,
                  icon: const Icon(Icons.download),
                  label:  Text(
                    AppLocalizations.of(context, 'Fetch Document'),
                  ),
                ),
                const SizedBox(height: 20),
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  if (document == null)
                    const Center(child: Text('No Document Available'))
                  else
                    ...[
                      if (document?.qrCode.isNotEmpty ?? false)
                        Center(
                          child: QrImageView(
                            data: document?.qrCode ?? '',
                            size: 200.0,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      if (decodedQRCodeContent.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context, 'Decoded QR Code Content'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,

                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16),
                              child: SelectableText(
                                decodedQRCodeContent,
                                style: const TextStyle(
                                  fontFamily: 'Courier', // Monospaced font for code
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (decodedQRCodeContent.isNotEmpty)
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final pdfFile = await generatePDF(decodedQRCodeContent);
                              if (pdfFile != null) {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                      child: Wrap(
                                        children: <Widget>[
                                          ListTile(
                                            leading: Icon(Icons.share),
                                            title: Text(
                                              AppLocalizations.of(context, 'Share'),
                                            ),
                                            onTap: () {
                                              sharePDF(pdfFile);
                                              Navigator.pop(context);
                                            },
                                          ),
                                          ListTile(
                                            leading: Icon(Icons.download),
                                            title: Text(
                                              AppLocalizations.of(context, 'Download'),
                                            ),
                                            onTap: () {
                                              DownloadPDF(pdfFile);
                                              Navigator.pop(context);
                                            },
                                          ),
                                          ListTile(
                                            leading: Icon(Icons.remove_red_eye),
                                            title: Text(
                                              AppLocalizations.of(context, 'View File'),
                                            ),
                                            onTap: () {
                                              openPDF(pdfFile!.path, context);
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                            icon: const Icon(Icons.save),
                            label:  Text(  AppLocalizations.of(context, 'Download'),
                            ),

                          ),
                        ),
                      const SizedBox(height: 20),
                     Center(child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
      AppLocalizations.of(context, 'Document ID: ${document?.documentIdNumber ??
                                    'Unknown'}',),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Request Status: ${document?.requestStatus ?? ''}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),),
                      const SizedBox(height: 20),
                      Center(
                        child: (document?.invoiceXml.isNotEmpty ?? false)
                            ? ElevatedButton.icon(
                          onPressed: () {
                            downloadXML(document?.invoiceXml ?? '', context);
                          },
                          icon: const Icon(Icons.file_download),
                          label:  Text(    AppLocalizations.of(context, 'Download XML File'),
                          ),

                        )
                            : const Text('No XML content available'),
                      ),
                      const SizedBox(height: 30),
                      if (document?.fileUpload?.isNotEmpty ?? false) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // View PDF Button
                            ElevatedButton.icon(
                              onPressed: () async {
                                String base64String = document?.fileUpload ?? '';
                                if (base64String.isNotEmpty) {
                                  String filePath = await convertBase64ToFile(base64String, 'document.pdf');
                                  openPDF(filePath, context);
                                } else {
                                  print('No PDF available to view.');
                                }
                              },
                              icon: const Icon(Icons.picture_as_pdf),
                              label:  Text( AppLocalizations.of(context, 'View PDF'),),

                            ),
                            const SizedBox(width: 20), // Add some spacing between buttons
                            ElevatedButton.icon(
                              onPressed: () async {
                                String base64String = document?.fileUpload ?? '';
                                if (base64String.isNotEmpty) {
                                  await downloadPDF(base64String, context);
                                } else {
                                  print('No PDF available to download.');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('No PDF available to download'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.download_rounded),
                              label:  Text( AppLocalizations.of(context, 'Download PDF'),),

                            ),

                          ],
                        ),
                        const SizedBox(height: 10),
                      ] else
                        ...[
                          const Center(child: Text('No PDF available for download or view.')),
                        ],

                    ],
              ],
            ),
          ),
        ),
      );
    }
  }

  String documentId = ''; // This will store the documentId value

  Widget _buildTextField(
      String label, {
        TextEditingController? controller,
        String? initialValue,
        ValueChanged<String>? onChanged, // onChanged callback
      }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.blue[700]),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue[700]!),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(
          Icons.search, // The search icon
          color: Colors.blue[700],
        ),
      ),
      initialValue: initialValue,
      onChanged: onChanged, // Using the onChanged callback
    );
  }