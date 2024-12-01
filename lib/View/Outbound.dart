  import 'dart:convert';
  import 'dart:io';
  import 'dart:typed_data';
  import 'package:flutter/material.dart';
  import 'package:qr_flutter/qr_flutter.dart';
  import 'package:path_provider/path_provider.dart';
  import 'package:flutter_pdfview/flutter_pdfview.dart';
  import 'package:http/http.dart' as http;
  import 'package:permission_handler/permission_handler.dart';
  import 'package:share_plus/share_plus.dart';
  import '../Models/document_model.dart';


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


    @override
    void initState() {
      super.initState();

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

      final String apiUrl = 'https://cosco.phase2.uat.edsgcc.com/api/app_documentAttachment/1/$documentId';

      try {
        final response = await http.get(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'apikeysyncdemo ECBFFE2D-8E76-4335-97FA-8502381B6EBF',
            'COMPANY_SECRATE_KEY': '0273239B-C005-4DE3-8138-A4B8A4068A5B',
          },
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          setState(() {
            document = Document.fromJson(jsonDecode(response.body));
          });
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

    // Function to open the saved PDF file in a PDF viewer
    Future<void> openPDF(String filePath, BuildContext context) async {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerPage(pdfPath: filePath),
        ),
      );
    }



    // Function to download XML file from URL
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


    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: const Text('Document Details'),
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
              'Enter Document ID',
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
                  label: const Text('Fetch Document'),
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
                      const SizedBox(height: 20),
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'Document ID: ${document?.documentIdNumber ??
                                    'Unknown'}',
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
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: (document?.invoiceXml.isNotEmpty ?? false)
                            ? ElevatedButton.icon(
                          onPressed: () {
                            downloadXML(document?.invoiceXml ?? '', context);
                          },
                          icon: const Icon(Icons.file_download),
                          label: const Text('Download XML File'),

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
                              label: const Text('View PDF'),

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
                              label: const Text('Download PDF'),

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

  class PDFViewerPage extends StatelessWidget {
    final String? pdfPath;

    const PDFViewerPage({super.key, this.pdfPath});

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: const Text("PDF Viewer")),
        body: pdfPath != null
            ? Column(
          children: [
            // Display the PDF
            Expanded(child: PDFView(filePath: pdfPath)),

            // Share button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (pdfPath != null && pdfPath!.isNotEmpty) {
                    // Share the PDF file using XFile
                    final pdfFile = File(pdfPath!);
                    await Share.shareXFiles(
                      [XFile(pdfFile.path)],  // Pass the file path wrapped in XFile
                      text: 'Check out this document!',
                    );
                  } else {
                    print('No PDF available to share.');
                  }
                },
                icon: const Icon(
                  Icons.share,
                  color: Colors.white, // Icon color
                  size: 24, // Icon size
                ),
                label: const Text(
                  'Share PDF',
                  style: TextStyle(
                    fontSize: 16, // Increase font size
                    fontWeight: FontWeight.bold, // Make text bold
                    color: Colors.white, // Text color
                  ),
                ),

              ),

            ),
          ],
        )
            : const Center(child: Text('No PDF available')),
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
