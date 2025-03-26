import 'package:flutter/material.dart';
import 'package:brokeo/frontend/home_pages/home_page.dart' as brokeo_home;
import 'package:brokeo/frontend/transactions_pages/categories_page.dart';
import 'package:brokeo/frontend/split_pages/choose_split_type.dart';

// Ensure that the ChooseTransactionsPage class is defined in the imported file
// or define it below if it is missing.
class SplitBetweenPage extends StatefulWidget {
  final Map<String, dynamic> transaction;

  const SplitBetweenPage({Key? key, required this.transaction}) : super(key: key);

  @override
  _SplitBetweenPageState createState() => _SplitBetweenPageState();
}

class _SplitBetweenPageState extends State<SplitBetweenPage> {
  int _currentIndex = 3;
  List<String> contacts = [
    "Abeer Singh",
    "Abel George",
    "Alan Abraham",
    "Amar Guniyal",
    "Anant Kumar",
    "Ansh Yadav",
    "Aryan Singh",
    "Ash Ketchum",
    "Astitva Verma",
    "Aujasvit Datta",
  ];
  TextEditingController _searchController = TextEditingController();
  Map<String, bool> selectedContacts = {};

  @override
  void initState() {
    super.initState();
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
                      Text(
                        widget.transaction["name"],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '₹${widget.transaction["amount"]}',
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
                setState(() {});
              },
            ),
          ),

          // Contacts List
          Expanded(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                final firstLetter = contact[0];

                // Show letter header if it's the first contact with this letter
                final showHeader =
                    index == 0 || contacts[index - 1][0] != firstLetter;

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChooseSplitTypePage(
                        transaction: widget.transaction,
                        selectedContacts: selectedContacts.entries
                            .where((entry) => entry.value)
                            .map((entry) => entry.key)
                            .toList(),
                      ),
                    ),
                  );
                },
                backgroundColor: const Color.fromARGB(
                  255, 97, 53, 186),
                elevation: 4,
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
              ),
            )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) {
            setState(() {
              _currentIndex = index;
            });
          }
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    brokeo_home.HomePage(name: "Darshan", budget: 5000),
              ),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CategoriesPage(),
              ),
            );
          } else if (index == 2) {
            // TODO: Analytics page
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        iconSize: 24,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.list), label: "Transactions"),
          BottomNavigationBarItem(
              icon: Icon(Icons.analytics), label: "Analytics"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Split"),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
