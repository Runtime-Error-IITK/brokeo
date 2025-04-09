import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart'
    show firebaseAuthProvider, userMetadataStreamProvider;
import 'package:brokeo/backend/services/providers/write_providers/user_metadata_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:brokeo/frontend/login_pages/login_page3.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for name and email remain
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  // Remove assignment to phone controller in the phone field; we'll use a separate state variable.
  final TextEditingController _phoneController = TextEditingController();

  // State variable to hold the complete phone number
  String _completePhoneNumber = "";

  @override
  void initState() {
    super.initState();
    _nameController.text = "";
    // Initialize email controller with the current user's email
    _emailController.text =
        ref.read(firebaseAuthProvider).currentUser?.email ?? "";
    _phoneController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    final asyncMetadata = ref.watch(userMetadataStreamProvider);
    return asyncMetadata.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Edit Profile Error: $error")),
          );
        });
        return const SizedBox.shrink();
      },
      data: (metadata) {
        _nameController.text = metadata['name'] ?? "";
        // We don't assign _phoneController here because we are using IntlPhoneField to manage phone state

        // --- START: Phone Extraction Logic with Logging ---
        // Assume phone is non-empty and may be in the format "+919579332746".
        String phoneFromMetadata = metadata['phone'] ?? "";
        // Set default values.
        String displayCountryCode = "IN";
        String displayPhoneNumber = phoneFromMetadata;

        if (phoneFromMetadata.isNotEmpty &&
            phoneFromMetadata.startsWith('+') &&
            phoneFromMetadata.length > 3) {
          String dialCode = phoneFromMetadata.substring(0, 3); // e.g., "+91"
          if (dialCode == "+91") {
            displayCountryCode = "IN";
          } else {
            // If needed, add mapping for other dial codes
            displayCountryCode = dialCode;
          }
          displayPhoneNumber = phoneFromMetadata.substring(3).trim();
        }
        // Combine the country code and phone for the complete phone number.
        _completePhoneNumber = displayCountryCode == "IN"
            ? "+91" + displayPhoneNumber
            : displayCountryCode + displayPhoneNumber;
        // --- END: Phone Extraction Logic with Logging ---

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Edit Profile",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Input with validation
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Name cannot be empty";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    // Email Input (disabled and greyed out)
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "E-Mail",
                        border: OutlineInputBorder(),
                        fillColor: Colors.grey[200],
                        filled: false,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      enabled: false,
                    ),
                    SizedBox(height: 16),
                    // Phone Number Input using IntlPhoneField
                    SizedBox(height: 8),
                    IntlPhoneField(
                      showCountryFlag: false,
                      initialCountryCode: displayCountryCode, // Dynamically set
                      initialValue: displayPhoneNumber, // Dynamically set (without dial code)
                      decoration: InputDecoration(
                        labelText: "Phone Number",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      // Use callbacks to update our state variable instead of _phoneController
                      onChanged: (value) {
                        setState(() {
                          _completePhoneNumber = value.completeNumber.trim();
                          
                        });
                      },
                      onSaved: (value) {
                        _completePhoneNumber =
                            value?.completeNumber.trim() ?? "";
                       
                      },
                      controller: null,
                    ),
                    SizedBox(height: 16),
                    // Save Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // Trigger onSaved callback on all form fields.
                              _formKey.currentState!.save();

                              final newMetadata = metadata;
                              newMetadata['name'] = _nameController.text.trim();
                              // Update metadata with our _completePhoneNumber variable.
                              newMetadata['phone'] = _completePhoneNumber.trim();


                              final metadataService =
                                  ref.read(userMetadataServiceProvider);

                              if (metadataService != null) {
                                await metadataService.updateUserMetadata(
                                  metadata: newMetadata,
                                );
                                
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("User metadata updated"),
                                    ),
                                  );
                                }
                              } else {
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text("Error updating user metadata"),
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Please fill in all the fields."),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24.0, vertical: 12.0),
                          ),
                          child: Text(
                            "Save",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
