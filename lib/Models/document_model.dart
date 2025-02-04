class Document {

  Document({
    required this.companyId,
    this.companyBranch,
    required this.documentIdNumber,
    required this.invoiceXml,
    this.fileUpload,
    this.errorDetail,
    required this.requestStatus,
    required this.documentType,
    required this.qrCode,
  });

  final String companyId;
  final String? companyBranch;
  final String documentIdNumber;
  final String invoiceXml;
  final String? fileUpload;
  final String? errorDetail;
  final String requestStatus;
  final String documentType;
  final String qrCode;

  // From JSON factory constructor
  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      companyId: json['COMPANY_ID'],
      companyBranch: json['COMPANY_BRANCH'],
      documentIdNumber: json['DOCUMENT_ID_NUMBER'],
      invoiceXml: json['INVOICE_XML'],
      fileUpload: json['FileUpload'],
      errorDetail: json['Error_Detail'],
      requestStatus: json['Request_Status'],
      documentType: json['DOCUMENT_TYPE'],
      qrCode: json['QRCode'],
    );
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'COMPANY_ID': companyId,
      'COMPANY_BRANCH': companyBranch,
      'DOCUMENT_ID_NUMBER': documentIdNumber,
      'INVOICE_XML': invoiceXml,
      'FileUpload': fileUpload,
      'Error_Detail': errorDetail,
      'Request_Status': requestStatus,
      'DOCUMENT_TYPE': documentType,
      'QRCode': qrCode,
    };
  }
}
