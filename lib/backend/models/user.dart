import 'dart:convert';

class User {
  String name;
  String email;
  String phoneNumber;
  Map<String, double> budget;

  User({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.budget,
  });

  @override
  bool operator ==(covariant Object other) {
    if (identical(this, other)) return true;

    return other is User && other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode {
    return phoneNumber.hashCode;
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
