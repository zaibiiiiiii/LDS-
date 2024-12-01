import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/post_document.dart';

Future<postdocument?> sendDocumentRequest() async {
  // Define your URL
  final url = Uri.parse('https://cosco.phase2.uat.edsgcc.com/api/app_Document');

  // Your request headers
  final headers = {
    'Authorization': 'apikeysyncdemo ECBFFE2D-8E76-4335-97FA-8502381B6EBF',
    'COMPANY_SECRATE_KEY': '0273239B-C005-4DE3-8138-A4B8A4068A5B',
    'Content-Type': 'application/json',
  };

  // The data to send (this is just an example, you can use your own data)
  final body = json.encode(

      {"Document": [
      {
        "COMPANY_BRANCH": "Riyad",
        "DOCUMENT_TYPE": "i",
        "INVOICE_SUB_TYPE_DESC": "B2B",
        "INVOICE_TYPE_DESC": "Standard Invoice",
        "DOCUMENT_ID_NUMBER": "EDS-App-004",
        "CUSTOMER_NAME": "Amgen Saudi",
        "CUSTOMER_EMAIL": "amgen@amgen.com",
        "DOCUMENT_DATE": "11-Nov-2024",
        "DOCUMENT_TOTAL_AMOUNT": 1080,
        "Document_Detail": [
          {
            "PRODUCT_NAME": "Hotel",
            "PRODUCT_QUANTITY": 1,
            "PRODUCT_PRICE": 0,
          }
        ]
      }
    ]}
  );

  // Send the POST request
  final response = await http.post(url, headers: headers, body: body);

  // Handle the response
  if (response.statusCode == 200) {
    // Assuming the response body contains the document data
    final responseBody = json.decode(response.body);
    final documentData = postdocument.fromJson(responseBody[0]); // Assuming the document is the first element

    return documentData;
  } else {
    // Handle the error if status code is not 200
    final responseBody = json.decode(response.body);
    final statusCode = responseBody[0]['StatusCode'];
    final statusMessage = responseBody[0]['StatusMessage'];
    if (statusCode == 'BadRequest') {
      showErrorDialog(statusMessage);
    }
    return null;
  }
}

void showErrorDialog(String message) {
  print('Error: $message');  // Or use a dialog, Snackbar, etc.
}
