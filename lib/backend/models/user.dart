import 'dart:convert';

class User {
  String name;
  String email;
  String phoneNumber;
  Map<String, dynamic> budget;

  User({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.budget,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.name == name &&
        other.email == email &&
        other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode {
    return name.hashCode ^ email.hashCode ^ phoneNumber.hashCode;
  }

  factory User.fromJson(String json) {
    Map<String, dynamic> decodedJson = jsonDecode(json) as Map<String, dynamic>;
    return User(
      name: decodedJson[nameColumn] as String,
      email: decodedJson[emailColumn] as String,
      phoneNumber: decodedJson[phoneNumberColumn] as String,
      budget: decodedJson[budgetColumn] as Map<String, dynamic>,
    );
  }

  String toJson() {
    //return json string

    return jsonEncode({
      nameColumn: name,
      emailColumn: email,
      phoneNumberColumn: phoneNumber,
      budgetColumn: budget,
    });
  }

  void updateMerchant(Map<String, dynamic> newMerchant) {
    name = newMerchant[nameColumn] ?? name;
    email = newMerchant[emailColumn] ?? email;
    phoneNumber = newMerchant[phoneNumberColumn] ?? phoneNumber;
    budget = newMerchant[budgetColumn] ?? budget;
  }

  void addEmail(String email) {
    //check email format
    //TODO: Add more robust error handling

    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email)) {
      throw Exception('Invalid email format');
    }

    this.email = email;
  }

  void setBudget(Map<String, dynamic> budget) {
    this.budget = budget;
  }
}

const String nameColumn = 'name';
const String emailColumn = 'email';
const String phoneNumberColumn = 'phoneNumber';
const String budgetColumn = 'budget';
