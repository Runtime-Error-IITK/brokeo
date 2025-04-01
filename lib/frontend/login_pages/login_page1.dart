import 'dart:developer';

import 'package:brokeo/frontend/login_pages/login_page2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

class LoginPage1 extends StatefulWidget {
  @override
  _LoginPage1State createState() => _LoginPage1State();
}

class _LoginPage1State extends State<LoginPage1> {
  PhoneNumber? phoneNumber;

  void validateAndProceed() {
    try {
      if (phoneNumber != null && phoneNumber!.isValidNumber()) {
        print("✅ Valid Number: ${phoneNumber!.completeNumber}");

        // TODO: Store number in database and send OTP to the that number

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage2(phoneNumber: phoneNumber!),
          ),
        );
      } else {
        log("Invalid Number. Action not allowed.");
      }
    } catch (e) {
      log("Exception: ${e.toString()}");
    }
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
                'Hello!',
                style: GoogleFonts.pacifico(
                  color: Color(0xFF1C1B14),
                  fontSize: 50,
                  fontWeight: FontWeight.w400,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 4),
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.25),
                    )
                  ],
                ),
              ),

              SizedBox(height: 40),

              // Phone Number Input with Proper Vertical Alignment
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: IntlPhoneField(
                  showCountryFlag: false,
                  initialCountryCode: 'IN',
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 20, horizontal: 16), // Adjusted padding
                    hintText: 'Enter Contact Number',
                    hintStyle: TextStyle(
                      color: Colors.black.withOpacity(0.6),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2),
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
                  onChanged: (PhoneNumber phone) {
                    phoneNumber = phone;
                  },
                ),
              ),

              SizedBox(height: 20),

              // Arrow Button
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF65558F),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  iconSize: 35,
                  icon: Icon(Icons.arrow_forward, color: Colors.white),
                  onPressed: validateAndProceed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
