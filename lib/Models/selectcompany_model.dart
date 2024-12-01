class selectcompany {
  List<Company>? company;

  selectcompany({this.company});

  selectcompany.fromJson(Map<String, dynamic> json) {
    if (json['Company'] != null) {
      company = <Company>[];
      json['Company'].forEach((v) {
        company!.add(Company.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (company != null) {
      data['Company'] = company!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Company {
  String? id;
  String? name;
  String? logoUrl;

  Company({this.id, this.name, this.logoUrl});

  Company.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    logoUrl = json['logoUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['logoUrl'] = logoUrl;
    return data;
  }
}
