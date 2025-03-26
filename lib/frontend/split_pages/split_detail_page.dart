import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SplitHistoryPage extends StatefulWidget {
  final Map<String, dynamic> split;

  const SplitHistoryPage({Key? key, required this.split}) : super(key: key);

  @override
  _SplitHistoryPageState createState() => _SplitHistoryPageState();
}

class _SplitHistoryPageState extends State<SplitHistoryPage> {
  late List<Map<String, dynamic>> _transactions;
  final NumberFormat _formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    // Using your exact mock data format
    final mockTransactions = [
      {
        'name': widget.split['name'],
        'amount': 200.0,
        'date': '31 Jan\'25, 7:00 pm',
        'avatarText': widget.split['name'][0]
      },
      {
        'name': widget.split['name'],
        'amount': -150.0,
        'date': '30 Jan\'25, 2:30 pm',
        'avatarText': widget.split['name'][0]
      },
    ];

    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _transactions = mockTransactions;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalOwed = _transactions.fold<double>(
      0,
      (sum, transaction) => sum + transaction['amount'],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Split History with ${widget.split['name']}'),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary Card
                _buildSummaryCard(totalOwed),
                
                // Transactions List Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        'Transaction History',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Transactions List
                Expanded(
                  child: ListView.builder(
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      return _buildTransactionTile(_transactions[index]);
                    },
                  ),
                ),
                
                // Settle Up Button (always shown since we don't have isSettled)
                _buildSettleButton(context),
              ],
            ),
    );
  }

  Widget _buildSummaryCard(double totalOwed) {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.purple[100],
              child: Text(
                widget.split['name'][0],
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              widget.split['name'],
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Total Balance: ${_formatter.format(totalOwed)}',
              style: TextStyle(
                fontSize: 18,
                color: totalOwed >= 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(Map<String, dynamic> transaction) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.purple[100],
        child: Text(
          transaction['avatarText'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
      ),
      title: Text(
        transaction['date'],
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: Text(
        _formatter.format(transaction['amount'].abs()),
        style: TextStyle(
          color: transaction['amount'] > 0 ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettleButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () => _showSettleConfirmation(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          minimumSize: Size(double.infinity, 50),
        ),
        child: Text(
          'Settle Up',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showSettleConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Settlement'),
        content: Text('Are you sure you want to settle with ${widget.split['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle settlement logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Settled with ${widget.split['name']}')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }
}