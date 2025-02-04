// class DashboardData {
//   final int error;
//   final int warning;
//   final int pending;
//   final int cancel;
//   final int invoice;
//   final int creditNote;
//   final int debitNote;
//   final int draft;
//   final int prepaid;
//
//   DashboardData({
//     required this.error,
//     required this.warning,
//     required this.pending,
//     required this.cancel,
//     required this.invoice,
//     required this.creditNote,
//     required this.debitNote,
//     required this.draft,
//     required this.prepaid,
//   });
//
//   // Factory constructor to create a DashboardData instance from JSON
//   factory DashboardData.fromJson(Map<String, dynamic> json) {
//     return DashboardData(
//       error: json['Error'] as int,
//       warning: json['Warning'] as int,
//       // Convert string values to integers using tryParse, defaulting to 0 if conversion fails
//       pending: int.tryParse(json['Pending'] as String) ?? 0,
//       cancel: int.tryParse(json['Cancel'] as String) ?? 0,
//       invoice: int.tryParse(json['Invoice'] as String) ?? 0,
//       creditNote: int.tryParse(json['Credit_note'] as String) ?? 0,
//       debitNote: int.tryParse(json['Debit_note'] as String) ?? 0,
//       draft: int.tryParse(json['Draft'] as String) ?? 0,
//       prepaid: int.tryParse(json['Prepaid'] as String) ?? 0,
//     );
//   }
//
//
//   // Method to convert DashboardData instance to JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'Error': error,
//       'Warning': warning,
//       'Pending': pending.toString(),
//       'Cancel': cancel.toString(),
//       'Invoice': invoice.toString(),
//       'Credit_note': creditNote.toString(),
//       'Debit_note': debitNote.toString(),
//       'Draft': draft.toString(),
//       'Prepaid': prepaid.toString(),
//     };
//   }
// }
//
// class DashboardResponse {
//   final List<DashboardData> result;
//   final String status;
//   final String? errorCode;
//   final String message;
//
//   DashboardResponse({
//     required this.result,
//     required this.status,
//     required this.errorCode,
//     required this.message,
//   });
//
//   factory DashboardResponse.fromJson(Map<String, dynamic> json) {
//     final message = json['Message'] as String? ?? '';
//     final resultList = json['result'] ?? [];
//
//     return DashboardResponse(
//       result: resultList is List
//           ? resultList
//           .map((item) =>
//           DashboardData.fromJson(item as Map<String, dynamic>))
//           .toList()
//           : [],
//       status: json['status'] as String? ?? '',
//       errorCode: json['error_code'] as String?,
//       message: message,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'result': result.map((item) => item.toJson()).toList(),
//       'status': status,
//       'error_code': errorCode,
//       'message': message,
//     };
//   }
// }
//
