import 'package:brokeo/frontend/split_pages/split_between.dart'
    show SplitBetweenPage;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChooseTransactionPage extends ConsumerStatefulWidget {
  const ChooseTransactionPage({super.key});

  @override
  _ChooseTransactionPageState createState() => _ChooseTransactionPageState();
}

class _ChooseTransactionPageState extends ConsumerState<ChooseTransactionPage> {
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final description = _descController.text.trim();
    final amountText = _amountController.text.trim();

    // Validate non-empty fields
    if (description.isEmpty || amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
        ),
      );
      return;
    }

    // Validate that the amount is a valid positive number
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a positive amount.'),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SplitBetweenPage(
          amount: amount,
          description: description,
        ),
      ),
    );

    // If both validations pass, process the input accordingly
    // Add further transaction handling logic as needed.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Prevents keyboard overflow
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Removes the shadow for a cleaner look
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add Expense',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Enter Description',
                  prefixIcon: Icon(Icons.description, color: Colors.black54),
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter Amount',
                  prefixIcon: Icon(Icons.currency_rupee, color: Colors.black54),
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                  ),
                  child: const Text('Next'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
