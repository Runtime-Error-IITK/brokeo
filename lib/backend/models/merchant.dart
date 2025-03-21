import 'dart:convert';

class Merchant {
  int merchantId;
  String name;
  int categoryId;

  Merchant({
    required this.merchantId,
    required this.name,
    required this.categoryId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Merchant && other.merchantId == merchantId;
  }

  @override
  int get hashCode {
    return merchantId.hashCode;
  }

  factory Merchant.fromJson(String json) {
    Map<String, dynamic> decodedJson = jsonDecode(json) as Map<String, dynamic>;
    return Merchant(
      merchantId: decodedJson[merchantIdColumn] as int,
      name: decodedJson[nameColumn] as String,
      categoryId: decodedJson[categoryIdColumn] as int,
    );
  }

  factory Merchant.fromDatabaseMerchant(DatabaseMerchant databaseMerchant) {
    return Merchant(
      merchantId: databaseMerchant.merchantId,
      name: databaseMerchant.name,
      categoryId: databaseMerchant.categoryId,
    );
  }

  @override
  String toString() {
    return "Merchant{merchantId: $merchantId, name: $name, categoryId: $categoryId}";
  }

  String toJson() {
    //return json string

    return jsonEncode({
      merchantIdColumn: merchantId,
      nameColumn: name,
      categoryIdColumn: categoryId,
    });
  }
}

class DatabaseMerchant {
  int merchantId;
  String name;
  int categoryId;

  DatabaseMerchant({
    required this.merchantId,
    required this.name,
    required this.categoryId,
  });

  factory DatabaseMerchant.fromRow(Map<String, Object?> row) {
    return DatabaseMerchant(
      merchantId: row[merchantIdColumn] as int,
      name: row[nameColumn] as String,
      categoryId: row[categoryIdColumn] as int,
    );
  }

  factory DatabaseMerchant.fromMerchant(Merchant merchant) {
    return DatabaseMerchant(
      merchantId: merchant.merchantId,
      name: merchant.name,
      categoryId: merchant.categoryId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DatabaseMerchant && other.merchantId == merchantId;
  }

  @override
  int get hashCode {
    return merchantId.hashCode;
  }

  @override
  String toString() {
    return "DatabaseMerchant{merchantId: $merchantId, name: $name, categoryId: $categoryId}";
  }
}

String nameColumn = "name";
String merchantIdColumn = "merchantId";
String categoryIdColumn = "categoryId";
