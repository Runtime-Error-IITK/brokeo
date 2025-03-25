import 'package:brokeo/frontend/transactions_pages/categories_page.dart';
import 'package:flutter/material.dart';
import 'package:brokeo/frontend/split_pages/choose_transactions.dart';
import 'package:brokeo/frontend/home_pages/home_page.dart' as brokeo_split;


class ManageSplitsPage extends StatefulWidget {
  @override
  _ManageSplitsPageState createState() => _ManageSplitsPageState();
}

class _ManageSplitsPageState extends State<ManageSplitsPage> {
  int _currentIndex = 3;
  List<brokeo_split.Split> splits = []; // Now using Split model instead of raw data

  @override
  void initState() {
    super.initState();
    _loadSplits(); // Load data when widget initializes
  }

  Future<void> _loadSplits() async {
    // Simulated data - replace with your actual data fetching logic
    final mockData = [
      {"name": "Chetan Singh", "amount": 50.0, "isSettled": false},
      {"name": "Darshan", "amount": 510.0, "isSettled": false},
      {"name": "Chinmay Jain", "amount": 75.0, "isSettled": false},
      {"name": "Aryan Kumar", "amount": 25.0, "isSettled": false},
      {"name": "Suryansh Verma", "amount": 160.0, "isSettled": false},
      {"name": "Anjali Patra", "amount": 1200.0, "isSettled": false},
      {"name": "Rudransh Verma", "amount": 0.0, "isSettled": true},
      {"name": "Moni Sinha", "amount": 50.0, "isSettled": false},
      {"name": "Sanjina S", "amount": 1.0, "isSettled": false},
      {"name": "Prem Bhardwaj", "amount": 3180.0, "isSettled": false},
    ];

    // Convert raw data to Split objects


    setState(() {
      splits = mockData.map((item) => brokeo_split.Split.fromMap(item)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: [
// Balance Summary Card
Container(
  margin: const EdgeInsets.all(16.0),
  decoration: BoxDecoration(
    color: const Color(0xFFEDE7F6), // Your specified background color
    borderRadius: BorderRadius.circular(16.0),
  ),
  child: Padding(
    padding: const EdgeInsets.all(20.0),
    child: Column(
      children: [
        // Total Balance
        _buildBalanceRow(
          label: "Total Balance",
          amount: 1441,
          amountColor: Colors.green[700]!,
        ),
        const SizedBox(height: 16),
        
        // You Owe
        _buildBalanceRow(
          label: "You Owe",
          amount: 200,
          amountColor: Colors.red[700]!,
        ),
        const SizedBox(height: 16),
        
        // You Are Owed
        _buildBalanceRow(
          label: "You Are Owed",
          amount: 1641,
          amountColor: Colors.green[700]!,
        ),
      ],
    ),
  ),
),          // Dynamic ListView with dividers
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadSplits,
              child: ListView.separated(
                itemCount: splits.length,
                itemBuilder: (context, index) {
                  final split = splits[index];
                  return _buildSplitTile(split);
                },
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey[300],
                  height: 1,
                  indent: 72, // Matches avatar width
                ),
              ),
            ),
          ),
        ],
      ),
floatingActionButton: _currentIndex == 3 ? FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChooseTransactionPage()),
    );
  },
  child: const Icon(Icons.add, color: Colors.white),
  backgroundColor: const Color.fromARGB(255, 97, 53, 186), // Your exact purple color
  shape: const CircleBorder(),
) : null,
      
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

Widget _buildBalanceRow({
  required String label,
  required int amount,
  required Color amountColor,
}) {
  return Row(
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      const Spacer(),
      Text(
        "₹${amount.toString()}",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: amountColor,
        ),
      ),
    ],
  );
}
  Widget _buildSplitTile(brokeo_split.Split split) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.purple[100],
        child: Text(
          split.name[0],
          style: TextStyle(color: Colors.purple),
        ),
      ),
      title: Text(split.name),
      trailing: Text(
        "₹${split.amount}",
        style: TextStyle(
          color: split.amount < 0 ? Colors.red : Colors.green,
          //Issettled not defined in split class
          //fontWeight: split.isSettled ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        // Add tap handling if needed
      },
    );
  }

  Widget buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        if (index != _currentIndex) {
          setState(() {
            _currentIndex = index;
          });
        }
        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => brokeo_split.HomePage(name: "Darshan", budget: 5000),
            ),
          );
        } else if (index == 1) {
          Navigator.push(
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
        BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "Analytics"),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: "Split"),
      ],
    );
  }
}