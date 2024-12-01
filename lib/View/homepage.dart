// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// class AddInvoiceWizard extends StatefulWidget {
//   @override
//   _AddInvoiceWizardState createState() => _AddInvoiceWizardState();
// }
//
// class _AddInvoiceWizardState extends State<AddInvoiceWizard> {
//   int currentStep = 0;
//   List<ProductGroup> productGroups = [ProductGroup()];
//
//   // Controllers for other form fields
//   TextEditingController branchController = TextEditingController();
//   TextEditingController docTypeController = TextEditingController();
//   TextEditingController subtypeController = TextEditingController();
//   TextEditingController customerNameController = TextEditingController();
//   TextEditingController baseCurrencyController = TextEditingController();
//   TextEditingController exchangeRateController = TextEditingController();
//   TextEditingController deliveryDateController = TextEditingController();
//   TextEditingController paymentMethodController = TextEditingController();
//   TextEditingController taxCategoryController = TextEditingController();
//   TextEditingController taxExemptionReasonCodeController = TextEditingController();
//   TextEditingController taxExemptionReasonController = TextEditingController();
//   TextEditingController totalAmountController = TextEditingController();
//   TextEditingController totalAmountSarController = TextEditingController();
//   TextEditingController transactionTypeController = TextEditingController();
//   TextEditingController invoiceIndicatorController = TextEditingController();
//   TextEditingController docNoController = TextEditingController();
//
//   void _addGroup() {
//     setState(() {
//       productGroups.add(ProductGroup());
//     });
//   }
//
//   void _removeGroup(int index) {
//     setState(() {
//       productGroups.removeAt(index);
//     });
//   }
//
//   Future<void> _submitForm() async {
//     // Collecting all form data into a map to send to API
//     Map<String, dynamic> formData = {
//       'Document': [
//         {
//           'COMPANY_BRANCH': branchController.text,
//           'DOCUMENT_TYPE': docTypeController.text,
//           'INVOICE_SUB_TYPE_DESC': subtypeController.text,
//           'CUSTOMER_NAME': customerNameController.text,
//           'DELIVERY_DATE': deliveryDateController.text,
//           'CURRENCY': baseCurrencyController.text,
//           'EXCHANGE': double.tryParse(exchangeRateController.text) ?? 1, // Ensure numeric value
//           'PAYMENT_TYPE': paymentMethodController.text,
//           'TAX_CATEGORY': taxCategoryController.text,
//           'TAX_EXEMPTION_REASON_CODE': taxExemptionReasonCodeController.text,
//           'TAX_EXEMPTION_REASON': taxExemptionReasonController.text,
//           'DOCUMENT_ID_NUMBER': docNoController.text,
//           'productGroups': productGroups.map((group) {
//             return {
//               'PRODUCT_NAME': group.productController.text,
//               'PRODUCT_PRICE': double.tryParse(group.priceController.text) ?? 0, // Ensure numeric value
//               'PRODUCT_QUANTITY': int.tryParse(group.quantityController.text) ?? 1, // Ensure integer value
//               'PRODUCT_DISCOUNT': double.tryParse(group.discountController.text) ?? 0, // Ensure numeric value
//               'TOTAL_AMOUNT': double.tryParse(group.totalAmountController.text) ?? 0, // Ensure numeric value
//               'TAX_RATE': double.tryParse(group.taxRateController.text) ?? 0, // Ensure numeric value
//               'TAX_AMOUNT': double.tryParse(group.taxAmountController.text) ?? 0, // Ensure numeric value
//               'GROSS_AMOUNT': double.tryParse(group.grossAmountController.text) ?? 0, // Ensure numeric value
//             };
//           }).toList(),
//         }
//       ]
//     };
//
//     // Convert the form data to JSON
//     String jsonData = json.encode(formData);
//
//     try {
//       // API POST request to send the data
//       final response = await http.post(
//         Uri.parse('https://cosco.phase2.uat.edsgcc.com/api/app_Document'), // Replace with your API endpoint
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'apikeysyncdemo ECBFFE2D-8E76-4335-97FA-8502381B6EBF',
//           'COMPANY_SECRATE_KEY': '0273239B-C005-4DE3-8138-A4B8A4068A5B',
//         },
//         body: jsonData,
//       );
//
//       // Log response status and body for debugging
//       print("Response status: ${response.statusCode}");
//       print("Response body: ${response.body}");
//
//       if (response.statusCode == 200) {
//         // Successfully posted data
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invoice submitted successfully!')));
//       } else {
//         // API returned an error
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit invoice. Status: ${response.statusCode}')));
//       }
//     } catch (e) {
//       // Handle errors like network failure or other issues
//       print("Error: $e");
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error submitting invoice: $e')));
//     }
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add Invoice', style: TextStyle(fontWeight: FontWeight.bold)),
//         backgroundColor: Colors.blue[900],
//         centerTitle: true,
//         foregroundColor: Colors.white,
//       ),
//       body: Stepper(
//         type: StepperType.horizontal,
//         currentStep: currentStep,
//         onStepContinue: () {
//           if (currentStep < 1) setState(() => currentStep += 1);
//         },
//         onStepCancel: () {
//           if (currentStep > 0) setState(() => currentStep -= 1);
//         },
//         steps: [
//           Step(
//             title: _buildStepTitle('Step 1', currentStep == 0),
//             isActive: currentStep == 0,
//             content: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
//               child: Column(
//                 children: [
//                   _buildTextField("Branch", controller: branchController),
//                   SizedBox(height: 16),
//                   _buildTextField("Document Type", controller: docTypeController),
//                   SizedBox(height: 16),
//                   _buildTextField("SubType", controller: subtypeController),
//                   SizedBox(height: 16),
//                   _buildTextField("Customer Name", controller: customerNameController),
//                   SizedBox(height: 16),
//                   _buildTextField("Base Currency", controller: baseCurrencyController),
//                   SizedBox(height: 16),
//                   _buildTextField("Exchange Rate", controller: exchangeRateController,),
//                   SizedBox(height: 16),
//                   _buildTextField("Delivery Date", controller: deliveryDateController),
//                   SizedBox(height: 16),
//                   _buildTextField("Payment Method", controller: paymentMethodController),
//                   SizedBox(height: 16),
//                   _buildTextField("Tax Category", controller: taxCategoryController),
//                   SizedBox(height: 16),
//                   _buildTextField("Tax Exemption Reason Code", controller: taxExemptionReasonCodeController),
//                   SizedBox(height: 16),
//                   _buildTextField("Tax Exemption Reason", controller: taxExemptionReasonController),
//                   SizedBox(height: 16),
//                   _buildTextField("Total Amount", controller: totalAmountController),
//                   SizedBox(height: 16),
//                   _buildTextField("Total Amount SAR", controller: totalAmountSarController),
//                   SizedBox(height: 16),
//                   _buildTextField("Transaction Type", controller: transactionTypeController),
//                   SizedBox(height: 16),
//                   _buildTextField("Invoice Indicator", controller: invoiceIndicatorController),
//                   SizedBox(height: 16),
//                   _buildTextField("Doc No", controller: docNoController),
//                 ],
//               ),
//             ),
//           ),
//           Step(
//             title: _buildStepTitle('Step 2', currentStep == 1),
//             isActive: currentStep == 1,
//             content: SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
//                 child: Column(
//                   children: [
//                     ...List.generate(productGroups.length, (index) {
//                       return Column(
//                         children: [
//                           _buildProductGroup(index),
//                           if (index < productGroups.length - 1)
//                             Divider(thickness: 1, color: Colors.grey.shade300),
//                         ],
//                       );
//                     }),
//                     SizedBox(height: 20),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         _buildActionButton('Add Group', Colors.blue[900]!, _addGroup),
//                         _buildActionButton('Remove Group', Colors.red[900]!,
//                             productGroups.length > 1 ? () => _removeGroup(productGroups.length - 1) : null),
//                       ],
//                     ),
//                     SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: _submitForm,
//                       child: Text('Submit'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green[700]!,
//                         padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStepTitle(String title, bool isActive) {
//     return Text(
//       title,
//       style: TextStyle(
//         fontWeight: FontWeight.bold,
//         fontSize: 18,
//         color: isActive ? Colors.blue[800] : Colors.grey,
//       ),
//     );
//   }
//
//   Widget _buildProductGroup(int index) {
//     final group = productGroups[index];
//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           children: [
//             _buildTextField("Product", controller: group.productController),
//             SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(child: _buildTextField("Price", controller: group.priceController)),
//                 SizedBox(width: 16),
//                 Expanded(child: _buildTextField("Quantity", controller: group.quantityController)),
//               ],
//             ),
//             SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(child: _buildTextField("Discount", controller: group.discountController)),
//                 SizedBox(width: 16),
//                 Expanded(child: _buildTextField("Total Amount", controller: group.totalAmountController)),
//               ],
//             ),
//             SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(child: _buildTextField("Tax Rate %", controller: group.taxRateController)),
//                 SizedBox(width: 16),
//                 Expanded(child: _buildTextField("Tax Amount", controller: group.taxAmountController)),
//               ],
//             ),
//             SizedBox(height: 12),
//             _buildTextField("Gross Amount", controller: group.grossAmountController),
//             SizedBox(height: 12),
//             _buildTextField("Tax Category", controller: group.taxCategoryController),
//             SizedBox(height: 12),
//             _buildTextField("Tax Exemption Code", controller: group.taxExemptionCodeController),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField(String label, {TextEditingController? controller, String? initialValue}) {
//     return TextFormField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(color: Colors.blue[700]),
//         focusedBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: Colors.blue[700]!),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: Colors.grey.shade300),
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//       initialValue: initialValue,
//     );
//   }
//
//   Widget _buildActionButton(String text, Color color, VoidCallback? onPressed) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       child: Text(text),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color,
//         padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//     );
//   }
// }
//
// class ProductGroup {
//   TextEditingController productController = TextEditingController();
//   TextEditingController priceController = TextEditingController();
//   TextEditingController quantityController = TextEditingController();
//   TextEditingController discountController = TextEditingController();
//   TextEditingController totalAmountController = TextEditingController();
//   TextEditingController taxRateController = TextEditingController();
//   TextEditingController taxAmountController = TextEditingController();
//   TextEditingController grossAmountController = TextEditingController();
//   TextEditingController taxCategoryController = TextEditingController();
//   TextEditingController taxExemptionCodeController = TextEditingController();
// }
