import 'dart:convert';

import 'package:brokeo/backend/models/category.dart';

class Merchant {
  String merchantId;
  String name;
  Category category;

  Merchant({
    required this.merchantId,
    required this.name,
    required this.category,
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
      merchantId: decodedJson[merchantIdColumn] as String,
      name: decodedJson[nameColumn] as String,
      category: Category.fromJson(
        decodedJson[categoryColumn] as String,
      ),
    );
  }

  String toJson() {
    //return json string

    return jsonEncode({
      merchantIdColumn: merchantId,
      nameColumn: name,
      categoryColumn: category.toJson(),
    });
  }
}

String nameColumn = "name";
String merchantIdColumn = "merchantId";
String categoryColumn = "category";
