import 'dart:convert';

class Due {
  int dueId;
  double amount;
  int merchantId;
  int categoryId;

  Due({
    required this.dueId,
    required this.amount,
    required this.merchantId,
    required this.categoryId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Due && other.dueId == dueId;
  }

  @override
  int get hashCode {
    return dueId.hashCode;
  }

  factory Due.fromJson(String json) {
    Map<String, dynamic> decodedJson = jsonDecode(json) as Map<String, dynamic>;
    return Due(
      dueId: decodedJson[dueIdColumn] as int,
      amount: decodedJson[amountColumn] as double,
      merchantId: decodedJson[merchantIdColumn] as int,
      categoryId: decodedJson[categoryIdColumn] as int,
    );
  }

  @override
  String toString() {
    return "Due{dueId: $dueId, amount: $amount, merchantId: $merchantId, categoryId: $categoryId}";
  }

  factory Due.fromDatabaseDue(DatabaseDue databaseDue) {
    return Due(
      dueId: databaseDue.dueId,
      amount: databaseDue.amount,
      merchantId: databaseDue.merchantId,
      categoryId: databaseDue.categoryId,
    );
  }

  String toJson() {
    //return json string

    return jsonEncode({
      dueIdColumn: dueId,
      amountColumn: amount,
      merchantIdColumn: merchantId,
      categoryIdColumn: categoryId,
    });
  }
}

class DatabaseDue {
  int dueId;
  double amount;
  int merchantId;
  int categoryId;

  DatabaseDue({
    required this.dueId,
    required this.amount,
    required this.merchantId,
    required this.categoryId,
  });

  factory DatabaseDue.fromRow(Map<String, Object?> row) {
    return DatabaseDue(
      dueId: row[dueIdColumn] as int,
      amount: row[amountColumn] as double,
      merchantId: row[merchantIdColumn] as int,
      categoryId: row[categoryIdColumn] as int,
    );
  }

  factory DatabaseDue.fromDue(Due due) {
    return DatabaseDue(
      dueId: due.dueId,
      amount: due.amount,
      merchantId: due.merchantId,
      categoryId: due.categoryId,
    );
  }

  @override
  String toString() {
    return "Due(dueId: $dueId, amount: $amount, merchantId: $merchantId, categoryId: $categoryId)";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DatabaseDue && other.dueId == dueId;
  }

  @override
  int get hashCode {
    return dueId.hashCode;
  }
}

String dueIdColumn = "dueId";
String amountColumn = "amount";
String merchantIdColumn = "merchantId";
String categoryIdColumn = "categoryId";
