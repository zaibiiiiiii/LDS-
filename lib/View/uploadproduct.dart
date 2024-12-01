import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UploadProductScreen extends StatefulWidget {
  const UploadProductScreen({super.key});

  @override
  _UploadProductScreenState createState() => _UploadProductScreenState();
}

class _UploadProductScreenState extends State<UploadProductScreen> {
  String? selectedFileName; // To display the selected file name

  Future<void> _pickFile() async {
    // Allow only Excel files to be selected
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx'], // Excel file extensions
    );

    if (result != null) {
      setState(() {
        selectedFileName = result.files.single.name; // Get the file name
      });
    } else {
      // User canceled the picker
      setState(() {
        selectedFileName = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Product'),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // Header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Upload Product',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // File Upload Box
          Expanded(
            child: Center(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      selectedFileName ?? 'Drop Excel file to upload',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _pickFile, // Open file picker
                      child: const Text('CHOOSE FILE'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Download Excel Format Functionality
                  },
                  child: const Text('DOWNLOAD EXCEL FORMAT'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedFileName != null) {
                      // Proceed with import functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Importing $selectedFileName...'),
                        ),
                      );
                    } else {
                      // Notify user to select a file first
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a file first!'),
                        ),
                      );
                    }
                  },
                  child: const Text('IMPORT'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
