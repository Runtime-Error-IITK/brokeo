import 'dart:developer' show log;
import 'package:brokeo/frontend/split_pages/choose_split_type.dart';
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
  final int _currentIndex = 3;
  // List of contacts; each contact is represented as a Map with keys "name" and "phone".
  List<Map<String, String>> contacts = [];
  final TextEditingController _searchController = TextEditingController();
  // Instead of a Map<String, bool>, we now keep a Map where the key is the phone number
  // and the value is the full contact (which includes both name and phone).
  Map<String, Map<String, String>> selectedContacts = {};

  Future<void> _fetchContacts(BuildContext context) async {
    log("Requesting permission to access contacts...");
    final status = await Permission.contacts.request();
    if (status.isGranted) {
      log("Permission granted. Fetching contacts...");
      try {
        // This calls your platform method to fetch contacts.
        const platform = MethodChannel('com.example.contacts/fetch');
        final List<dynamic> contactDetails =
            await platform.invokeMethod('getContacts');
        log("Contacts fetched successfully: ${contactDetails.length} contacts found.");

        // Use a temporary map to remove duplicates (keyed by a unique field, e.g. phone number).
        final Map<String, Map<String, String>> tempMap = {};

        for (var contact in contactDetails) {
          // Extract the name and phone number from each contact.
          final String name = (contact['name'] as String?)?.trim() ?? "Unknown";
          final String phone =
              (contact['phone']! as String?)?.trim().replaceAll(' ', '') ?? "";
          if (name.isNotEmpty && phone.isNotEmpty) {
            tempMap[phone] = {"name": name, "phone": phone};
          }
        }

        // Convert the deduplicated map values to a list and sort it by name.
        List<Map<String, String>> contactList = tempMap.values.toList();
        contactList.sort((a, b) =>
            a["name"]!.toLowerCase().compareTo(b["name"]!.toLowerCase()));

        setState(() {
          contacts = contactList;
          // Initialize selectedContacts as empty.
          selectedContacts = {};
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
    // Filter contacts based on search query.
    final filteredContacts = _searchController.text.isEmpty
        ? contacts
        : contacts.where((contact) {
            return (contact["name"]?.toLowerCase() ?? "")
                .contains(_searchController.text.toLowerCase());
          }).toList();

    // Check if at least one contact is selected.
    bool hasSelectedContacts = selectedContacts.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Split Between')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Splitting Transaction',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween, // Removed this line
                    crossAxisAlignment: CrossAxisAlignment
                        .start, // Optional: Aligns text to the start
                    children: [
                      Text(
                        '₹${widget.amount}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.description,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Select contacts to split with:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
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
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredContacts.length,
              itemBuilder: (context, index) {
                final contact = filteredContacts[index];
                final name = contact["name"]!;
                final phone = contact["phone"]!;
                final firstLetter =
                    name.isNotEmpty ? name[0].toUpperCase() : '';
                // Decide whether to display an alphabetical header.
                bool showHeader = index == 0;
                if (!showHeader) {
                  final previousContact = filteredContacts[index - 1];
                  final previousFirstLetter =
                      (previousContact["name"] ?? "").isNotEmpty
                          ? previousContact["name"]![0].toUpperCase()
                          : '';
                  showHeader = firstLetter != previousFirstLetter;
                }
                // Check if this contact is selected by looking it up by phone.
                bool isSelected = selectedContacts.containsKey(phone);

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
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        phone,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: Checkbox(
                        value: isSelected,
                        onChanged: (bool? value) => setState(() {
                          if (value == true) {
                            selectedContacts[phone] = contact;
                          } else {
                            selectedContacts.remove(phone);
                          }
                        }),
                        activeColor: Colors.purple,
                      ),
                      onTap: () => setState(() {
                        if (isSelected) {
                          selectedContacts.remove(phone);
                        } else {
                          selectedContacts[phone] = contact;
                        }
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
                // Here you can pass the list of selected contacts (with both name and phone)
                // Example:
                final List<Map<String, String>> selected =
                    selectedContacts.values.toList();

                // for (var contact in selected) {
                //   contact['phone'] = contact['phone']!.replaceAll(' ', '');
                // }

                // log("Selected contacts: $selected");
                // Navigation logic...
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChooseSplitTypePage(
                              amount: widget.amount,
                              description: widget.description,
                              selectedContacts: selected,
                            )));
              },
              backgroundColor: const Color.fromARGB(255, 97, 53, 186),
              heroTag: 'split_between_next',
              child: const Icon(Icons.arrow_forward, color: Colors.white),
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
