import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:brokeo/frontend/login_pages/login_page3.dart';
class EditProfilePage extends ConsumerStatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  String? _selectedCountry = "India";
  String? _selectedGender = "Male";
  String? _selectedCurrency = "Indian Rupee";

  @override
  void initState() {
    super.initState();
    // Set default values
    _nameController.text = "Aujasvit Datta";
    _emailController.text = "aujasvit@dhichik.com";
    _phoneController.text = "+91 9870131789"; // Default phone number
    _addressController.text = "Hall X, IIT X";
    _budgetController.text = "500";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
        title: Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     colors: [Colors.white, Color(0xFFF3E5F5)],
        //     begin: Alignment.bottomCenter,
        //     end: Alignment.topCenter,
        //   ),
        // ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name Input

                SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                // Email Input

                SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "E-Mail",
                    border: OutlineInputBorder(),
                    enabled: false, // Visually indicate the field is read-only
                  ),
                  keyboardType: TextInputType.emailAddress,
                  readOnly: true, // Make the email field non-editable
                ),
                SizedBox(height: 16),

                // Phone Input

                SizedBox(height: 8),
                IntlPhoneField(
                  showCountryFlag: false,
                  initialCountryCode: 'IN',
                  initialValue: "9870131789", // Default phone number without country code
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    setState(() {
                      _phoneController.text = value.completeNumber.trim();
                    });
                  },
                  onSaved: (value) {
                    _phoneController.text = value?.completeNumber.trim() ?? '';
                  },
                  controller: null, // Remove the controller to avoid conflicts
                ),
                SizedBox(height: 16),

                // // Address Input
                // SizedBox(height: 8),
                // TextFormField(
                //   controller: _addressController,
                //   decoration: InputDecoration(
                //     labelText: "Address",
                //     border: OutlineInputBorder(),
                //   ),
                // ),
                // SizedBox(height: 16),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Validate fields
                        if (_nameController.text.trim().isEmpty ||
                            _phoneController.text.trim().isEmpty ||
                            _addressController.text.trim().isEmpty ||
                            _budgetController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please fill in all the fields."),
                            ),
                          );
                          return;
                        }

                        // Save logic
                        print("Name: ${_nameController.text}");
                        print("Email: ${_emailController.text}");
                        print("Phone: ${_phoneController.text}");
                        print("Address: ${_addressController.text}");
                        print("Budget: ${_budgetController.text}");
                        print("Country: $_selectedCountry");
                        print("Gender: $_selectedGender");
                        print("Currency: $_selectedCurrency");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: EdgeInsets.symmetric(
                            horizontal: 40.0, vertical: 12.0),
                      ),
                      child: Text(
                        "Save",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                      ),
                    ),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     // Cancel logic
                    //     Navigator.pop(context);
                    //   },
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor:
                    //         Theme.of(context).colorScheme.secondary,
                    //     padding: EdgeInsets.symmetric(
                    //         horizontal: 24.0, vertical: 12.0),
                    //   ),
                    //   child: Text(
                    //     "Cancel",
                    //     style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    //           fontWeight: FontWeight.bold,
                    //           color: Theme.of(context).colorScheme.onSecondary,
                    //         ),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
