import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart';
import 'package:brokeo/frontend/login_pages/login_page1.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:brokeo/frontend/profile_pages/edit_profile_page.dart';
import 'package:brokeo/frontend/profile_pages/faqs_page.dart'; // Import FAQsPage
import 'package:brokeo/frontend/profile_pages/privacy_policy_page.dart'; // Import PrivacyPolicyPage
import 'package:brokeo/frontend/profile_pages/budget_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart'; // Import BudgetPage
import 'package:permission_handler/permission_handler.dart';

class ProfilePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool _notificationsEnabled = true; // State variable for notifications
    final asyncUsermetadata = ref.watch(userMetadataStreamProvider);
    return asyncUsermetadata.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Profile page Error: $error")),
          );
        });
        return const SizedBox.shrink();
      },
      data: (metadata) {
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
              "Profile",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture and Name
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.purple[100],
                        child:
                            Icon(Icons.person, size: 50, color: Colors.purple),
                      ),
                      SizedBox(height: 10),
                      Text(
                        metadata['name'] ?? "Unknown User",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "${ref.read(firebaseAuthProvider).currentUser?.email ?? "Unknown user"} | ${metadata['phone']}",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Edit Profile Option
                ListTile(
                  leading: Icon(Icons.edit, color: Colors.purple),
                  title: Text(
                    "Edit profile information",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditProfilePage()),
                    );
                  },
                ),

                // Budget Section
                ListTile(
                  leading:
                      Icon(Icons.account_balance_wallet, color: Colors.purple),
                  title: Text(
                    "Budget",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BudgetPage()),
                    );
                  },
                ),

                Divider(),

                // Permissions Section
                ListTile(
                  leading: Icon(Icons.lock, color: Colors.purple),
                  title: Text(
                    "Permissions",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    await openAppSettings();
                  },
                ),

                Divider(),

                // // Help & Support
                // ListTile(
                //   leading: Icon(Icons.help_outline, color: Colors.purple),
                //   title: Text(
                //     "Help & Support",
                //     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                //   ),
                //   trailing: Icon(Icons.arrow_forward_ios, size: 16),
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(builder: (context) => FAQsPage()),
                //     );
                //   },
                // ),

                // Contact Us
                ListTile(
                  leading: Icon(Icons.contact_mail, color: Colors.purple),
                  title: Text(
                    "Contact us",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showContactDialog(context, "Contact Us");
                  },
                ),

                // Privacy Policy
                ListTile(
                  leading: Icon(Icons.privacy_tip, color: Colors.purple),
                  title: Text(
                    "Privacy policy",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showPrivacyPolicyDialog(context);
                  },
                ),

                Divider(),

                // About Us Section
                ListTile(
                  leading: Icon(Icons.info, color: Colors.purple),
                  title: Text(
                    "About Us",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showContactDialog(context, "About Us");
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.info, color: Colors.purple),
                  title: Text(
                    "Logout",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  trailing: Icon(Icons.logout, size: 16),
                  onTap: () async {
                    try {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              LoginPage1(), // Replace with your login page
                        ),
                        (Route<dynamic> route) => false,
                      );
                    } on FirebaseAuthException catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error logging out: ${e.code}"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error logging out: $e"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to show the Contact Us or About Us dialog
  void _showContactDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title == "About Us") ...[
                Text(
                  "We are Runtime-Error, a passionate team of 10 individuals dedicated to improving financial management and delivering a seamless user experience.\n\n"
                  "If you have any questions or need assistance, feel free to reach out to us via the email or phone number provided on the Contact Us page.\n\n",
                  style: TextStyle(fontSize: 16),
                ),
              ] else ...[
                Row(
                  children: [
                    Text(
                      "Email: ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "shreyjsolanki@gmail.com",
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      "Phone: ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "+91 9574662607",
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  // Helper method to show the Privacy Policy dialog
  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text(
              "Privacy Policy",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: SingleChildScrollView(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Data We Collect\n",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextSpan(
                    text: "Phone Number—Required for login.\n"
                        "Transaction Data—Includes budgets, spending categories, and transactions.\n"
                        "SMS Data—Only accessed if you enable transaction tracking.\n",
                    style: TextStyle(fontSize: 16),
                  ),
                  TextSpan(
                    text: "How We Use Your Data\n",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextSpan(
                    text:
                        "To provide core features such as budgeting and analytics.\n"
                        "SMS data remains on your device and is not stored on our servers.\n",
                    style: TextStyle(fontSize: 16),
                  ),
                  TextSpan(
                    text: "Data Security\n",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextSpan(
                    text:
                        "Your data is securely stored in Firebase, Google’s cloud infrastructure.\n",
                    style: TextStyle(fontSize: 16),
                  ),
                  TextSpan(
                    text: "Your Control\n",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextSpan(
                    text:
                        "You can disable SMS access at any time through app settings.\n"
                        "Your data can be exported via the app when needed.",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
