import 'dart:developer' show log;

import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart'
    show firebaseAuthProvider, userMetadataStreamProvider;
import 'package:brokeo/backend/services/providers/write_providers/user_metadata_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:brokeo/frontend/login_pages/login_page3.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  final String name, phone;
  const EditProfilePage({
    super.key,
    required this.name,
    required this.phone,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for name and email remain
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Controller for phone is no longer used with IntlPhoneField;
  // we use a state variable for the complete phone number.
  final TextEditingController _phoneController = TextEditingController();

  // State variable to hold the complete phone number.
  String _completePhoneNumber = "";

  @override
  void initState() {
    super.initState();

    // Set initial values using the widget properties.
    _nameController.text = widget.name;
    _emailController.text =
        ref.read(firebaseAuthProvider).currentUser?.email ?? "";
    _phoneController.text = widget.phone;

    // Call the asynchronous initialization method.
    _initializeUserMetadata();
  }

  Future<void> _initializeUserMetadata() async {
    try {
      // Reads the first value from the userMetadataStreamProvider.
      final userMetadata = await ref.read(userMetadataStreamProvider.future);

      // Update controllers with the retrieved metadata if available.
      _nameController.text = userMetadata['name'] ?? widget.name;
      _phoneController.text = userMetadata['phone'] ?? widget.phone;

      // Trigger a rebuild, if necessary.
      if (mounted) setState(() {});
    } catch (error) {
      debugPrint('Error loading user metadata: $error');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the async provider to update the UI as metadata state changes.
    final asyncMetadata = ref.watch(userMetadataStreamProvider);

    return asyncMetadata.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        // Display error using a SnackBar after the build is complete.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Edit Profile Error: $error")),
          );
        });
        return const SizedBox.shrink();
      },
      data: (metadata) {
        // Extract phone details to set IntlPhoneField initial values.
        String phoneFromMetadata = metadata['phone'] ?? "";
        String displayCountryCode = "IN";
        String displayPhoneNumber = phoneFromMetadata;

        if (phoneFromMetadata.isNotEmpty &&
            phoneFromMetadata.startsWith('+') &&
            phoneFromMetadata.length > 3) {
          log(phoneFromMetadata);
          String dialCode = phoneFromMetadata.substring(0, 3); // e.g., "+91"
          if (dialCode == "+91") {
            displayCountryCode = "IN";
          } else {
            // Optionally add mapping for other dial codes.
            displayCountryCode = dialCode;
          }
          displayPhoneNumber = phoneFromMetadata.substring(3).trim();
        }
        // displayPhoneNumber = "9278949220";

        // Combine the country code and phone for the complete phone number.
        _completePhoneNumber = displayCountryCode == "IN"
            ? "+91" + displayPhoneNumber
            : displayCountryCode + displayPhoneNumber;

        log(displayCountryCode);
        log(displayPhoneNumber);

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
                    // Name input with validation.
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
                    // Email input (disabled).
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
                    // Phone number input using IntlPhoneField.
                    SizedBox(height: 8),
                    IntlPhoneField(
                      enabled: false,
                      showCountryFlag: false,
                      initialCountryCode: displayCountryCode,
                      initialValue: displayPhoneNumber,
                      decoration: InputDecoration(
                        labelText: "Phone Number",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      // Update our complete phone number state variable.
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
                    // Save button.
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
                              newMetadata['phone'] =
                                  _completePhoneNumber.trim();

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
