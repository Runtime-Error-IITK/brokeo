import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart';
import 'package:brokeo/frontend/login_pages/auth_page.dart' show AuthPage;
import 'package:brokeo/frontend/login_pages/login_page2.dart' show LoginPage2;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart' show IntlPhoneField;
import 'package:intl_phone_field/phone_number.dart' show PhoneNumber;

class LoginPage1 extends ConsumerStatefulWidget {
  const LoginPage1({super.key});

  @override
  LoginPage1State createState() => LoginPage1State();
}

class LoginPage1State extends ConsumerState<LoginPage1> {
  // You can add your state variables and methods here

  PhoneNumber? phoneNumber;

  @override
  void initState() {
    super.initState();
    // Initialize any state variables or perform setup here
  }

  void _verifyPhone() async {
    final auth = ref.read(firebaseAuthProvider);

    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber.toString(),
      verificationCompleted: (PhoneAuthCredential credential) async {
        final userCredential = await auth.signInWithCredential(credential);

        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => AuthPage(),
            ),
          );
        } else {
          return;
        }
      },
      verificationFailed: (FirebaseAuthException error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Verification failed: ${error.message}")),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage2(
                verificationId: verificationId, phoneNumber: phoneNumber!),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage2(
                verificationId: verificationId, phoneNumber: phoneNumber!),
          ),
        );
      },
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
                  onPressed: _verifyPhone,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
