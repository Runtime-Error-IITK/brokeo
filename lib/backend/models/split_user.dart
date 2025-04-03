import 'dart:convert';

class SplitUser {
  String name;
  String phoneNumber;

  SplitUser({
    required this.name,
    required this.phoneNumber,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SplitUser && other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode {
    return phoneNumber.hashCode;
  }

  factory SplitUser.fromDatabaseSplitUser(DatabaseSplitUser databaseSplitUser) {
    return SplitUser(
      name: databaseSplitUser.name,
      phoneNumber: databaseSplitUser.phoneNumber,
    );
  }

  @override
  String toString() {
    return "SplitUser{name: $name, phoneNumber: $phoneNumber}";
  }
}

class DatabaseSplitUser {
  String name;
  String phoneNumber;

  DatabaseSplitUser({
    required this.name,
    required this.phoneNumber,
  });

  factory DatabaseSplitUser.fromRow(Map<String, Object?> row) {
    return DatabaseSplitUser(
      name: row[nameColumn] as String,
      phoneNumber: row[phoneNumberColumn] as String,
    );
  }

  factory DatabaseSplitUser.fromSplitUser(SplitUser splitUser) {
    return DatabaseSplitUser(
      name: splitUser.name,
      phoneNumber: splitUser.phoneNumber,
    );
  }

  @override
  String toString() {
    return "DatabaseSplitUser{name: $name, phoneNumber: $phoneNumber}";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DatabaseSplitUser && other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode {
    return phoneNumber.hashCode;
  }
}

String nameColumn = "name";
String phoneNumberColumn = "phoneNumber";
