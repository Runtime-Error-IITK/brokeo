import 'package:cloud_firestore/cloud_firestore.dart';

class SplitTransaction {
  final String splitTransactionId;
  final double amount;
  final DateTime date;
  final String description;
  final bool isPayment;
  final String userId;
  final Map<String, double> splitAmounts;

  SplitTransaction({
    required this.splitTransactionId,
    required this.amount,
    required this.date,
    required this.description,
    required this.isPayment,
    required this.userId,
    required this.splitAmounts,
  });

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
    return "SplitTransaction{splitTransactionId: $splitTransactionId, amount: $amount, date: $date, description: $description, isPayment: $isPayment, userId: $userId, splitAmounts: ${splitAmounts.toString()}}";
  }
}

class CloudSplitTransaction {
  final String splitTransactionId;
  final double amount;
  final DateTime date;
  final String description;
  final bool isPayment;
  final String userId;
  final Map<String, double> splitAmounts;

  CloudSplitTransaction({
    required this.splitTransactionId,
    required this.amount,
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
    return "CloudSplitTransaction{splitTransactionId: $splitTransactionId, amount: $amount, date: $date, description: $description, isPayment: $isPayment, userId: $userId, splitAmounts: ${splitAmounts.toString()}}";
  }

  factory CloudSplitTransaction.fromSplitTransaction(
      SplitTransaction splitTransaction) {
    return CloudSplitTransaction(
      splitTransactionId: splitTransaction.splitTransactionId,
      amount: splitTransaction.amount,
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
      splitTransactionId: data['splitTransactionId'] as String,
      amount: (data['amount'] as num).toDouble(),
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
      amountColumn: amount,
      dateColumn: date,
      descriptionColumn: description,
      isPaymentColumn: isPayment,
      userIdColumn: userId,
      splitAmountsColumn: splitAmounts,
    };
  }
}

const String splitTransactionIdColumn = 'splitTransactionId';
const String amountColumn = 'amount';
const String dateColumn = 'date';
const String descriptionColumn = 'description';
const String isPaymentColumn = 'isPayment';
const String userIdColumn = 'userId';
const String splitAmountsColumn = 'splitAmounts';
