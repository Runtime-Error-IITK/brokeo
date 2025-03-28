import 'package:flutter/material.dart';
import 'package:brokeo/frontend/split_pages/split_between.dart';
import 'package:brokeo/frontend/home_pages/home_page.dart' as brokeo_home;
import 'package:brokeo/frontend/transactions_pages/categories_page.dart';
import 'package:brokeo/frontend/analytics_pages/analytics_page.dart';

class ChooseTransactionPage extends StatefulWidget {
  @override
  _ChooseTransactionPageState createState() => _ChooseTransactionPageState();
}

class _ChooseTransactionPageState extends State<ChooseTransactionPage> {
    int _currentIndex = 3;
  int? _selectedIndex;
  final List<Map<String, dynamic>> transactions = [
    {"name": "Aujasvit Datta", "amount": 123},
    {"name": "Darshan Sethia", "amount": 10},
    {"name": "Suryansh Verma", "amount": 1320},
    {"name": "Darshan Sethia", "amount": 123},
    {"name": "Bhavnoor", "amount": 123},
    {"name": "CC Canteen", "amount": 123},
    {"name": "Hall 10 Canteen", "amount": 431},
    {"name": "Domino's", "amount": 123},
    {"name": "Swiggy", "amount": 13},
    {"name": "Barbeque Nation", "amount": 134},
    {"name": "PVR Cinemas", "amount": 123},
    {"name": "Aujasvit Datta", "amount": 123},
  ];

  void _navigateToSplitBetweenPage() {
    if (_selectedIndex == null) return;

    final selectedTransaction = transactions[_selectedIndex!];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SplitBetweenPage(transaction: selectedTransaction),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose Transaction"),
        //backgroundColor: Colors.purple,
      ),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          final isSelected = _selectedIndex == index;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple[100],
              child: Text(
                transaction["name"][0],
                style: TextStyle(color: Colors.purple),
              ),
            ),
            title: Text(transaction["name"]),
            subtitle: Text("₹${transaction["amount"]}"),
            trailing: isSelected
                ? Icon(Icons.check_circle, color: Colors.green)
                : null,
            tileColor: isSelected ? Colors.purple[50] : null,
            onTap: () {
              setState(() {
                _selectedIndex = isSelected ? null : index;
              });
            },
          );
        },
      ),
      floatingActionButton: _selectedIndex != null
          ? FloatingActionButton(
              onPressed: _navigateToSplitBetweenPage,
              backgroundColor: const Color.fromARGB(
                  255, 97, 53, 186),
              child: Icon(Icons.arrow_forward, color: Colors.white),
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AnalyticsPage(),
              ),
            );
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
}

// // Example SplitBetweenPage (define this in your app)
// class SplitBetweenPage extends StatelessWidget {
//   final Map<String, dynamic> transaction;

//   const SplitBetweenPage({Key? key, required this.transaction}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Split Transaction"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text("Splitting: ${transaction["name"]}"),
//             Text("Amount: ₹${transaction["amount"]}"),
//           ],
//         ),
//       ),
//     );
//   }
// }
