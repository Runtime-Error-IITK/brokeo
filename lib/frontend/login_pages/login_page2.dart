import 'package:brokeo/frontend/login_pages/login_page3.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/phone_number.dart';

class LoginPage2 extends StatefulWidget {
  final PhoneNumber phoneNumber; 

  LoginPage2({required this.phoneNumber});

  @override
  _LoginPage2State createState() => _LoginPage2State();
}

class _LoginPage2State extends State<LoginPage2> {
  TextEditingController otpController = TextEditingController();

  void validateAndProceed() {
    if (otpController.text.isNotEmpty) {
      print("✅ Phone: ${widget.phoneNumber.completeNumber}");
      print("✅ OTP Entered: ${otpController.text}");

      // TODO: Implement OTP verification and check whether the otp is correct or not
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage3(),
        ),
      );

    } else {
      print("❌ OTP Required.");
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
              // "Hello!" Text
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

              // Displaying Phone Number Properly Aligned
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey, width: 2),
                  ),
                  child: Row(
                    children: [
                      Text(
                        widget.phoneNumber.countryCode, // Dynamic Prefix
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(width: 8), // Space between Prefix & Number
                      Text(
                        widget.phoneNumber.number, // The actual number
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // OTP Input Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Enter OTP',
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 18),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
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
