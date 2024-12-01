import 'package:flutter/material.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedItem;
  String? textFieldValue1;
  String? textFieldValue2;

  // Example list for dropdown
  List<String> items = ["Item 1", "Item 2", "Item 3"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // TextField 1
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Field 1',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) {
                  textFieldValue1 = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a value';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // TextField 2
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Field 2',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) {
                  textFieldValue2 = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a value';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Dropdown
              DropdownButtonFormField<String>(
                value: selectedItem,
                hint: const Text('Select Item'),
                onChanged: (newValue) {
                  setState(() {
                    selectedItem = newValue;
                  });
                },
                onSaved: (newValue) {
                  selectedItem = newValue;
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select an item';
                  }
                  return null;
                },
                items: items.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    // Process data (e.g., send to API or save to local storage)
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'Form submitted: $textFieldValue1, $textFieldValue2, $selectedItem')));
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
