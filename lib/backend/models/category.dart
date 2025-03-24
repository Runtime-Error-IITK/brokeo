import 'dart:convert';

class Category {
  String name;
  int categoryId;
  double budget;

  Category({
    required this.name,
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
      categoryId: decodedJson[categoryIdColumn] as int,
      budget: decodedJson[budgetColumn] as double,
    );
  }

  factory Category.fromDatabaseCategory(DatabaseCategory databaseCategory) {
    return Category(
      name: databaseCategory.name,
      categoryId: databaseCategory.categoryId,
      budget: databaseCategory.budget,
    );
  }

  @override
  String toString() {
    return "Category{name: $name, categoryId: $categoryId, budget: $budget}";
  }

  String toJson() {
    //return json string

    return jsonEncode({
      nameColumn: name,
      categoryIdColumn: categoryId,
      budgetColumn: budget,
    });
  }
}

class DatabaseCategory {
  String name;
  int categoryId;
  double budget;

  DatabaseCategory({
    required this.name,
    required this.categoryId,
    required this.budget,
  });

  // DatabaseCategory.fromRow(Map<String, dynamic> row)
  //     : categoryId = row[categoryIdColumn] as int,
  //       name = row[nameColumn] as String,
  //       budget = row[budgetColumn] as double;

  factory DatabaseCategory.fromRow(Map<String, Object?> row) {
    return DatabaseCategory(
      name: row[nameColumn] as String,
      categoryId: row[categoryIdColumn] as int,
      budget: row[budgetColumn] as double,
    );
  }

  factory DatabaseCategory.fromCategory(Category category) {
    return DatabaseCategory(
      name: category.name,
      categoryId: category.categoryId,
      budget: category.budget,
    );
  }

  @override
  String toString() =>
      "Category(name: $name, categoryId: $categoryId, budget: $budget)";

  @override
  bool operator ==(covariant Object other) {
    if (identical(this, other)) return true;

    return other is DatabaseCategory && other.categoryId == categoryId;
  }

  @override
  int get hashCode => categoryId.hashCode;
}

String nameColumn = "name";
String categoryIdColumn = "categoryId";
String budgetColumn = "budget";
