import 'package:flutter/material.dart';

class BudgetPage extends StatefulWidget {
  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  double _totalBudget = 0.0;
  Map<String, Map<String, dynamic>> _categoryBudgets = {
    "Food and Drinks": {"budget": 0.0, "emoji": "🍔"},
    "Shopping": {"budget": 0.0, "emoji": "🛍️"},
    "Travel": {"budget": 0.0, "emoji": "✈️"},
    "Education": {"budget": 0.0, "emoji": "📚"},
  };

  final TextEditingController _catNameController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  String? _selectedEmoji;
  final List<String> _emojiOptions = ['🍔', '🍕', '🎉', '💡', '📚'];

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
        padding: EdgeInsets.symmetric(
          horizontal: Theme.of(context).paddingScheme.horizontal,
          vertical: Theme.of(context).paddingScheme.vertical,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Budget Input
            Text(
              "Total Budget",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: Theme.of(context).spacingScheme.small),
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
            SizedBox(height: Theme.of(context).spacingScheme.medium),

            // Category Budgets
            Text(
              "Category Budgets",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: Theme.of(context).spacingScheme.small),
            ..._categoryBudgets.entries.map((entry) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  vertical: Theme.of(context).spacingScheme.small,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      child: Text(
                        entry.value["emoji"],
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(width: Theme.of(context).spacingScheme.small),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    SizedBox(width: Theme.of(context).spacingScheme.small),
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
            SizedBox(height: Theme.of(context).spacingScheme.medium),
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
            SizedBox(height: Theme.of(context).spacingScheme.medium),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Save the budget data to backend or local storage
                  print("Total Budget: $_totalBudget");
                  print("Category Budgets: $_categoryBudgets");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  padding: EdgeInsets.symmetric(
                    horizontal: Theme.of(context).spacingScheme.large,
                    vertical: Theme.of(context).spacingScheme.medium,
                  ),
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
    _selectedEmoji = _emojiOptions.first;
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
            DropdownButton<String>(
              value: _selectedEmoji,
              items: _emojiOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedEmoji = val),
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
              String emoji = _selectedEmoji ?? '';
              int? budget = int.tryParse(_budgetController.text.trim());
              print("New Category: $name, Emoji: $emoji, Budget: $budget");
              Navigator.pop(context);
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }
}

extension on ThemeData {
  PaddingScheme get paddingScheme => PaddingScheme(
        horizontal: 16.0,
        vertical: 16.0,
      );

  SpacingScheme get spacingScheme => SpacingScheme(
        small: 8.0,
        medium: 16.0,
        large: 24.0,
      );
}

class PaddingScheme {
  final double horizontal;
  final double vertical;

  PaddingScheme({required this.horizontal, required this.vertical});
}

class SpacingScheme {
  final double small;
  final double medium;
  final double large;

  SpacingScheme({required this.small, required this.medium, required this.large});
}
