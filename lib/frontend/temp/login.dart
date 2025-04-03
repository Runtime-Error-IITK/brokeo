// import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';

// class PhoneAuthScreen extends ConsumerStatefulWidget {
//   const PhoneAuthScreen({Key? key}) : super(key: key);

//   @override
//   ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
// }

// class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
//   final TextEditingController _phoneController = TextEditingController();

//   void _verifyPhone() async {
//     // Retrieve the FirebaseAuth instance from the provider.
//     final auth = ref.read(firebaseAuthProvider);

//     await auth.verifyPhoneNumber(
//       phoneNumber: _phoneController.text,
//       timeout: const Duration(seconds: 60),

//       // Auto-verification callback:
//       verificationCompleted: (PhoneAuthCredential credential) async {
//         await auth.signInWithCredential(credential);
//       },

//       // Error callback:
//       verificationFailed: (FirebaseAuthException error) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Verification failed: ${error.message}")),
//         );
//       },

//       // OTP code sent callback:
//       codeSent: (String verificationId, int? resendToken) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => OtpScreen(verificationId: verificationId),
//           ),
//         );
//       },

//       // Auto-retrieval timeout callback:
//       codeAutoRetrievalTimeout: (String verificationId) {
//         // Optional: Handle auto-retrieval timeout.
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Phone Authentication")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _phoneController,
//               decoration: const InputDecoration(
//                 labelText: "Phone Number",
//                 hintText: "+1234567890",
//               ),
//               keyboardType: TextInputType.phone,
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _verifyPhone,
//               child: const Text("Verify Phone"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class OtpScreen extends StatelessWidget {
//   final String verificationId;
//   const OtpScreen({Key? key, required this.verificationId}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Replace this with your actual OTP input UI.
//     return Scaffold(
//       appBar: AppBar(title: const Text("Enter OTP")),
//       body: Center(
//         child: Text("OTP sent. VerificationId: $verificationId"),
//       ),
//     );
//   }
// }
