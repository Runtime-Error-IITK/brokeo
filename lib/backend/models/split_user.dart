import 'package:cloud_firestore/cloud_firestore.dart';

class SplitUser {
  String userId;
  String phoneNumber;
  String name;
  SplitUser({
    required this.userId,
    required this.phoneNumber,
    required this.name,
  });

  factory SplitUser.fromCloudSplitUser(CloudSplitUser cloudSplitUser) {
    return SplitUser(
      userId: cloudSplitUser.userId,
      phoneNumber: cloudSplitUser.phoneNumber,
      name: cloudSplitUser.name,
    );
  }

  @override
  bool operator ==(covariant Object other) {
    if (identical(this, other)) return true;

    return other is SplitUser && other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode {
    return phoneNumber.hashCode;
  }

  @override
  String toString() {
    return "SplitUser{userId: $userId, phoneNumber: $phoneNumber, name: $name}";
  }
}

class CloudSplitUser {
  String userId;
  String phoneNumber;
  String name;

  CloudSplitUser({
    required this.userId,
    required this.phoneNumber,
    required this.name,
  });

  @override
  bool operator ==(covariant Object other) {
    if (identical(this, other)) return true;

    return other is CloudSplitUser && other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode {
    return phoneNumber.hashCode;
  }

  factory CloudSplitUser.fromSplitUser(SplitUser splitUser) {
    return CloudSplitUser(
      userId: splitUser.userId,
      phoneNumber: splitUser.phoneNumber,
      name: splitUser.name,
    );
  }

  factory CloudSplitUser.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return CloudSplitUser(
      userId: snapshot.id,
      phoneNumber: data[phoneNumberColumn] ?? '',
      name: data['name'] ?? '',
    );
  }

  @override
  String toString() {
    return "CloudSplitUser{userId: $userId, phoneNumber: $phoneNumber, name: $name}";
  }

  Map<String, dynamic> toFirestore() {
    return {
      phoneNumberColumn: phoneNumber,
      nameColumn: name,
    };
  }
}

String phoneNumberColumn = "phoneNumber";
String nameColumn = "name";
