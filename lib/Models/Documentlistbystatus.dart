class DocumentList {
  final List<Document> documents;

  DocumentList({required this.documents});

  factory DocumentList.fromJson(Map<String, dynamic> json) {
    return DocumentList(
      documents: (json['Documents'] as List<dynamic>)
          .map((document) => Document.fromJson(document as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Document {
  final int documentno;
  final String documentBranch;
  final String customerName;
  final String issueDate;
  final double totalAmount;
  final double taxInclusiveAmount;
  final String documentType;
  final String status;

  Document({
    required this.documentno,
    required this.documentBranch,
    required this.customerName,
    required this.issueDate,
    required this.totalAmount,
    required this.taxInclusiveAmount,
    required this.documentType,
    required this.status,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      documentno: json['documentno'] ?? 0,
      documentBranch: json['documentBranch'] ?? '',
      customerName: json['customerName'] ?? '',
      issueDate: json['issueDate'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      taxInclusiveAmount: (json['taxInclusiveAmount'] ?? 0).toDouble(),
      documentType: json['documentType'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
