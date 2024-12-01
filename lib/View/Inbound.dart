import 'package:flutter/material.dart';
import '../Controller/post_document.dart';
import '../Models/post_document.dart';

class DocumentsPage extends StatefulWidget {
  final postdocument? documentData;

  // Constructor to accept document data
  const DocumentsPage({super.key, this.documentData});

  @override
  _DocumentsPageState createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  late postdocument documentData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // If data was passed via constructor, use it directly
    if (widget.documentData != null) {
      documentData = widget.documentData!;
      isLoading = false;
    } else {
      fetchDocumentData(); // Fetch document data if not passed
    }
  }

  // Fetch document data from the service
  Future<void> fetchDocumentData() async {
    final data = await sendDocumentRequest();
    setState(() {
      documentData = data!;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Information'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : documentData != null
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Document ID Number:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),  // Make this heading bold
            ),
            Text('${documentData.documentIDNumber}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),

            const Text(
              'Status Code:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),  // Make this heading bold
            ),
            Text('${documentData.statusCode}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),

            const Text(
              'Status Message:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),  // Make this heading bold
            ),
            Text('${documentData.statusMessage}', style: const TextStyle(fontSize: 18)),
          ],

        ),
      )
          : const Center(child: Text('No document data available')),
    );
  }
}
