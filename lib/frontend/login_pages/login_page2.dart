import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart'
    show firebaseAuthProvider;
import 'package:brokeo/frontend/login_pages/auth_page.dart' show AuthPage;
import 'package:firebase_auth/firebase_auth.dart' show PhoneAuthProvider;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl_phone_field/phone_number.dart' show PhoneNumber;

class LoginPage2 extends ConsumerStatefulWidget {
  final String verificationId;
  final PhoneNumber phoneNumber;

  const LoginPage2(
      {super.key, required this.phoneNumber, required this.verificationId});

  @override
  LoginPage2State createState() => LoginPage2State();
}

class LoginPage2State extends ConsumerState<LoginPage2> {
  TextEditingController otpController = TextEditingController();

  void _verifyOtp() async {
    final credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: otpController.text,
    );

    final firebaseAuthInstance = ref.read(firebaseAuthProvider);

    final userCredential =
        await firebaseAuthInstance.signInWithCredential(credential);

    // Navigate to a screen to collect metadata
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => AuthPage(),
        ),
      );
    } else {
      return;
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(width: 8), // Space between Prefix & Number
                      Text(
                        widget.phoneNumber.number, // The actual number
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
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
                    hintStyle: TextStyle(
                        color: Colors.black.withOpacity(0.6), fontSize: 18),
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
                  onPressed: _verifyOtp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
