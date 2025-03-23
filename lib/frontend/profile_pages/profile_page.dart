import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:brokeo/frontend/profile_pages/edit_profile_page.dart';
import 'package:brokeo/frontend/profile_pages/faqs_page.dart';
import 'package:brokeo/frontend/profile_pages/privacy_policy_page.dart';
import 'package:brokeo/frontend/profile_pages/budget_page.dart';
import 'package:brokeo/main.dart'; // Import ThemeNotifier

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool _notificationsEnabled = true; // State variable for notifications
    // String _selectedTheme = "Light"; 
    final themeNotifier = Provider.of<ThemeNotifier>(context); // Access ThemeNotifier
    bool isDarkMode = themeNotifier.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
        title: Text(
          "Profile",
          style: Theme.of(context).appBarTheme.titleTextStyle,
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
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Icon(Icons.person, size: 50, color: Theme.of(context).primaryColor),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Aujasvit Datta",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "aujasvit@chitchi.com | +91 9870131789",
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Profile Options
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Edit Profile Option
                  ListTile(
                    leading: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                    title: Text(
                      "Edit profile information",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditProfilePage()),
                      );
                    },
                  ),

                  // Notifications Toggle
                  ListTile(
                    leading: Icon(Icons.notifications, color: Theme.of(context).primaryColor),
                    title: Text(
                      "Notifications",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {
                        // TODO: Notify backend team to configure notifications
                      },
                      activeColor: Theme.of(context).primaryColor,
                    ),
                  ),

                  // Language Selector
                  ListTile(
                    leading: Icon(Icons.language, color: Theme.of(context).primaryColor),
                    title: Text(
                      "Language",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    trailing: DropdownButton<String>(
                      value: "English", // Default language
                      items: [
                        DropdownMenuItem(
                          value: "English",
                          child: Text("English"),
                        ),
                        DropdownMenuItem(
                          value: "Hindi",
                          child: Text("हिंदी"),
                        ),
                      ],
                      onChanged: (value) {
                        // TODO: Handle language change
                      },
                    ),
                  ),
                  Divider(),
                  // Permissions Section
                  ListTile(
                    leading: Icon(Icons.lock, color: Theme.of(context).primaryColor),
                    title: Text(
                      "Permissions",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Navigate to permissions page
                    },
                  ),

                  // Theme Selector
                  ListTile(
                    leading: Icon(Icons.brightness_6, color: Theme.of(context).primaryColor),
                    title: Text(
                      "Theme",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    trailing: DropdownButton<String>(
                      value: isDarkMode ? "Dark" : "Light",
                      items: [
                        DropdownMenuItem(
                          value: "Light",
                          child: Text("Light"),
                        ),
                        DropdownMenuItem(
                          value: "Dark",
                          child: Text("Dark"),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == "Light") {
                          themeNotifier.toggleTheme(); // Switch to light mode
                        } else if (value == "Dark") {
                          themeNotifier.toggleTheme(); // Switch to dark mode
                        }
                      },
                    ),
                  ),

                  Divider(),

                  // Help & Support
                  ListTile(
                    leading: Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
                    title: Text(
                      "Help & Support",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FAQsPage()),
                      );
                    },
                  ),

                  // Contact Us
                  ListTile(
                    leading: Icon(Icons.contact_mail, color: Theme.of(context).primaryColor),
                    title: Text(
                      "Contact us",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Contact Us"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Email: ",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Expanded(
                                      child: Text(
                                        "support@brokeo.com",
                                        style: TextStyle(color: Colors.black54),
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
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Expanded(
                                      child: Text(
                                        "+91 9876543210",
                                        style: TextStyle(color: Colors.black54),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
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
                    },
                  ),

                  // Privacy Policy
                  ListTile(
                    leading: Icon(Icons.privacy_tip, color: Theme.of(context).primaryColor),
                    title: Text(
                      "Privacy policy",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
                      );
                    },
                  ),
                  Divider(),
                  _buildProfileOption(
                    context,
                    icon: Icons.account_balance_wallet,
                    title: "Budget",
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BudgetPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(BuildContext context,
      {required IconData icon,
      required String title,
      required Widget trailing,
      VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}