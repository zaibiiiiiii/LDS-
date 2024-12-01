import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class AddInvoiceWizard extends StatefulWidget {
  const AddInvoiceWizard({super.key});

  @override
  _AddInvoiceWizardState createState() => _AddInvoiceWizardState();
}

class _AddInvoiceWizardState extends State<AddInvoiceWizard> {
  int currentStep = 0;
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController taxRateController = TextEditingController();
  final TextEditingController deliveryDateController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController transactionTypeController = TextEditingController();
  final TextEditingController baseCurrencyController= TextEditingController();
  final TextEditingController subtypeController = TextEditingController();
  final TextEditingController exchangeRateController= TextEditingController();

  String? selectedBranch;
  String? selectedTaxCategory;
  String? selectedTransactiontype;
  String? selectedBaseCurrency;
  String? selectedinvoicesubtype;
  String? selectedPaymentmethod;
  String? selectedinvoicetype;
  String? selectedTaxExemptionReasonCode;

  final TextEditingController paymentMethodController= TextEditingController();
  final TextEditingController totalAmountSarController= TextEditingController();
  final TextEditingController taxExemptionReasonCodeController= TextEditingController();
  final TextEditingController docNoController= TextEditingController();
  final TextEditingController taxCategoryController= TextEditingController();
  final TextEditingController taxExemptionReasonController= TextEditingController();
  final TextEditingController docTypeController= TextEditingController();
  final TextEditingController invoiceIndicatorController= TextEditingController();


  List<Map<String, dynamic>> productGroups = [
    {
      'product': '',
      'price': '',
      'quantity': '',
      'discount': '',
      'totalAmount': '',
      'taxRate': '',
      'taxAmount': '',
      'grossAmount': ''
    }
  ];

  void _addGroup() {
    setState(() {
      productGroups.add({
        'product': '',
        'price': '',
        'quantity': '',
        'discount': '',
        'totalAmount': '',
        'taxRate': '',
        'taxAmount': '',
        'grossAmount': ''
      });
    });
  }

  void _removeGroup(int index) {
    setState(() {
      productGroups.removeAt(index);
    });
  }

  Future<void> _submitInvoice() async {
      final invoiceData = {
      "Document": [
        {
          "COMPANY_BRANCH":selectedBranch ?? " ",
          "DOCUMENT_TYPE": selectedTransactiontype??"i",
          "INVOICE_SUB_TYPE_DESC": selectedinvoicesubtype??"B2B",
          "INVOICE_TYPE_DESC": selectedinvoicetype??" ",
          "DOCUMENT_ID_NUMBER": docNoController.text,
          "DOCUMENT_REF_NO": "",
          "CUSTOMER_CODE_NUMBER": "",
          "CUSTOMER_NAME": customerNameController.text,
          "CUSTOMER_NAME_ARABIC": "امجين السعودية",
          "CUSTOMER_ADDRESS":
          "Kudu Building, Office No 2 Talateen Al-Sulimanhia Street, Prince Mamdouh Bin Abdel Aziz Street, Riyadh, ",
          "CUSTOMER_ADDRESS_ARABIC":
          "مبنى كودو، _x000D_مكتب رقم 2 شارع تلاتين السليمانية, شارع الأمير ممدوح بن عبد العزيز, الرياض, ",
          "CUSTOMER_PARTY_IDENTIFICATION": "000000000000",
          "CUSTOMER_PARTY_IDENTIFICATION_TYPE": "CRN",
          "CUSTOMER_PLOT_IDENTIFICATION": "2550",
          "CUSTOMER_POSTAL_ZONE": "23332",
          "CUSTOMER_BUILDING_NUMBER": "6855",
          "CUSTOMER_CITY_NAME": "-",
          "CUSTOMER_CITY_SUB_DIVISION_NAME": "-",
          "CUSTOMER_COUNTRY_CODE": "SA",
          "CUSTOMER_COUNTRY_SUB_ENTITY": "SA",
          "CUSTOMER_EMAIL": "amgen@amgen.com",
          "CUSTOMER_REGISTER_NAME": "United Golden",
          "CUSTOMER_STREET_NAME": "RBuilding number 7875",
          "CUSTOMER_VAT_NO": "310721227500003",
          "DOCUMENT_COMMENTS": "",
          "DOCUMENT_DATE": DateFormat('dd-MMM-yyyy').format(DateTime.now()),
          "DELIVERY_DATE": deliveryDateController.text,
          "CURRENCY": baseCurrencyController ?? "SAR",
          "PAYMENT_TYPE": "42",
          "TAX_CATEGORY": taxCategoryController??'',
          "TAX_EXEMPTION_REASON_CODE": taxExemptionReasonCodeController??"",
          "DOCUMENT_DISCOUNT_TYPE": "Fixed",
          "DOCUMENT_DISCOUNT_VALUE": 0,
          "DOCUMENT_SUB_TOTAL": totalAmountController.text,
          "DOCUMENT_TOTAL_AMOUNT": totalAmountController.text,
          "EXCHANGE": exchangeRateController ?? 1,
          "DOCUMENT_TOTAL_DISCOUNT": 0,

          "Document_Detail": productGroups.map((group) {
            return {
              "PRODUCT_NAME": group['product'],
              "TAX_CATEGORY": group['TaxCategory'],
              "TAX_EXEMPTION_REASON": group['TaxExemptionReason'],
              "TAX_EXEMPTION_REASON_CODE": group['TaxExemptionReasonCode'],
              "PRODUCT_PRICE": group['price'],
              "PRODUCT_QUANTITY": group['quantity'],
              "PRODUCT_DISCOUNT": group['discount'],
              "TAX_RATE": group['taxRate'],
              "TAX_AMOUNT": group['taxAmount'],
              "TOTAL_AMOUNT": group['totalAmount'],
              "GROSS_AMOUNT": group['grossAmount'],
            };
          }).toList(),
        }
      ]
    };

    // Post the invoice
    final url = Uri.parse('https://cosco.phase2.uat.edsgcc.com/api/app_Document');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json",
        'Authorization':'apikeysyncdemo ECBFFE2D-8E76-4335-97FA-8502381B6EBF',
        'COMPANY_SECRATE_KEY':'0273239B-C005-4DE3-8138-A4B8A4068A5B'

      },
      body: jsonEncode(invoiceData),
    );
print (response.statusCode);
    print (response.body);

    if (response.statusCode == 200) {
      print("Invoice created successfully!");
    } else {
      print("Failed to create invoice: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Invoice', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: currentStep,
        onStepContinue: () {
          if (currentStep < 1) setState(() => currentStep += 1);
        },
        onStepCancel: () {
          if (currentStep > 0) setState(() => currentStep -= 1);
        },
        steps: [
          Step(
            title: _buildStepTitle('Step 1', currentStep == 0),
            isActive: currentStep == 0,
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Column(
                children: [
                  CustomDropdown(
                    label: "COMPANY_BRANCH",
                    items: const ['Riyadh', 'Jeddah'],
                    selectedValue: selectedBranch,
                    onChanged: (value) {
                      setState(() {
                        selectedBranch = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomDropdown(
                    label: "INVOICE_TYPE_DESC",
                    items: const ['Standard', 'Simplified'],
                    selectedValue: selectedinvoicetype,
                    onChanged: (value) {
                      setState(() {
                        selectedinvoicetype = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomDropdown(
                    label: "INVOICE_SUB_TYPE_DESC",
                    items: const ['B2B', 'B2G', 'Export'],
                    selectedValue: selectedinvoicesubtype,
                    onChanged: (value) {
                      setState(() {
                        selectedinvoicesubtype = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField("Customer Name", controller: customerNameController),
                  const SizedBox(height: 16),
                  CustomDropdown(
                    label: "Base Currency",
                    items: const ['SAR', 'USD', 'EUR'],
                    selectedValue: selectedBaseCurrency,
                    onChanged: (value) {
                      setState(() {
                        selectedBaseCurrency = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField("Exchange Rate", controller: exchangeRateController),
                  const SizedBox(height: 16),
                  _buildTextField("Delivery Date"),
                  const SizedBox(height: 16),
                  CustomDropdown(
                    label: "Payment Method",
                    items: const ['transfer', 'cash', 'card'],
                    selectedValue: selectedPaymentmethod,
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentmethod = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomDropdown(
                    label: "Tax Category",
                    items: const ['transfer', 'cash', 'card'],
                    selectedValue: selectedTaxCategory,
                    onChanged: (value) {
                      setState(() {
                        selectedTaxCategory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomDropdown(
                    label: "Tax Exemption Reason Code",
                    items: const ['transfer', 'cash', 'card'],
                    selectedValue: selectedTaxExemptionReasonCode,
                    onChanged: (value) {
                      setState(() {
                        selectedTaxExemptionReasonCode = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField("Tax Exemption Reason", controller: taxExemptionReasonController),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: DateFormat('dd-MMM-yyyy').format(DateTime.now()), // Format the date
                    decoration: InputDecoration(
                      labelText: 'Invoice Date',
                      labelStyle: TextStyle(color: Colors.blue[700]),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue[700]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField("Total Amount", controller: totalAmountController),
                  const SizedBox(height: 16),
                  _buildTextField("Total Amount SAR", controller: totalAmountSarController),
                  const SizedBox(height: 16),
                  CustomDropdown(
                    label: "Transaction Type",
                    items: const ['transfer', 'cash', 'card'],
                    selectedValue: selectedTransactiontype,
                    onChanged: (value) {
                      setState(() {
                        selectedTransactiontype = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField("Invoice Indicator(Optional)", controller: invoiceIndicatorController),
                  const SizedBox(height: 16),
                  _buildTextField("Doc No", controller: docNoController),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
    Step(
    title: _buildStepTitle('Step 2', currentStep == 1),
    isActive: currentStep == 1,
    content: SingleChildScrollView(
    child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    child: Column(
    children: [
    ...List.generate(productGroups.length, (index) {
    return Column(
    children: [
    _buildProductGroup(index),
    if (index < productGroups.length - 1)
    Divider(thickness: 1, color: Colors.grey.shade300),
    ],
    );
    }),
    const SizedBox(height: 20),
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    _buildActionButton('Add Group', Colors.green[700]!, _addGroup),
    _buildActionButton('Remove Group', Colors.red[900]!,
    productGroups.length > 1 ? () => _removeGroup(productGroups.length - 1) : null),
    ]),

             const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _submitInvoice,
                    child: const Text("Submit Invoice"),
                  ),
                ],
              ),
            ),
          ),
    )],
      ),
    );
  }

  Widget _buildStepTitle(String title, bool isActive) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: isActive ? Colors.blue[800] : Colors.grey,
      ),
    );
  }

  Widget _buildTextField(String label, {TextEditingController? controller, Icon? icon}) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 16, color: Colors.black),  // Text color and size
      decoration: InputDecoration(
        labelText: label,  // Label text
        labelStyle: TextStyle(
          color: Colors.blue[700],  // Label color
          fontWeight: FontWeight.bold,  // Bold label text
        ),
        hintStyle: TextStyle(color: Colors.grey[500]),  // Hint text style
        prefixIcon: icon,  // Optional icon before the text field (e.g., calendar icon)
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
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }


  Widget _buildProductGroup(int index) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField("Product", ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField("Price",)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField("Quantity", )),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField("Discount" , )),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField("Total Amount", )),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField("Tax Rate %", )),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField("Tax Amount", )),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField("Gross Amount",),
            const SizedBox(height: 12),
            CustomDropdown(
              label: "Tax Category",
              items: const ['transfer', 'cash', 'card'],
              selectedValue: selectedTaxCategory,
              onChanged: (value) {
                setState(() {
                  selectedTaxCategory = value;
                });
              },
            ),
            const SizedBox(height: 12),
            CustomDropdown(
              label: "Tax Exemption Reason Code",
              items: const ['transfer', 'cash', 'card'],
              selectedValue: selectedTaxExemptionReasonCode,
              onChanged: (value) {
                setState(() {
                  selectedTaxExemptionReasonCode = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
class CustomDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final String? selectedValue;
  final Function(String?) onChanged;

  const CustomDropdown({super.key, 
    required this.label,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedValue,  // Display the selected value
      decoration: InputDecoration(
        labelText: label,  // Label text
        labelStyle: TextStyle(
          color: Colors.blue[700],  // Consistent label color
          fontWeight: FontWeight.bold,  // Bold label text for emphasis
        ),
        hintStyle: TextStyle(color: Colors.grey[500]),  // Hint text style when empty
        filled: true,  // Background color
        fillColor: Colors.grey.shade100,  // Light grey background for text field
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),  // Blue border on focus
          borderRadius: BorderRadius.circular(8),  // Rounded corners
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),  // Light grey border when enabled
          borderRadius: BorderRadius.circular(8),  // Rounded corners
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 1.5),  // Red border when error occurs
          borderRadius: BorderRadius.circular(8),  // Rounded corners
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2),  // Thicker red border when focused and error
          borderRadius: BorderRadius.circular(8),  // Rounded corners
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(
        value: item,
        child: Text(item),
      ))
          .toList(),
      onChanged: onChanged,
    );
  }
}
Widget _buildActionButton(String text, Color color, VoidCallback? onPressed) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: Text(text),
  );
}
