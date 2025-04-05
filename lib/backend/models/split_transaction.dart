import 'package:cloud_firestore/cloud_firestore.dart';

class SplitTransaction {
  final String splitTransactionId;

  final DateTime date;
  final String description;
  final bool isPayment;
  final String userId;
  final Map<String, double> splitAmounts;

  SplitTransaction({
    required this.splitTransactionId,
    required this.date,
    required this.description,
    required this.isPayment,
    required this.userId,
    required this.splitAmounts,
  });

  factory SplitTransaction.fromCloudSplitTransaction(
      CloudSplitTransaction cloudSplitTransaction) {
    return SplitTransaction(
      splitTransactionId: cloudSplitTransaction.splitTransactionId,
      date: cloudSplitTransaction.date,
      description: cloudSplitTransaction.description,
      isPayment: cloudSplitTransaction.isPayment,
      userId: cloudSplitTransaction.userId,
      splitAmounts: cloudSplitTransaction.splitAmounts,
    );
  }

  @override
  bool operator ==(covariant Object other) {
    if (identical(this, other)) return true;

    return other is SplitTransaction &&
        other.splitTransactionId == splitTransactionId &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return splitTransactionId.hashCode ^ userId.hashCode;
  }

  @override
  String toString() {
    return "SplitTransaction{splitTransactionId: $splitTransactionId, date: $date, description: $description, isPayment: $isPayment, userId: $userId, splitAmounts: ${splitAmounts.toString()}}";
  }
}

class CloudSplitTransaction {
  final String splitTransactionId;
  final DateTime date;
  final String description;
  final bool isPayment;
  final String userId;
  final Map<String, double> splitAmounts;

  CloudSplitTransaction({
    required this.splitTransactionId,
    required this.date,
    required this.description,
    required this.isPayment,
    required this.userId,
    required this.splitAmounts,
  });

  @override
  bool operator ==(covariant Object other) {
    if (identical(this, other)) return true;

    return other is CloudSplitTransaction &&
        other.splitTransactionId == splitTransactionId &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return splitTransactionId.hashCode ^ userId.hashCode;
  }

  @override
  String toString() {
    return "CloudSplitTransaction{splitTransactionId: $splitTransactionId, date: $date, description: $description, isPayment: $isPayment, userId: $userId, splitAmounts: ${splitAmounts.toString()}}";
  }

  factory CloudSplitTransaction.fromSplitTransaction(
      SplitTransaction splitTransaction) {
    return CloudSplitTransaction(
      splitTransactionId: splitTransaction.splitTransactionId,
      date: splitTransaction.date,
      description: splitTransaction.description,
      isPayment: splitTransaction.isPayment,
      userId: splitTransaction.userId,
      splitAmounts: splitTransaction.splitAmounts,
    );
  }

  factory CloudSplitTransaction.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return CloudSplitTransaction(
      splitTransactionId: snapshot.id,
      date: (data['date'] as Timestamp).toDate(),
      description: data['description'] as String,
      isPayment: data['isPayment'] as bool,
      userId: data['userId'] as String,
      splitAmounts: Map<String, double>.from(
        data['splitAmounts'] as Map<String, double>,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      splitTransactionIdColumn: splitTransactionId,
      dateColumn: date,
      descriptionColumn: description,
      isPaymentColumn: isPayment,
      userIdColumn: userId,
      splitAmountsColumn: splitAmounts,
    };
  }
}

const String splitTransactionIdColumn = 'splitTransactionId';
const String dateColumn = 'date';
const String descriptionColumn = 'description';
const String isPaymentColumn = 'isPayment';
const String userIdColumn = 'userId';
const String splitAmountsColumn = 'splitAmounts';
