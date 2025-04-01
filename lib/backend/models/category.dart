import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String name;
  final String categoryId;
  final double budget;
  final String userId;

  Category({
    required this.name,
    required this.categoryId,
    required this.budget,
    required this.userId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Category &&
        other.categoryId == categoryId &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return categoryId.hashCode ^ userId.hashCode;
  }

  factory Category.fromCloudCategory(CloudCategory cloudCategory) {
    return Category(
      name: cloudCategory.name,
      categoryId: cloudCategory.categoryId,
      budget: cloudCategory.budget,
      userId: cloudCategory.categoryId,
    );
  }

  // factory Category.fromDatabaseCategory(DatabaseCategory databaseCategory) {
  //   return Category(
  //     name: databaseCategory.name,
  //     categoryId: databaseCategory.categoryId,
  //     budget: databaseCategory.budget,
  //   );
  // }

  @override
  String toString() {
    return "Category{name: $name, categoryId: $categoryId, budget: $budget, userId: $userId}";
  }
}

class CloudCategory {
  final String name;
  final String categoryId;
  final double budget;
  final String userId;

  CloudCategory({
    required this.name,
    required this.categoryId,
    required this.budget,
    required this.userId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CloudCategory &&
        other.categoryId == categoryId &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return categoryId.hashCode ^ userId.hashCode;
  }

  factory CloudCategory.fromCategory(Category category) {
    return CloudCategory(
      name: category.name,
      categoryId: category.categoryId,
      budget: category.budget,
      userId: category.userId,
    );
  }

  factory CloudCategory.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CloudCategory(
      categoryId: doc.id,
      name: data[nameColumn] as String,
      budget: (data[budgetColumn] as num).toDouble(),
      userId: data[userIdColumn] as String,
    );
  }

  @override
  String toString() {
    return "CloudCategory{name: $name, categoryId: $categoryId, budget: $budget, userId: $userId}";
  }

  Map<String, dynamic> toFirestore() {
    return {
      nameColumn: name,
      budgetColumn: budget,
      userIdColumn: userId,
    };
  }
}

// class DatabaseCategory {
//   String name;
//   int categoryId;
//   double budget;

//   DatabaseCategory({
//     required this.name,
//     required this.categoryId,
//     required this.budget,
//   });

//   // DatabaseCategory.fromRow(Map<String, dynamic> row)
//   //     : categoryId = row[categoryIdColumn] as int,
//   //       name = row[nameColumn] as String,
//   //       budget = row[budgetColumn] as double;

//   factory DatabaseCategory.fromRow(Map<String, Object?> row) {
//     return DatabaseCategory(
//       name: row[nameColumn] as String,
//       categoryId: row[categoryIdColumn] as int,
//       budget: row[budgetColumn] as double,
//     );
//   }

//   factory DatabaseCategory.fromCategory(Category category) {
//     return DatabaseCategory(
//       name: category.name,
//       categoryId: category.categoryId,
//       budget: category.budget,
//     );
//   }

//   @override
//   String toString() =>
//       "Category(name: $name, categoryId: $categoryId, budget: $budget)";

//   @override
//   bool operator ==(covariant Object other) {
//     if (identical(this, other)) return true;

//     return other is DatabaseCategory && other.categoryId == categoryId;
//   }

//   @override
//   int get hashCode => categoryId.hashCode;
// }

const String nameColumn = "name";
const String categoryIdColumn = "categoryId";
const String budgetColumn = "budget";
const String userIdColumn = "userId";
