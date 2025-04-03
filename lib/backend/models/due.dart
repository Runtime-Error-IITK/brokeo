import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Due {
  final String dueId;
  final double amount;
  final String merchantId;
  final String categoryId;
  final String userId;

  Due({
    required this.dueId,
    required this.amount,
    required this.merchantId,
    required this.categoryId,
    required this.userId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Due && other.dueId == dueId && other.userId == userId;
  }

  @override
  int get hashCode {
    return dueId.hashCode ^ userId.hashCode;
  }

  factory Due.fromCloudDue(CloudDue cloudDue) {
    return Due(
      dueId: cloudDue.dueId,
      amount: cloudDue.amount,
      merchantId: cloudDue.merchantId,
      categoryId: cloudDue.categoryId,
      userId: cloudDue.userId,
    );
  }

  @override
  String toString() {
    return "Due{dueId: $dueId, amount: $amount, merchantId: $merchantId, categoryId: $categoryId, userId: $userId}";
  }
}

class CloudDue {
  final String dueId;
  final double amount;
  final String merchantId;
  final String categoryId;
  final String userId;

  CloudDue({
    required this.dueId,
    required this.amount,
    required this.merchantId,
    required this.categoryId,
    required this.userId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CloudDue && other.dueId == dueId && other.userId == userId;
  }

  @override
  int get hashCode {
    return dueId.hashCode ^ userId.hashCode;
  }

  factory CloudDue.fromDue(Due due) {
    return CloudDue(
      dueId: due.dueId,
      amount: due.amount,
      merchantId: due.merchantId,
      categoryId: due.categoryId,
      userId: due.userId,
    );
  }

  factory CloudDue.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CloudDue(
      dueId: doc.id,
      amount: (data[amountColumn] as num).toDouble(),
      merchantId: data[merchantIdColumn] as String,
      categoryId: data[categoryIdColumn] as String,
      userId: data[userIdColumn] as String,
    );
  }

  @override
  String toString() {
    return "CloudDue{dueId: $dueId, amount: $amount, merchantId: $merchantId, categoryId: $categoryId, userId: $userId}";
  }

  Map<String, dynamic> toFirestore() {
    return {
      amountColumn: amount,
      merchantIdColumn: merchantId,
      categoryIdColumn: categoryId,
      userIdColumn: userId,
    };
  }
}

const String dueIdColumn = "dueId";
const String amountColumn = "amount";
const String merchantIdColumn = "merchantId";
const String categoryIdColumn = "categoryId";
const String userIdColumn = "userId";
