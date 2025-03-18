import 'dart:convert';

import 'package:brokeo/backend/models/merchant.dart';

class Schedule {
  String scheduleId;
  double amount;
  Merchant merchant;
  String category;
  List<DateTime> dates;
  int timePeriod;

  Schedule({
    required this.scheduleId,
    required this.amount,
    required this.merchant,
    required this.category,
    required this.dates,
    required this.timePeriod,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Schedule && other.scheduleId == scheduleId;
  }

  @override
  int get hashCode {
    return scheduleId.hashCode;
  }

  factory Schedule.fromJson(String json) {
    Map<String, dynamic> decodedJson = jsonDecode(json) as Map<String, dynamic>;
    return Schedule(
      scheduleId: decodedJson[scheduleIdColumn] as String,
      amount: decodedJson[amountColumn] as double,
      merchant: Merchant.fromJson(decodedJson[merchantColumn] as String),
      category: decodedJson[categoryColumn] as String,
      dates: List<DateTime>.from(decodedJson[datesColumn] as List),
      timePeriod: decodedJson[timePeriodColumn] as int,
    );
  }
  String toJson() {
    //return json string

    return jsonEncode({
      scheduleIdColumn: scheduleId,
      amountColumn: amount,
      merchantColumn: merchant.toJson(),
      categoryColumn: category,
      datesColumn: dates.map((date) => date.toIso8601String()).toList(),
      timePeriodColumn: timePeriod,
    });
  }
}

String scheduleIdColumn = "scheduleId";
String amountColumn = "amount";
String merchantColumn = "merchant";
String categoryColumn = "category";
String datesColumn = "dates";
String timePeriodColumn = "timePeriod";
