import 'package:flutter/material.dart';
import 'package:brokeo/frontend/home_pages/home_page.dart' as brokeo_home;
import 'package:brokeo/frontend/transactions_pages/categories_page.dart';
import 'package:brokeo/frontend/split_pages/choose_transactions.dart';

class SplitBetweenPage extends StatefulWidget {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                final showHeader = index == 0 || 
                    contacts[index - 1][0] != firstLetter;
                
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
                      onTap: () {
                        // Handle contact selection
                        // Navigator.push(context, MaterialPageRoute(
                        //   builder: (context) => SplitWithContactPage(contact: contact),
                        // ));
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 3
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChooseTransactionPage()),
                );
              },
              child: const Icon(Icons.add, color: Colors.white),
              backgroundColor: const Color.fromARGB(255, 97, 53, 186),
              shape: const CircleBorder(),
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
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Transactions"),
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
