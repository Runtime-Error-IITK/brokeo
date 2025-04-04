import 'package:brokeo/frontend/analytics_pages/analytics_page.dart'
    show AnalyticsPage;
import 'package:brokeo/frontend/home_pages/home_page.dart' show HomePage;
import 'package:brokeo/frontend/split_pages/manage_splits.dart'
    show ManageSplitsPage;
import 'package:brokeo/frontend/transactions_pages/categories_page.dart'
    show CategoriesPage;
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Define your pages here. They can be your HomePage, CategoriesPage, etc.
  final List<Widget> _pages = [
    HomePage(),
    CategoriesPage(),
    AnalyticsPage(),
    ManageSplitsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The IndexedStack displays only the child at the _currentIndex.
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // Simply update the index; this doesn't rebuild the entire widget tree.
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        items: const [
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
}
