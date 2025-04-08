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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

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
        _phoneController.text = metadata['phone'] ?? "";

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
                      enabled:
                          false, // Disables editing and greys out the field
                    ),
                    SizedBox(height: 16),
                    // Phone Number Input using IntlPhoneField
                    SizedBox(height: 8),
                    IntlPhoneField(
                      showCountryFlag: false,
                      initialCountryCode: 'IN',
                      initialValue: "9870131789",
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
                      // Remove the controller to avoid conflicts with the onChanged handler
                      controller: null,
                    ),
                    SizedBox(height: 16),
                    // Save Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            // Validate the form
                            if (_formKey.currentState!.validate()) {
                              final newMetadata = metadata;
                              newMetadata['name'] = _nameController.text.trim();
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
                                        Text("Error updating user metadata"),
                                  ),
                                );
                              }
                            } else {
                              // If validation fails, notify the user
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
