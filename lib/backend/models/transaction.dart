import 'dart:convert';

import 'package:brokeo/backend/models/merchant.dart';
import 'package:brokeo/backend/models/sms.dart';
import 'package:brokeo/backend/models/split_user.dart';
import 'package:brokeo/backend/models/category.dart';

class Transaction {
  String transactionId;
  double amount;
  DateTime date;
  Merchant merchant;
  Category category;
  Map<SplitUser, double>? split;
  Sms? sms;

  Transaction({
    required this.transactionId,
    required this.amount,
    required this.date,
    required this.merchant,
    required this.category,
    this.split,
    this.sms,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Transaction && other.transactionId == transactionId;
  }

  @override
  int get hashCode {
    return transactionId.hashCode;
  }

  factory Transaction.fromJson(String json) {
    Map<String, dynamic> decodedJson = jsonDecode(json) as Map<String, dynamic>;
    return Transaction(
        transactionId: decodedJson[transactionIdColumn] as String,
        amount: decodedJson[amountColumn] as double,
        date: DateTime.parse(decodedJson[dateColumn] as String),
        merchant: Merchant.fromJson(decodedJson[merchantColumn] as String),
        category: Category.fromJson(decodedJson[categoryColumn] as String),
        split: decodedJson[splitColumn] != null
            ? Map<SplitUser, double>.from(decodedJson[splitColumn])
            : null,
        sms: decodedJson[smsColumn] != null
            ? Sms.fromJson(decodedJson[smsColumn] as String)
            : null);
  }

  String toJson() {
    //return json string

    return jsonEncode({
      transactionIdColumn: transactionId,
      amountColumn: amount,
      dateColumn: date.toIso8601String(),
      merchantColumn: merchant.toJson(),
      categoryColumn: category.toJson(),
      splitColumn: split?.map((key, value) => MapEntry(key.toJson(), value)),
      smsColumn: sms?.toJson(),
    });
  }
}

String transactionIdColumn = "transactionId";
String amountColumn = "amount";
String dateColumn = "date";
String merchantColumn = "merchant";
String categoryColumn = "category";
String splitColumn = "split";
String smsColumn = "sms";
