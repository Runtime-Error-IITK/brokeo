import 'dart:convert';

class Transaction {
  int transactionId;
  double amount;
  DateTime date;
  int merchantId;
  int categoryId;
  Map<String, double>? split;
  int? smsId;

  Transaction({
    required this.transactionId,
    required this.amount,
    required this.date,
    required this.merchantId,
    required this.categoryId,
    this.split,
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

  factory Transaction.fromJson(String json) {
    Map<String, dynamic> decodedJson = jsonDecode(json) as Map<String, dynamic>;
    return Transaction(
      transactionId: decodedJson[transactionIdColumn] as int,
      amount: decodedJson[amountColumn] as double,
      date: DateTime.parse(decodedJson[dateColumn] as String),
      merchantId: decodedJson[merchantIdColumn] as int,
      categoryId: decodedJson[categoryIdColumn] as int,
      split: decodedJson[splitColumn] != null
          ? jsonDecode(decodedJson[splitColumn] as String)
          : null,
      smsId: decodedJson[smsIdColumn] != null
          ? decodedJson[smsIdColumn] as int
          : null,
    );
  }

  String toJson() {
    //return json string

    return jsonEncode({
      transactionIdColumn: transactionId,
      amountColumn: amount,
      dateColumn: date.toIso8601String(),
      merchantIdColumn: merchantId,
      categoryIdColumn: categoryId,
      splitColumn: split != null ? jsonEncode(split) : null,
      smsIdColumn: smsId,
    });
  }
}

class DatabaseTransaction {
  int transactionId;
  double amount;
  String date;
  int merchantId;
  int categoryId;
  String? split;
  int? smsId;

  DatabaseTransaction({
    required this.transactionId,
    required this.amount,
    required this.date,
    required this.merchantId,
    required this.categoryId,
    this.split,
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
    return "DatabaseTransaction{transactionId: $transactionId, amount: $amount, date: $date, merchantId: $merchantId, categoryId: $categoryId, split: $split, smsId: $smsId}";
  }

  factory DatabaseTransaction.fromRow(Map<String, Object?> row) {
    return DatabaseTransaction(
      transactionId: row[transactionIdColumn] as int,
      amount: row[amountColumn] as double,
      date: row[dateColumn] as String,
      merchantId: row[merchantIdColumn] as int,
      categoryId: row[categoryIdColumn] as int,
      split: row[splitColumn] as String?,
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
      split: transaction.split != null ? jsonEncode(transaction.split) : null,
      smsId: transaction.smsId,
    );
  }
}

const String transactionIdColumn = "transactionId";
const String amountColumn = "amount";
const String dateColumn = "date";
const String merchantIdColumn = "merchantId";
const String categoryIdColumn = "category";
const String splitColumn = "split";
const String smsIdColumn = "sms";
