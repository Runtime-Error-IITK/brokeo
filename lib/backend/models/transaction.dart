import 'dart:convert';

class Transaction {
  int transactionId;
  double amount;
  DateTime date;
  int merchantId;
  int categoryId;
  int? smsId;

  Transaction({
    required this.transactionId,
    required this.amount,
    required this.date,
    required this.merchantId,
    required this.categoryId,
    this.smsId,
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
}

class DatabaseTransaction {
  int transactionId;
  double amount;
  String date;
  int merchantId;
  int categoryId;
  int? smsId;

  DatabaseTransaction({
    required this.transactionId,
    required this.amount,
    required this.date,
    required this.merchantId,
    required this.categoryId,
    this.smsId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DatabaseTransaction && other.transactionId == transactionId;
  }

  @override
  int get hashCode {
    return transactionId.hashCode;
  }

  @override
  String toString() {
    return "DatabaseTransaction{transactionId: $transactionId, amount: $amount, date: $date, merchantId: $merchantId, categoryId: $categoryId, smsId: $smsId}";
  }

  factory DatabaseTransaction.fromRow(Map<String, Object?> row) {
    return DatabaseTransaction(
      transactionId: row[transactionIdColumn] as int,
      amount: row[amountColumn] as double,
      date: row[dateColumn] as String,
      merchantId: row[merchantIdColumn] as int,
      categoryId: row[categoryIdColumn] as int,
      smsId: row[smsIdColumn] != null ? row[smsIdColumn] as int : null,
    );
  }

  factory DatabaseTransaction.fromTransaction(Transaction transaction) {
    return DatabaseTransaction(
      transactionId: transaction.transactionId,
      amount: transaction.amount,
      date: transaction.date.toIso8601String(),
      merchantId: transaction.merchantId,
      categoryId: transaction.categoryId,
      smsId: transaction.smsId,
    );
  }
}

const String transactionIdColumn = "transactionId";
const String amountColumn = "amount";
const String dateColumn = "date";
const String merchantIdColumn = "merchantId";
const String categoryIdColumn = "category";
const String smsIdColumn = "sms";
