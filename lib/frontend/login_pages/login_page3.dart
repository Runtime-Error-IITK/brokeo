import 'dart:developer' show log;

import 'package:brokeo/backend/models/category.dart'
    show Category, CloudCategory;
import 'package:brokeo/backend/services/providers/read_providers/category_stream_provider.dart';
import 'package:brokeo/backend/services/providers/write_providers/category_service.dart';
import 'package:brokeo/backend/services/providers/write_providers/user_metadata_service.dart';
import 'package:brokeo/frontend/home_pages/home_page.dart' show HomePage;
import 'package:brokeo/frontend/home_pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

class LoginPage3 extends ConsumerStatefulWidget {
  const LoginPage3({super.key});

  @override
  LoginPage3State createState() => LoginPage3State();
}

class LoginPage3State extends ConsumerState<LoginPage3> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  PhoneNumber? phoneNumber;

  bool _isNameValid = true;
  bool _isPhoneValid = true;
  bool _isBudgetValid = true;

  void _validateAndProceed() async {
    setState(() {
      _isNameValid = _nameController.text.isNotEmpty;
      _isPhoneValid =
          phoneNumber != null && phoneNumber!.number.trim().isNotEmpty;
      _isBudgetValid = _budgetController.text.isNotEmpty;
    });

    if (_isNameValid && _isPhoneValid && _isBudgetValid) {
      Map<String, dynamic> metadata = {
        'name': _nameController.text,
        'phone': phoneNumber!.completeNumber,
        'budget': double.parse(_budgetController.text),
      };
      ref
          .read(userMetadataServiceProvider)
          ?.insertUserMetadata(metadata: metadata);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(),
        ),
      );

      final categoryFilter = CategoryFilter(categoryName: "Others");
      final categoryService = ref.read(categoryServiceProvider);
      final category =
          await ref.read(categoryStreamProvider(categoryFilter).future);
      log("im here");
      log(category.toString());
      if (category.isNotEmpty) {
        final oldCategory = category[0];
        final newCategory = Category(
          name: oldCategory.name,
          budget: double.parse(_budgetController.text),
          categoryId: oldCategory.categoryId,
          userId: oldCategory.userId,
        );
        categoryService
            ?.updateCloudCategory(CloudCategory.fromCategory(newCategory));
      }
    }
  }

  void _resetFields() {
    setState(() {
      _nameController.clear();
      _budgetController.clear();
      phoneNumber = null;
      _isNameValid = true;
      _isPhoneValid = true;
      _isBudgetValid = true;
    });
  }

  InputDecoration _inputDecoration(String hintText, bool isValid) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
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
              colors: const [Color(0xFFB443B6), Colors.white],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Get Started!',
                style: GoogleFonts.pacifico(
                  color: const Color(0xFF1C1B14),
                  fontSize: 40,
                  fontWeight: FontWeight.w400,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 4),
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.25),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              // Name Input
              // Name Input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  height: 60, // fixed height for consistency
                  child: TextFormField(
                    controller: _nameController,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.6),
                    ),
                    decoration: _inputDecoration("Name", _isNameValid),
                  ),
                ),
              ),
              const SizedBox(height: 25),
// Phone Number Input with default country code +91
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  height: 90, // same fixed height as the name field
                  child: IntlPhoneField(
                    showCountryFlag: false,
                    initialCountryCode: 'IN',
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16), // adjusted to match others
                      hintText: 'Enter Phone Number',
                      hintStyle: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: _isPhoneValid ? Colors.grey : Colors.red,
                            width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: _isPhoneValid ? Colors.grey : Colors.red,
                            width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: _isPhoneValid ? Colors.blue : Colors.red,
                            width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    textAlignVertical: TextAlignVertical(
                        y: 0.4), // Ensures text is vertically centered
                    textInputAction: TextInputAction.done,
                    style: TextStyle(
                      fontSize: 18, // Ensuring same size for prefix & number
                      fontWeight: FontWeight.w500,
                    ),
                    dropdownTextStyle: TextStyle(
                      fontSize: 18, // Same size for prefix
                      fontWeight: FontWeight.w500,
                    ),
                    onChanged: (PhoneNumber number) {
                      setState(() {
                        phoneNumber = number;
                      });
                    },
                  ),
                ),
              ),
// Budget Input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  height: 60, // same fixed height as the other fields
                  child: TextFormField(
                    controller: _budgetController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.6),
                    ),
                    decoration: _inputDecoration("Budget", _isBudgetValid),
                  ),
                ),
              ),

              const SizedBox(height: 20),
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
                        backgroundColor: const Color(0xFF65558F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text("Cancel",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  // Confirm Button
                  SizedBox(
                    width: 150,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _validateAndProceed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF65558F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text("Confirm",
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
