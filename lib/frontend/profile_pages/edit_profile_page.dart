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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set default values
    _nameController.text = "";
    _emailController.text =
        ref.read(firebaseAuthProvider).currentUser?.email ?? "";
    _phoneController.text = ""; // Default phone number
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
          _phoneController.text =
              metadata['phone'] ?? ""; // Default phone number

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
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),
            body: Container(
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
                          enabled:
                              false, // Visually indicate the field is read-only
                        ),
                        keyboardType: TextInputType.emailAddress,
                        readOnly: true, // Make the email field non-editable
                      ),
                      SizedBox(height: 16),

                      SizedBox(height: 8),
                      IntlPhoneField(
                        showCountryFlag: false,
                        initialCountryCode: 'IN',
                        initialValue:
                            "9870131789", // Default phone number without country code
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
                          _phoneController.text =
                              value?.completeNumber.trim() ?? '';
                        },
                        controller:
                            null, // Remove the controller to avoid conflicts
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
                            onPressed: () async {
                              // Validate fields
                              if (_nameController.text.trim().isNotEmpty &&
                                  _phoneController.text.trim().isNotEmpty) {
                                final newMetadata = metadata;
                                newMetadata['name'] =
                                    _nameController.text.trim();
                                newMetadata['phone'] =
                                    _phoneController.text.trim();

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
                                          Text("Error updating user metadata "),
                                    ),
                                  );
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text("Please fill in all the fields."),
                                  ),
                                );
                                return;
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
        });
  }
}
