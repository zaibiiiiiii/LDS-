import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';

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
                color: Colors.white,
                size: 24,
              ),
              label: const Text(
                'Share PDF',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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