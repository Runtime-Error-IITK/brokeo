import 'package:cloud_firestore/cloud_firestore.dart';

class SplitTransaction {
  final String splitTransactionId;

  final DateTime date;
  final String description;
  final bool isPayment;
  final String userPhone;
  final Map<String, double> splitAmounts;

  SplitTransaction({
    required this.splitTransactionId,
    required this.date,
    required this.description,
    required this.isPayment,
    required this.userPhone,
    required this.splitAmounts,
  });

  factory SplitTransaction.fromCloudSplitTransaction(
      CloudSplitTransaction cloudSplitTransaction) {
    return SplitTransaction(
      splitTransactionId: cloudSplitTransaction.splitTransactionId,
      date: cloudSplitTransaction.date,
      description: cloudSplitTransaction.description,
      isPayment: cloudSplitTransaction.isPayment,
      userPhone: cloudSplitTransaction.userId,
      splitAmounts: cloudSplitTransaction.splitAmounts,
    );
  }

  @override
  bool operator ==(covariant Object other) {
    if (identical(this, other)) return true;

    return other is SplitTransaction &&
        other.splitTransactionId == splitTransactionId &&
        other.userPhone == userPhone;
  }

  @override
  int get hashCode {
    return splitTransactionId.hashCode ^ userPhone.hashCode;
  }

  @override
  String toString() {
    return "SplitTransaction{splitTransactionId: $splitTransactionId, date: $date, description: $description, isPayment: $isPayment, userId: $userPhone, splitAmounts: ${splitAmounts.toString()}}";
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
      userId: splitTransaction.userPhone,
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
      userPhoneColumn: userId,
      splitAmountsColumn: splitAmounts,
    };
  }
}

const String splitTransactionIdColumn = 'splitTransactionId';
const String dateColumn = 'date';
const String descriptionColumn = 'description';
const String isPaymentColumn = 'isPayment';
const String userPhoneColumn = 'userPhone';
const String splitAmountsColumn = 'splitAmounts';
