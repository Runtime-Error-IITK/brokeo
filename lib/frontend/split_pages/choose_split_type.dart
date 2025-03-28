import 'package:brokeo/frontend/split_pages/manage_splits.dart';
import 'package:flutter/material.dart';
import 'package:brokeo/frontend/home_pages/home_page.dart' as brokeo_home;
import 'package:brokeo/frontend/transactions_pages/categories_page.dart';
import 'package:brokeo/frontend/analytics_pages/analytics_page.dart';

class ChooseSplitTypePage extends StatefulWidget {
  final Map<String, dynamic> transaction;
  final List<String> selectedContacts;

  const ChooseSplitTypePage({
    Key? key,
    required this.transaction,
    required this.selectedContacts,
  }) : super(key: key);

  @override
  _ChooseSplitTypePageState createState() => _ChooseSplitTypePageState();
}

class _ChooseSplitTypePageState extends State<ChooseSplitTypePage> {
  String _splitType = 'Equal'; // 'Equal' or 'Custom'
  final Map<String, double> _customAmounts = {};
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeEqualSplit();
  }

  void _initializeEqualSplit() {
    final totalAmount = widget.transaction['amount'].toDouble();
    final participantCount = widget.selectedContacts.length + 1; // +1 for yourself
    final equalAmount = totalAmount / participantCount;
    
    _customAmounts.clear();
    
    for (var contact in widget.selectedContacts) {
      _customAmounts[contact] = equalAmount;
    }
    _customAmounts['You'] = equalAmount;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _remainingAmount {
    final total = widget.transaction['amount'].toDouble();
    final allocated = _customAmounts.values.fold(0.0, (sum, amount) => sum + amount);
    return total - allocated;
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = widget.transaction['amount'].toDouble();
    final remainingAmount = _remainingAmount;

    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Split Type'),
      ),
      body: Column(
        children: [
          // Transaction Info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.transaction['name'],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: remainingAmount / totalAmount,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                ),
                SizedBox(height: 8),
                Text(
                  'Left ${remainingAmount.toStringAsFixed(2)}/${totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Split Type Selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Split Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Text('Equal'),
                        selected: _splitType == 'Equal',
                        onSelected: (selected) {
                          setState(() {
                            _splitType = 'Equal';
                            _initializeEqualSplit();
                          });
                        },
                        selectedColor: Colors.purple,
                        labelStyle: TextStyle(
                          color: _splitType == 'Equal' ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ChoiceChip(
                        label: Text('Custom'),
                        selected: _splitType == 'Custom',
                        onSelected: (selected) {
                          setState(() {
                            _splitType = 'Custom';
                          });
                        },
                        selectedColor: Colors.purple,
                        labelStyle: TextStyle(
                          color: _splitType == 'Custom' ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Amount Allocation List
          Expanded(
            child: ListView(
              children: [
                // Your allocation
                _buildAmountTile(
                  name: 'You',
                  amount: _customAmounts['You'] ?? 0.0,
                  onChanged: (value) {
                    setState(() {
                      _customAmounts['You'] = value;
                      if (_splitType == 'Equal') {
                        // When in Equal mode, changing one amount should switch to Custom
                        _splitType = 'Custom';
                      }
                    });
                  },
                ),
                
                // Contacts allocation
                ...widget.selectedContacts.map((contact) {
                  return _buildAmountTile(
                    name: contact,
                    amount: _customAmounts[contact] ?? 0.0,
                    onChanged: (value) {
                      setState(() {
                        _customAmounts[contact] = value;
                        if (_splitType == 'Equal') {
                          // When in Equal mode, changing one amount should switch to Custom
                          _splitType = 'Custom';
                        }
                      });
                    },
                  );
                }).toList(),
              ],
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.purple),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.purple,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: remainingAmount == 0
                        ? () {
                            // TODO: Save the split transaction


                            //navigator to ManageSplitsPage
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ManageSplitsPage(),
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Transaction split successfully!'),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Confirm',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // Split tab is active
        onTap: (index) {
          if (index != 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => _getPageForIndex(index),
              ),
            );
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Transactions"),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "Analytics"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Split"),
        ],
      ),
    );
  }

  Widget _buildAmountTile({
    required String name,
    required double amount,
    required Function(double) onChanged,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.purple[100],
        child: Text(
          name[0],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
      ),
      title: Text(name),
      trailing: SizedBox(
        width: 100,
        child: TextField(
          controller: TextEditingController(text: amount.toStringAsFixed(2)),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: '₹',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
          onChanged: (value) {
            final newAmount = double.tryParse(value) ?? 0.0;
            onChanged(newAmount);
          },
        ),
      ),
    );
  }

  Widget _getPageForIndex(int index) {
    switch (index) {
      case 0:
        return brokeo_home.HomePage(name: "Darshan", budget: 5000);
      case 1:
        return CategoriesPage();
      case 2:
        return AnalyticsPage();
      default:
        return ManageSplitsPage();
    }
  }
}