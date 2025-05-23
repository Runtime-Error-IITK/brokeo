import 'package:cloud_firestore/cloud_firestore.dart';

class Merchant {
  final String merchantId;
  final String name;
  final String categoryId;
  final String userId;

  Merchant({
    required this.merchantId,
    required this.name,
    required this.categoryId,
    required this.userId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Merchant &&
        other.merchantId == merchantId &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return merchantId.hashCode ^ userId.hashCode;
  }

  factory Merchant.fromCloudMerchant(CloudMerchant cloudMerchant) {
    return Merchant(
      merchantId: cloudMerchant.merchantId,
      name: cloudMerchant.name,
      categoryId: cloudMerchant.categoryId,
      userId: cloudMerchant.userId,
    );
  }

  @override
  String toString() {
    return "Merchant{merchantId: $merchantId, name: $name, categoryId: $categoryId, userId: $userId}";
  }
}

class CloudMerchant {
  final String name;
  final String merchantId;
  final String categoryId;
  final String userId;

  CloudMerchant({
    required this.name,
    required this.merchantId,
    required this.categoryId,
    required this.userId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CloudMerchant &&
        other.merchantId == merchantId &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return merchantId.hashCode ^ userId.hashCode;
  }

  factory CloudMerchant.fromMerchant(Merchant merchant) {
    return CloudMerchant(
      name: merchant.name,
      merchantId: merchant.merchantId,
      categoryId: merchant.categoryId,
      userId: merchant.userId,
    );
  }

  factory CloudMerchant.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CloudMerchant(
      merchantId: doc.id,
      name: data[nameColumn] as String,
      categoryId: data[categoryIdColumn] as String,
      userId: data[userIdColumn] as String,
    );
  }

  @override
  String toString() {
    return "CloudMerchant{name: $name, merchantId: $merchantId, categoryId: $categoryId, userId: $userId}";
  }

  Map<String, dynamic> toFirestore() {
    return {
      nameColumn: name,
      categoryIdColumn: categoryId,
      userIdColumn: userId,
    };
  }
}

const String nameColumn = "name";
const String merchantIdColumn = "merchantId";
const String categoryIdColumn = "categoryId";
const userIdColumn = "userId";
