import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String transactionId;
  final double amount;
  final DateTime date;
  final String merchantId;
  final String categoryId;
  final String userId;
  final String sms;

  Transaction({
    required this.transactionId,
    required this.amount,
    required this.date,
    required this.merchantId,
    required this.categoryId,
    required this.userId,
    this.sms = "",
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Transaction &&
        other.transactionId == transactionId &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return transactionId.hashCode ^ userId.hashCode;
  }

  @override
  String toString() {
    return "Transaction{transactionId: $transactionId, amount: $amount, date: $date, merchantId: $merchantId, categoryId: $categoryId, userId: $userId}";
  }

  factory Transaction.fromCloudTransaction(CloudTransaction cloudTransaction) {
    return Transaction(
      transactionId: cloudTransaction.transactionId,
      amount: cloudTransaction.amount,
      date: cloudTransaction.date,
      merchantId: cloudTransaction.merchantId,
      categoryId: cloudTransaction.categoryId,
      userId: cloudTransaction.userId,
      sms: cloudTransaction.sms,
    );
  }
}

class CloudTransaction {
  final String transactionId;
  final double amount;
  final DateTime date;
  final String merchantId;
  final String categoryId;
  final String userId;
  final String sms;

  CloudTransaction({
    required this.transactionId,
    required this.amount,
    required this.date,
    required this.merchantId,
    required this.categoryId,
    required this.userId,
    this.sms = "",
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CloudTransaction &&
        other.transactionId == transactionId &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return transactionId.hashCode ^ userId.hashCode;
  }

  factory CloudTransaction.fromTransaction(Transaction transaction) {
    return CloudTransaction(
      transactionId: transaction.transactionId,
      amount: transaction.amount,
      date: transaction.date,
      merchantId: transaction.merchantId,
      categoryId: transaction.categoryId,
      userId: transaction.userId,
      sms: transaction.sms,
    );
  }

  factory CloudTransaction.fromSnapshot(DocumentSnapshot snapshot) {
    return CloudTransaction(
      transactionId: snapshot[transactionIdColumn] as String,
      amount: (snapshot[amountColumn] as num).toDouble(),
      date: (snapshot[dateColumn] as Timestamp).toDate(),
      merchantId: snapshot[merchantIdColumn] as String,
      categoryId: snapshot[categoryIdColumn] as String,
      userId: snapshot[userIdColumn] as String,
      sms: snapshot[smsIdColumn] as String,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      transactionIdColumn: transactionId,
      amountColumn: amount,
      dateColumn: Timestamp.fromDate(date),
      merchantIdColumn: merchantId,
      categoryIdColumn: categoryId,
      smsIdColumn: sms,
    };
  }

  @override
  String toString() {
    return "CloudTransaction{transactionId: $transactionId, amount: $amount, date: $date, merchantId: $merchantId, categoryId: $categoryId, userId: $userId}";
  }
}

const String transactionIdColumn = "transactionId";
const String amountColumn = "amount";
const String dateColumn = "date";
const String merchantIdColumn = "merchantId";
const String categoryIdColumn = "category";
const String smsIdColumn = "sms";
const String userIdColumn = "userId";
