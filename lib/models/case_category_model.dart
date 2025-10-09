class CaseCategory {
  final String id;
  final String name;

  CaseCategory({required this.id, required this.name});

  factory CaseCategory.fromJson(Map<String, dynamic> json) {
    return CaseCategory(id: json['cc_id'].toString(), name: json['tag']);
  }
}
