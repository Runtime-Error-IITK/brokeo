import 'package:flutter/material.dart';
import 'package:brokeo/frontend/split_pages/choose_transactions.dart';
class ManageSplitsPage extends StatefulWidget {
  @override
  _ManageSplitsPageState createState() => _ManageSplitsPageState();
}

class _ManageSplitsPageState extends State<ManageSplitsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Splits"),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Color(0xFFEDE7F6),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "Total Balance",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Text(
                        "₹1441",
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        "You owe",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Text(
                        "₹200",
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        "You are owed",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Text(
                        "₹1641",
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListView(
              shrinkWrap: true,
              children: [
                _buildSplitTile("Chetan Singh", 50),
                _buildSplitTile("Darshan", 510),
                _buildSplitTile("Chinmay Jain", 75),
                _buildSplitTile("Aryan Kumar", 25),
                _buildSplitTile("Suryansh Verma", 160),
                _buildSplitTile("Anjali Patra", 1200),
                _buildSplitTile("Rudransh Verma", 0, isSettled: true),
                _buildSplitTile("Moni Sinha", 50),
                _buildSplitTile("Sanjina S", 1),
                _buildSplitTile("Prem Bhardwaj", 3180),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChooseTransactionPage()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
    );
  }

  Widget _buildSplitTile(String name, double amount, {bool isSettled = false}) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.purple[100],
        child: Text(name[0], style: TextStyle(color: Colors.purple)),
      ),
      title: Text(name),
      trailing: Text(
        "₹${amount}",
        style: TextStyle(
          color: amount < 0 ? Colors.red : Colors.green,
          fontWeight: isSettled ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

