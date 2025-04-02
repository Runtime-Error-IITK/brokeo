import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Schedule {
  final String scheduleId;
  final String merchantId;
  final String categoryId;
  final String userId;
  final double amount;
  final List<DateTime> dates;
  final int timePeriod;

  Schedule({
    required this.scheduleId,
    required this.amount,
    required this.merchantId,
    required this.categoryId,
    required this.dates,
    required this.timePeriod,
    required this.userId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Schedule &&
        other.scheduleId == scheduleId &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return scheduleId.hashCode ^ userId.hashCode;
  }

  factory Schedule.fromCloudSchedule(CloudSchedule cloudSchedule) {
    return Schedule(
      scheduleId: cloudSchedule.scheduleId,
      merchantId: cloudSchedule.merchantId,
      categoryId: cloudSchedule.categoryId,
      userId: cloudSchedule.userId,
      amount: cloudSchedule.amount,
      dates: cloudSchedule.dates,
      timePeriod: cloudSchedule.timePeriod,
    );
  }

  @override
  String toString() {
    final jsonDates = jsonEncode(dates);
    return "Schedule{scheduleId: $scheduleId, amount: $amount, merchantId: $merchantId, categoryId: $categoryId, dates: $jsonDates, timePeriod: $timePeriod, userId: $userId}";
  }
}

class CloudSchedule {
  final String scheduleId;
  final String merchantId;
  final String categoryId;
  final String userId;
  final double amount;
  final List<DateTime> dates;
  final int timePeriod;

  CloudSchedule({
    required this.scheduleId,
    required this.merchantId,
    required this.categoryId,
    required this.userId,
    required this.amount,
    required this.dates,
    required this.timePeriod,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CloudSchedule &&
        other.scheduleId == scheduleId &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return scheduleId.hashCode ^ userId.hashCode;
  }

  factory CloudSchedule.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final List<dynamic> timestampList = data[datesColumn] as List<dynamic>;
    final List<DateTime> dateList = timestampList
        .map((timestamp) => (timestamp as Timestamp).toDate())
        .toList();

    return CloudSchedule(
      scheduleId: data[scheduleIdColumn] as String,
      merchantId: data[merchantIdColumn] as String,
      categoryId: data[categoryIdColumn] as String,
      userId: data[userIdColumn] as String,
      amount: (data[amountColumn] as num).toDouble(),
      dates: dateList,
      timePeriod: data[timePeriodColumn] as int,
    );
  }

  factory CloudSchedule.fromSchedule(Schedule schedule) {
    return CloudSchedule(
      scheduleId: schedule.scheduleId,
      merchantId: schedule.merchantId,
      categoryId: schedule.categoryId,
      userId: schedule.userId,
      amount: schedule.amount,
      dates: schedule.dates,
      timePeriod: schedule.timePeriod,
    );
  }

  @override
  String toString() {
    final jsonDates = jsonEncode(dates);
    return "CloudCategory{scheduleId: $scheduleId, amount: $amount, merchantId: $merchantId, categoryId: $categoryId, dates: $jsonDates, timePeriod: $timePeriod, userId: $userId}";
  }
}

String scheduleIdColumn = "scheduleId";
String amountColumn = "amount";
String merchantIdColumn = "merchantId";
String categoryIdColumn = "categoryId";
String datesColumn = "dates";
String timePeriodColumn = "timePeriod";
String userIdColumn = "userId";
