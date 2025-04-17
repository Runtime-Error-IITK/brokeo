import 'dart:developer' show log;

import 'package:brokeo/backend/models/category.dart' show Category, CloudCategory;
import 'package:brokeo/backend/services/providers/read_providers/category_stream_provider.dart';
import 'package:brokeo/backend/services/providers/write_providers/category_service.dart';
import 'package:brokeo/backend/services/providers/write_providers/user_metadata_service.dart';
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
  final TextEditingController _phoneController = TextEditingController();

  PhoneNumber? phoneNumber;

  bool _isNameValid = true;
  bool _isPhoneValid = true;
  bool _isBudgetValid = true;
  bool _isProcessing = false; // <-- added

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hintText, bool isValid) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: isValid ? Colors.grey : Colors.red, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: isValid ? Colors.grey : Colors.red, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: isValid ? Colors.blue : Colors.red, width: 2),
      ),
    );
  }

  Future<void> _validateAndProceed() async {
    setState(() {
      _isNameValid = _nameController.text.isNotEmpty;
      _isPhoneValid = phoneNumber != null && phoneNumber!.number.trim().isNotEmpty;
      _isBudgetValid = _budgetController.text.isNotEmpty;
    });

    if (!(_isNameValid && _isPhoneValid && _isBudgetValid)) return;

    // lock button and show loader
    setState(() => _isProcessing = true);

    try {
      // Save metadata
      Map<String, dynamic> metadata = {
        'name': _nameController.text,
        'phone': phoneNumber!.completeNumber,
        'budget': double.parse(_budgetController.text),
      };
      await ref.read(userMetadataServiceProvider)
           ?.insertUserMetadata(metadata: metadata);

      // Update default "Others" category
      final filter = CategoryFilter(categoryName: "Others");
      final categories = await ref.read(categoryStreamProvider(filter).future);
      if (categories.isNotEmpty) {
        final oldCat = categories.first;
        final newCat = Category(
          name: oldCat.name,
          budget: double.parse(_budgetController.text),
          categoryId: oldCat.categoryId,
          userId: oldCat.userId,
        );
        await ref.read(categoryServiceProvider)?.updateCloudCategory(
            CloudCategory.fromCategory(newCat));
      }

      // Navigate away
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainScreen()),
        );
      }
    } catch (e) {
      // handle any error and re-enable the button
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
        setState(() => _isProcessing = false);
      }
    }
  }

  void _resetFields() {
    setState(() {
      _nameController.clear();
      _budgetController.clear();
      _phoneController.clear();
      phoneNumber = null;
      _isNameValid = true;
      _isPhoneValid = true;
      _isBudgetValid = true;
    });
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
          child: SingleChildScrollView(
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

                // Name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextFormField(
                    controller: _nameController,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    decoration: _inputDecoration("Name", _isNameValid),
                  ),
                ),
                const SizedBox(height: 25),

                // Phone
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: IntlPhoneField(
                    controller: _phoneController,
                    showCountryFlag: false,
                    initialCountryCode: 'IN',
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      hintText: 'Enter Phone Number',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: _isPhoneValid ? Colors.grey : Colors.red, width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: _isPhoneValid ? Colors.grey : Colors.red, width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: _isPhoneValid ? Colors.blue : Colors.red, width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    dropdownTextStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    onChanged: (num) => setState(() => phoneNumber = num),
                  ),
                ),
                const SizedBox(height: 20),

                // Budget
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextFormField(
                    controller: _budgetController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    decoration: _inputDecoration("Budget", _isBudgetValid),
                  ),
                ),
                const SizedBox(height: 20),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Cancel
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
                        child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                      ),
                    ),

                    // Confirm / Loader
                    SizedBox(
                      width: 150,
                      height: 50,
                      child: _isProcessing
                          ? Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _validateAndProceed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF65558F),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text("Confirm", style: TextStyle(color: Colors.white)),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
