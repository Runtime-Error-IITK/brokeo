import 'package:flutter/material.dart';
import 'package:brokeo/frontend/home_pages/home_page.dart';
import 'package:brokeo/frontend/transactions_pages/category_page.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:brokeo/frontend/transactions_pages/transaction_detail_page.dart';

class ChooseTransactionPage extends StatefulWidget {
  @override
  _ChooseTransactionPageState createState() => _ChooseTransactionPageState();
}




class _ChooseTransactionPageState extends State<ChooseTransactionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose Transaction"),
        backgroundColor: Colors.purple,
      ),
      body: ListView(
        children: [
          _buildTransactionTile("Aujasvit Datta", 123),
          _buildTransactionTile("Darshan Sethia", 10),
          _buildTransactionTile("Suryansh Verma", 1320),
          _buildTransactionTile("Darshan Sethia", 123),
          _buildTransactionTile("Bhavnoor", 123),
          _buildTransactionTile("CC Canteen", 123),
          _buildTransactionTile("Hall 10 Canteen", 431),
          _buildTransactionTile("Domino's", 123),
          _buildTransactionTile("Swiggy", 13),
          _buildTransactionTile("Barbeque Nation", 134),
          _buildTransactionTile("PVR Cinemas", 123),
          _buildTransactionTile("Aujasvit Datta", 123),
        ],
      ),
    );
  }



  Widget _buildTransactionTile(String name, double amount) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.purple[100],
        child: Text(name[0], style: TextStyle(color: Colors.purple)),
      ),
      title: Text(name),
      subtitle: Text("₹$amount"),
      trailing: Icon(Icons.check_circle, color: Colors.green),
      onTap: () {
        // Logic for choosing a transaction
        print("Transaction chosen: $name");
      },
    );
  }
}


