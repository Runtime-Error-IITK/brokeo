import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class SplitBetweenPage extends ConsumerStatefulWidget {
  final double amount;
  final String description;
  const SplitBetweenPage({
    super.key,
    required this.amount,
    required this.description,
  });

  @override
  _SplitBetweenPageState createState() => _SplitBetweenPageState();
}

class _SplitBetweenPageState extends ConsumerState<SplitBetweenPage> {
  int _currentIndex = 3;
  List<String> contacts = [];
  TextEditingController _searchController = TextEditingController();
  Map<String, bool> selectedContacts = {};

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

        setState(() {
          // Process contacts: remove duplicates, empty names, and sort
          contacts = contactDetails
              .map((contact) => contact['name'] as String? ?? "Unknown")
              .where((name) => name.isNotEmpty)
              .toSet() // Remove duplicates
              .toList()
                ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

          // Initialize selectedContacts with all current contacts
          for (var contact in contacts) {
            selectedContacts.putIfAbsent(contact, () => false);
          }
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

  @override
  void initState() {
    super.initState();
    _fetchContacts(context);
  }

  @override
  Widget build(BuildContext context) {
    bool hasSelectedContacts =
        selectedContacts.values.any((isSelected) => isSelected);
    final filteredContacts = _searchController.text.isEmpty
        ? contacts
        : contacts
            .where((contact) => contact
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(title: Text('Split Between')),
      body: Column(
        children: [
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
              onChanged: (value) => setState(() {}),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredContacts.length,
              itemBuilder: (context, index) {
                final contact = filteredContacts[index];
                final firstLetter = contact.isNotEmpty
                    ? contact[0].toUpperCase()
                    : '';
                bool showHeader = index == 0;
                if (!showHeader) {
                  final previousContact = filteredContacts[index - 1];
                  final previousFirstLetter = previousContact.isNotEmpty
                      ? previousContact[0].toUpperCase()
                      : '';
                  showHeader = firstLetter != previousFirstLetter;
                }

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
                        onChanged: (bool? value) => setState(() {
                          selectedContacts[contact] = value ?? false;
                        }),
                        activeColor: Colors.purple,
                      ),
                      onTap: () => setState(() {
                        selectedContacts[contact] = !(selectedContacts[contact] ?? false);
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: hasSelectedContacts
          ? FloatingActionButton(
              onPressed: () {
                // Navigate to ChooseSplitTypePage
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => ChooseSplitTypePage(
                //       amount: widget.amount,
                //       description: widget.description,
                //       selectedContacts: selectedContacts.entries
                //           .where((entry) => entry.value)
                //           .map((entry) => entry.key)
                //           .toList(),
                //     ),
                //   ),
                // );
              },
              backgroundColor: Color.fromARGB(255, 97, 53, 186),
              child: Icon(Icons.arrow_forward, color: Colors.white),
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