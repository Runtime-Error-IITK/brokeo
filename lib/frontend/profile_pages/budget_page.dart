import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BudgetPage extends ConsumerStatefulWidget {
  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends ConsumerState<BudgetPage> {
  double _totalBudget = 1000;
  Map<String, Map<String, dynamic>> _categoryBudgets = {
    "Food and Drinks": {"budget": 500.0, "emoji": "🍔"},
    "Shopping": {"budget": 200.0, "emoji": "🛍️"},
    "Travel": {"budget": 200.0, "emoji": "✈️"},
    "Education": {"budget": 100.0, "emoji": "📚"},
  };

  final TextEditingController _catNameController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _emojiController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        title: Text(
          "Set Budget",
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Budget Input
            Text(
              "Total Budget",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8.0),
            TextFormField(
              initialValue: _totalBudget.toStringAsFixed(0),
              decoration: InputDecoration(
                labelText: "Enter total budget",
                prefixText: "₹",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _totalBudget = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            SizedBox(height: 16.0),

            // Category Budgets
            Text(
              "Category Budgets",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8.0),
            ..._categoryBudgets.entries.map((entry) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      child: Text(
                        entry.value["emoji"],
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Expanded(
                      child: TextFormField(
                        initialValue: entry.value["budget"].toStringAsFixed(0),
                        decoration: InputDecoration(
                          labelText: "Budget",
                          prefixText: "₹",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _categoryBudgets[entry.key]?["budget"] =
                                double.tryParse(value) ?? 0.0;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            // Add New Category Button
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  _showAddCategoryDialog();
                },
                icon: Icon(Icons.add, color: Theme.of(context).iconTheme.color),
                label: Text(
                  "Add Category",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            // Save Button
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Save the budget data to backend or local storage
                  print("Total Budget: $_totalBudget");
                  print("Category Budgets: $_categoryBudgets");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                ),
                child: Text(
                  "Save",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    _catNameController.clear();
    _budgetController.clear();
    _emojiController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Category"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _catNameController,
              decoration: InputDecoration(labelText: "Category Name"),
            ),
            TextField(
              controller: _emojiController,
              decoration: InputDecoration(labelText: "Emoji"),
            ),
            TextField(
              controller: _budgetController,
              decoration: InputDecoration(labelText: "Budget (optional)"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              String name = _catNameController.text.trim();
              String emoji = _emojiController.text.trim();
              double? budget = double.tryParse(_budgetController.text.trim());

              if (name.isNotEmpty && emoji.isNotEmpty) {
                setState(() {
                  _categoryBudgets[name] = {
                    "budget": budget ?? 0.0,
                    "emoji": emoji,
                  };
                });
              }

              Navigator.pop(context);
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }
}
