import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:brokeo/frontend/home_pages/home_page.dart' as brokeo_home;
import 'package:brokeo/frontend/transactions_pages/categories_page.dart';
import 'package:brokeo/frontend/split_pages/choose_split_type.dart';
import 'package:brokeo/frontend/analytics_pages/analytics_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

// Ensure that the ChooseTransactionsPage class is defined in the imported file
// or define it below if it is missing.
class SplitBetweenPage extends ConsumerStatefulWidget {
  final double amount;
  final String description;
  const SplitBetweenPage(
      {super.key, required this.amount, required this.description});

  @override
  _SplitBetweenPageState createState() => _SplitBetweenPageState();
}

class _SplitBetweenPageState extends ConsumerState<SplitBetweenPage> {
  int _currentIndex = 3;

  Future<void> _fetchContacts(BuildContext context) async {
    log("Requesting permission to access contacts...");
    final status = await Permission.contacts.request();
    if (status.isGranted) {
      log("Permission granted. Fetching contacts...");
      try {
        const platform = MethodChannel('com.example.contacts/fetch');
        final List<dynamic> contactDetails =
            await platform.invokeMethod('getContacts');
        log("Contacts fetched successfully: ${contactDetails.length} contacts found.");

        // Extract only the names from the contact details, handling null or missing names
        setState(() {
          contacts = contactDetails
              // .where((contact) => contact is Map && contact.containsKey('name') && contact['name'] != null) // Ensure 'name' exists and is not null
              .map((contact) =>
                  contact['name'] as String? ??
                  "Unknown") // Default to "Unknown" if name is null
              .toList();
        });
      } on PlatformException catch (e) {
        log("Failed to fetch contacts: ${e.message}");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to fetch contacts: ${e.message}")),
          );
        }
      }
    } else {
      log("Permission denied.");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Contacts permission denied")),
        );
      }
    }
  }

  List<String> contacts = []; // Updated to dynamically fetch contact names
  TextEditingController _searchController = TextEditingController();
  Map<String, bool> selectedContacts = {};

  @override
  void initState() {
    super.initState();
    _fetchContacts(context); // Fetch contacts when the page is initialized
    // Initialize all contacts as not selected
    for (var contact in contacts) {
      selectedContacts[contact] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate if any contacts are selected
    bool hasSelectedContacts =
        selectedContacts.values.any((isSelected) => isSelected);

    // Add filtering logic based on search text
    final filteredContacts = _searchController.text.isEmpty
        ? contacts
        : contacts
            .where((contact) => contact
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Split Between'),
      ),
      body: Column(
        children: [
          // Transaction Details Card
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Splitting Transaction',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Text(
                      //   widget.transaction[
                      //       "transactionId"], // Provide a default value if name is null
                      //   style: TextStyle(
                      //     fontSize: 16,
                      //     fontWeight: FontWeight.w500,
                      //   ),
                      // ),
                      Text(
                        '₹${widget.amount}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Divider(),
                  SizedBox(height: 8),
                  Text(
                    'Select contacts to split with:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Contact',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12.0),
              ),
              onChanged: (value) {
                setState(() {}); // triggers rebuild with new filteredContacts
              },
            ),
          ),

          // Contacts List now uses filteredContacts instead of contacts.
          Expanded(
            child: ListView.builder(
              itemCount: filteredContacts.length,
              itemBuilder: (context, index) {
                final contact = filteredContacts[index];
                final firstLetter = contact[0];

                // Show letter header if it's the first contact with this letter
                final showHeader =
                    index == 0 || filteredContacts[index - 1][0] != firstLetter;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showHeader)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          firstLetter,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple[100],
                        child: Text(
                          firstLetter,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                      ),
                      title: Text(
                        contact,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      trailing: Checkbox(
                        value: selectedContacts[contact] ?? false,
                        onChanged: (bool? value) {
                          setState(() {
                            selectedContacts[contact] = value ?? false;
                          });
                        },
                        activeColor: Colors.purple,
                      ),
                      onTap: () {
                        setState(() {
                          selectedContacts[contact] =
                              !(selectedContacts[contact] ?? false);
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: hasSelectedContacts
          ? ScaleTransition(
              scale: CurvedAnimation(
                parent: ModalRoute.of(context)!.animation!,
                curve: Curves.elasticOut,
              ),
              child: FloatingActionButton(
                onPressed: () {
                  //redirect to choosesplitype page
                  // Navigator.push(
                  // context,
                  // MaterialPageRoute(
                  // builder: (context) => ChooseSplitTypePage(
                  //   transaction: widget.transaction,
                  //   selectedContacts: selectedContacts.entries
                  //       .where((entry) => entry.value)
                  //       .map((entry) => entry.key)
                  //       .toList(),
                  // ),
                  // ),
                  // );
                },
                backgroundColor: const Color.fromARGB(255, 97, 53, 186),
                elevation: 4,
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
