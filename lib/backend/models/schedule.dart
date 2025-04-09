import 'dart:convert';
import 'dart:developer' show log;

import 'package:cloud_firestore/cloud_firestore.dart';

class Schedule {
  final String scheduleId;
  final String userId;
  final double amount;
  final String merchantName;
  final DateTime date;
  final String description;
  final bool paid;

  Schedule({
    required this.scheduleId,
    required this.amount,
    required this.userId,
    required this.merchantName,
    required this.date,
    required this.description,
    required this.paid,
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
      amount: cloudSchedule.amount,
      userId: cloudSchedule.userId,
      merchantName: cloudSchedule.merchantName,
      date: cloudSchedule.date,
      description: cloudSchedule.description,
      paid: cloudSchedule.paid,
    );
  }

  @override
  String toString() {
    return "Schedule{scheduleId: $scheduleId, amount: $amount, merchantName: $merchantName, date: $date, userId: $userId, description: $description, paid: $paid}";
  }
}

class CloudSchedule {
  final String scheduleId;
  final String userId;
  final double amount;
  final String merchantName;
  final DateTime date;
  final String description;
  final bool paid;

  CloudSchedule({
    required this.scheduleId,
    required this.amount,
    required this.userId,
    required this.merchantName,
    required this.date,
    required this.description,
    this.paid = false,
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
    log("Entered this place");
    final cloudSchedule = CloudSchedule(
      scheduleId: doc.id,
      amount: (data[amountColumn] as num).toDouble(),
      date: (data[dateColumn] as Timestamp).toDate(),
      merchantName: data[merchantNameColumn] as String,
      userId: data[userIdColumn] as String,
      description: data[descriptionColumn] as String,
      paid: data[paidColumn] as bool? ?? false,
    );

    // log(cloudSchedule.toString());
    return cloudSchedule;
  }

  factory CloudSchedule.fromSchedule(Schedule schedule) {
    return CloudSchedule(
      scheduleId: schedule.scheduleId,
      amount: schedule.amount,
      date: schedule.date,
      merchantName: schedule.merchantName,
      userId: schedule.userId,
      description: schedule.description,
      paid: schedule.paid,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      merchantNameColumn: merchantName,
      userIdColumn: userId,
      amountColumn: amount,
      dateColumn: Timestamp.fromDate(date),
      descriptionColumn: description,
      paidColumn: paid,
    };
  }

  @override
  String toString() {
    return "CloudSchedule{scheduleId: $scheduleId, amount: $amount, merchantName: $merchantName, date: $date, userId: $userId, description: $description}";
  }
}

const String scheduleIdColumn = "scheduleId";
const String amountColumn = "amount";
const String dateColumn = "date";
const String merchantNameColumn = "merchantName";
const String userIdColumn = "userId";
const String descriptionColumn = "description";
const String paidColumn = "paid";
