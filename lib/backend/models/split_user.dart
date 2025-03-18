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

  factory SplitUser.fromJson(String json) {
    Map<String, dynamic> decodedJson = jsonDecode(json) as Map<String, dynamic>;
    return SplitUser(
      name: decodedJson[nameColumn] as String,
      phoneNumber: decodedJson[phoneNumberColumn] as String,
    );
  }

  String toJson() {
    //return json string

    return jsonEncode({
      nameColumn: name,
      phoneNumberColumn: phoneNumber,
    });
  }
}

String nameColumn = "name";
String phoneNumberColumn = "phoneNumber";
