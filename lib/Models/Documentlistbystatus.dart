class Document {
  final String documentNo;
  final String branch;
  final String? customerName;  // Nullable
  final String issueDate;
  final double totalAmount;
  final double taxInclusiveAmount;
  final String documentType;
  final String status;
  final String? statusMessage; // Nullable

  Document({
    required this.documentNo,
    required this.branch,
    this.customerName,
    required this.issueDate,
    required this.totalAmount,
    required this.taxInclusiveAmount,
    required this.documentType,
    required this.status,
    this.statusMessage, // Nullable
  });

  // Updated fromJson to safely handle null values
  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      documentNo: json['Document_No'] as String? ?? 'NA', // Default to 'NA' if null
      branch: json['Branch'] as String? ?? 'NA', // Default to 'NA' if null
      customerName: json['Customer_Name'] as String?, // Can be null
      issueDate: json['Issue_Date'] as String? ?? 'NA', // Default to 'NA' if null
      totalAmount: (json['TotalAmount'] as num?)?.toDouble() ?? 0.0, // Default to 0.0 if null
      taxInclusiveAmount: (json['TaxInclusiveAmount'] as num?)?.toDouble() ?? 0.0, // Default to 0.0 if null
      documentType: json['document_Type'] as String? ?? 'NA', // Default to 'NA' if null
      status: json['Status'] as String? ?? 'NA', // Default to 'NA' if null
      statusMessage: json['Status_Message'] as String?, // Nullable, no fallback if null
    );
  }

  // toJson method to convert the Document to a map
  Map<String, dynamic> toJson() {
    return {
      'Document_No': documentNo,
      'Branch': branch,
      'Customer_Name': customerName,
      'Issue_Date': issueDate,
      'TotalAmount': totalAmount,
      'TaxInclusiveAmount': taxInclusiveAmount,
      'document_Type': documentType,
      'Status': status,
      'Status_Message': statusMessage, // Nullable, will be null if not provided
    };
  }
}

class ApiResponse {
  final List<List<Document>> result;
  final String status;
  final String? errorCode;
  final String message;

  ApiResponse({
    required this.result,
    required this.status,
    this.errorCode,
    required this.message,
  });

  // Factory method to parse the JSON response
  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      result: (json['result'] as List)
          .map((x) => (x as List)
          .map((item) => Document.fromJson(item as Map<String, dynamic>))
          .toList())
          .toList(),
      status: json['status'] as String? ?? 'NA', // Default to 'NA' if null
      errorCode: json['error_code'] as String?, // Can be null
      message: json['message'] as String? ?? '', // Default to empty string if null
    );
  }

  // toJson method to convert the ApiResponse to a map
  Map<String, dynamic> toJson() {
    return {
      'result': result
          .map((list) => list.map((doc) => doc.toJson()).toList()) // Mapping inner lists to JSON
          .toList(),
      'status': status,
      'error_code': errorCode,
      'message': message,
    };
  }
}
