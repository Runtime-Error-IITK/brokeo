import 'dart:convert';

import 'package:brokeo/backend/models/merchant.dart';
import 'package:brokeo/backend/models/category.dart';

class Due {
  String dueId;
  double amount;
  Merchant merchant;
  Category category;

  Due({
    required this.dueId,
    required this.amount,
    required this.merchant,
    required this.category,
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
      dueId: decodedJson[dueIdColumn] as String,
      amount: decodedJson[amountColumn] as double,
      merchant: Merchant.fromJson(decodedJson[merchantColumn] as String),
      category: Category.fromJson(decodedJson[categoryColumn] as String),
    );
  }

  String toJson() {
    //return json string

    return jsonEncode({
      dueIdColumn: dueId,
      amountColumn: amount,
      merchantColumn: merchant.toJson(),
      categoryColumn: category.toJson(),
    });
  }
}

String dueIdColumn = "dueId";
String amountColumn = "amount";
String merchantColumn = "merchant";
String categoryColumn = "category";
