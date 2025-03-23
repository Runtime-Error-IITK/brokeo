import 'package:flutter/material.dart';
import 'package:brokeo/frontend/profile_pages/edit_profile_page.dart';
import 'package:brokeo/frontend/profile_pages/faqs_page.dart'; // Import FAQsPage
import 'package:brokeo/frontend/profile_pages/privacy_policy_page.dart'; // Import PrivacyPolicyPage
import 'package:brokeo/frontend/profile_pages/budget_page.dart'; // Import BudgetPage

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool _notificationsEnabled = true; // State variable for notifications

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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                    child: Icon(Icons.person, size: 50, color: Colors.purple),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Aujasvit Datta",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "aujasvit@dhichik.com | +91 9870131789",
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
                  MaterialPageRoute(builder: (context) => EditProfilePage()),
                );
              },
            ),

            // Budget Section
            ListTile(
              leading: Icon(Icons.account_balance_wallet, color: Colors.purple),
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

            // Notifications Toggle
            ListTile(
              leading: Icon(Icons.notifications, color: Colors.purple),
              title: Text(
                "Notifications",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  // TODO: Notify backend team to configure notifications
                },
                activeColor: Colors.purple,
              ),
            ),

            // Permissions Section
            ListTile(
              leading: Icon(Icons.lock, color: Colors.purple),
              title: Text(
                "Permissions",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: Navigate to permissions page
              },
            ),

            Divider(),

            // Help & Support
            ListTile(
              leading: Icon(Icons.help_outline, color: Colors.purple),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
                );
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
                _showAboutDialog(context, "About Us");
              },
            ),
          ],
        ),
      ),
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
                      "support@brokeo.com",
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
                      "+91 9876543210",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
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
  }
  void _showAboutDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "We are Brokeo, a team of developers who are passionate about helping you manage your finances. Our goal is to provide you with tools and insights to make better financial decisions.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Made for:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "The CS253 course project at IIT Kanpur. This project is a demonstration of our commitment to creating impactful and user-friendly applications.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
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