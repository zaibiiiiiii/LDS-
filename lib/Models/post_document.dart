class postdocument {
  String? documentIDNumber;
  String? statusCode;
  String? statusMessage;

  postdocument({this.documentIDNumber, this.statusCode, this.statusMessage});

  postdocument.fromJson(Map<String, dynamic> json) {
    documentIDNumber = json['Document_ID_Number'];
    statusCode = json['StatusCode'];
    statusMessage = json['StatusMessage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Document_ID_Number'] = documentIDNumber;
    data['StatusCode'] = statusCode;
    data['StatusMessage'] = statusMessage;
    return data;
  }
}
