class InvoiceDashboard {
  ZatchaDashboard? zatchaDashboard;

  InvoiceDashboard({this.zatchaDashboard});

   factory InvoiceDashboard.fromJson(Map<String, dynamic> json) {
    return InvoiceDashboard(
      zatchaDashboard: json['ZatchaDashboard'] != null
          ? ZatchaDashboard.fromJson(json['ZatchaDashboard'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (zatchaDashboard != null) {
      data['ZatchaDashboard'] = zatchaDashboard!.toJson();
    }
    return data;
  }
}

class ZatchaDashboard {
  Status? status;
  Type? type;

  ZatchaDashboard({this.status, this.type});

  factory ZatchaDashboard.fromJson(Map<String, dynamic> json) {
    return ZatchaDashboard(
      status: json['status'] != null ? Status.fromJson(json['status']) : null,
      type: json['type'] != null ? Type.fromJson(json['type']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (status != null) {
      data['status'] = status!.toJson();
    }
    if (type != null) {
      data['type'] = type!.toJson();
    }
    return data;
  }
}

class Status {
  int? clear;
  int? error;
  int? warning;
  int? pending;

  Status({this.clear, this.error, this.warning, this.pending});

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      clear: json['clear'],
      error: json['error'],
      warning: json['warning'],
      pending: json['pending'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['clear'] = clear;
    data['error'] = error;
    data['warning'] = warning;
    data['pending'] = pending;
    return data;
  }
}

class Type {
  int? invoice;
  int? creditNote;
  int? debitNote;
  int? prepaid;
  int? draft;

  Type({
    this.invoice,
    this.creditNote,
    this.debitNote,
    this.prepaid,
    this.draft,
  });

  factory Type.fromJson(Map<String, dynamic> json) {
    return Type(
      invoice: json['Invoice'],
      creditNote: json['CreditNote'],
      debitNote: json['DebitNote'],
      prepaid: json['prepaid'],
      draft: json['draft'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Invoice'] = invoice;
    data['CreditNote'] = creditNote;
    data['DebitNote'] = debitNote;
    data['prepaid'] = prepaid;
    data['draft'] = draft;
    return data;
  }
}
