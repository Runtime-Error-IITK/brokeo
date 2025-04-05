import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class SplitUser {
  String userId;
  String phoneNumber;

  SplitUser({
    required this.userId,
    required this.phoneNumber,
  });

  factory SplitUser.fromCloudSplitUser(CloudSplitUser cloudSplitUser) {
    return SplitUser(
      userId: cloudSplitUser.userId,
      phoneNumber: cloudSplitUser.phoneNumber,
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
    return "SplitUser{userId: $userId, phoneNumber: $phoneNumber}";
  }
}

class CloudSplitUser {
  String userId;
  String phoneNumber;

  CloudSplitUser({
    required this.userId,
    required this.phoneNumber,
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
    );
  }

  factory CloudSplitUser.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return CloudSplitUser(
      userId: snapshot.id,
      phoneNumber: data[phoneNumberColumn] ?? '',
    );
  }

  @override
  String toString() {
    return "CloudSplitUser{userId: $userId, phoneNumber: $phoneNumber}";
  }

  Map<String, dynamic> toFirestore() {
    return {
      phoneNumberColumn: phoneNumber,
    };
  }
}

String phoneNumberColumn = "phoneNumber";
