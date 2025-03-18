import 'dart:convert';

class Category {
  String name;
  List<String> merchants;
  String categoryId;
  double budget;

  Category({
    required this.name,
    required this.merchants,
    required this.categoryId,
    required this.budget,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Category && other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    return categoryId.hashCode;
  }

  factory Category.fromJson(String json) {
    Map<String, dynamic> decodedJson = jsonDecode(json) as Map<String, dynamic>;
    return Category(
      name: decodedJson[nameColumn] as String,
      merchants: List<String>.from(decodedJson[merchantsColumn] as List),
      categoryId: decodedJson[categoryIdColumn] as String,
      budget: decodedJson[budgetColumn] as double,
    );
  }
  String toJson() {
    //return json string

    return jsonEncode({
      nameColumn: name,
      merchantsColumn: merchants,
      categoryIdColumn: categoryId,
      budgetColumn: budget,
    });
  }
}

String nameColumn = "name";
String merchantsColumn = "merchants";
String categoryIdColumn = "categoryId";
String budgetColumn = "budget";
