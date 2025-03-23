import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
@override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool _notificationsEnabled = true; // State variable for notifications
  String _selectedTheme = "Light"; // State variable for theme selection

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
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField("Full Name", "Aujasvit Datta"),
              _buildTextField("E-Mail", "aujasvit@dhichik.com"),
              _buildTextField("Phone Number", "123-456-7890"),
              _buildTextField("Country", "United States"),
              _buildTextField("Gender", "Male"),
              _buildTextField("Address", "Hall X, IIT X"),
              _buildTextField("Currency", "Indian Rupee"),
              _buildTextField("Budget", "₹500"),
SizedBox(height: 20),

            

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // TODO: Save profile changes
                },
                child: Text(
"Submit",
                  style: TextStyle(color: Colors.white), // Set text color to white
),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String placeholder) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          hintText: placeholder,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}