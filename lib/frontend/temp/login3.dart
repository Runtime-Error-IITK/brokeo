import 'dart:developer' show log;

import 'package:brokeo/frontend/home_pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:currency_picker/currency_picker.dart';

class LoginPage3 extends StatefulWidget {
  @override
  _LoginPage3State createState() => _LoginPage3State();
}

class _LoginPage3State extends State<LoginPage3> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  String _selectedCurrency = 'INR'; // Default currency

  // Error states
  bool _isNameValid = true;
  bool _isEmailValid = true;
  bool _isBudgetValid = true;

  bool _isValidEmail(String email) {
    final RegExp emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  void _validateAndProceed() {
    setState(() {
      _isNameValid = _nameController.text.isNotEmpty;
      _isEmailValid = _emailController.text.isNotEmpty &&
          _isValidEmail(_emailController.text);
      _isBudgetValid = _budgetController.text.isNotEmpty;
    });

    if (_isNameValid && _isEmailValid && _isBudgetValid) {
      //TODO : Store all the data in the database
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            name: _nameController.text,
            budget: double.parse(_budgetController.text),
          ),
        ),
      );
    }
  }

  void _resetFields() {
    setState(() {
      _nameController.clear();
      _emailController.clear();
      _budgetController.clear();
      _selectedCurrency = 'INR';
      _isNameValid = true;
      _isEmailValid = true;
      _isBudgetValid = true;
    });
  }

  InputDecoration _inputDecoration(String hintText, bool isValid) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide:
            BorderSide(color: isValid ? Colors.grey : Colors.red, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide:
            BorderSide(color: isValid ? Colors.grey : Colors.red, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide:
            BorderSide(color: isValid ? Colors.blue : Colors.red, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color(0xFFB443B6), Colors.white],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Get Started!',
                style: GoogleFonts.pacifico(
                  color: Color(0xFF1C1B14),
                  fontSize: 40,
                  fontWeight: FontWeight.w400,
                  shadows: [
                    Shadow(
                        offset: Offset(0, 4),
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.25)),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Name Input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration("Name", _isNameValid),
                ),
              ),
              SizedBox(height: 15),

              // Email Input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration("E-Mail", _isEmailValid),
                ),
              ),
              SizedBox(height: 15),

              // Currency Selector using Currency Picker
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: InkWell(
                  onTap: () {
                    showCurrencyPicker(
                      context: context,
                      showFlag: true,
                      showSearchField: true,
                      onSelect: (Currency currency) {
                        setState(() {
                          _selectedCurrency = currency.code;
                        });
                      },
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey, width: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_selectedCurrency, style: TextStyle(fontSize: 16)),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),

              // Budget Input (Only Numbers)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextFormField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration("Budget", _isBudgetValid),
                ),
              ),
              SizedBox(height: 20),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Cancel Button
                  SizedBox(
                    width: 150,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _resetFields,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF65558F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child:
                          Text("Cancel", style: TextStyle(color: Colors.white)),
                    ),
                  ),

                  // Confirm Button
                  SizedBox(
                    width: 150,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _validateAndProceed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF65558F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text("Confirm",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
