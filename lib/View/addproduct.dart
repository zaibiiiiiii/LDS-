import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AddProductScreen extends StatelessWidget {
  final TextEditingController companyController = TextEditingController();
  final TextEditingController productCodeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController arabicNameController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController vatRateController = TextEditingController();

  AddProductScreen({super.key});


  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);  // Ensures URL is parsed correctly

    // Check if the URL can be launched
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);  // Use LaunchMode to launch in an external app
    } else {
      print('Error: Could not launch $url');
      throw 'Could not launch $url';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // Show help message or dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Help ?\nInvoice Creation'),
                    content: const Text(
                        'To add your data of your products manually, click on the sub tab “add products” in the third dropdown. Fill up the empty slots with the essential information of the products and click on the save button. It will add the data of your product in the directory'),
                    actions: [
                      GestureDetector(
                        onTap: () {
                          _launchURL('http://www.youtube.com/watch?v=TyVyLrFHj_0&t=1s');

                        },
                        child: Column(
                          children: [
                            Image.network(
                              'https://img.youtube.com/vi/TyVyLrFHj_0/0.jpg',
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ?? 1)
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.error),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Watch Tutorial: How to Upload Products',
                              style: TextStyle(fontSize: 16, color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Company',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Bureida Trading and Refrigeration Company',
                    child: Text('Bureida Trading and Refrigeration Company'),
                  ),
                  // Add more items if necessary
                ],
                onChanged: (value) {},
              ),
              const SizedBox(height: 16.0),
              buildTextField('Product Code', productCodeController),
              buildTextField('Name', nameController),
              buildTextField('Arabic Name', arabicNameController),
              buildTextField('Unit', unitController),
              buildTextField('Price', priceController),
              buildTextField('VAT Rate', vatRateController),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Save product logic
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,  // Label text
          labelStyle: TextStyle(
            color: Colors.blue[700],  // Label color
            fontWeight: FontWeight.bold,  // Bold label text
          ),
          hintStyle: TextStyle(color: Colors.grey[500]),  // Hint text style
          filled: true,  // Background color
          fillColor: Colors.grey.shade100,  // Light grey background for the text field
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue[700]!, width: 2),  // Blue color on focus with thicker border
            borderRadius: BorderRadius.circular(12),  // Rounded corners
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),  // Lighter border for enabled state
            borderRadius: BorderRadius.circular(12),  // Rounded corners
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 1.5),  // Error border color
            borderRadius: BorderRadius.circular(12),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 2),  // Thicker error border
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

