import 'package:flutter/material.dart';
// import 'package:flutter_icons/flutter_icons.dart'; // Add this for additional icons

class BudgetPage extends StatefulWidget {
  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  double _totalBudget = 0.0;
  Map<String, Map<String, dynamic>> _categoryBudgets = {
    "Food": {"budget": 0.0, "icon": Icons.fastfood},
    "Shopping": {"budget": 0.0, "icon": Icons.shopping_cart},
    "Travel": {"budget": 0.0, "icon": Icons.flight},
    "Others": {"budget": 0.0, "icon": Icons.more_horiz},
  };

  void _addNewCategory(String categoryName, IconData icon) {
    setState(() {
      _categoryBudgets[categoryName] = {"budget": 0.0, "icon": icon};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: Theme.of(context).iconTheme,
        title: Text(
          "Set Budget",
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Budget Input
            Text(
              "Total Budget",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextFormField(
              initialValue: _totalBudget.toStringAsFixed(0),
              decoration: InputDecoration(
                labelText: "Enter total budget",
                labelStyle: Theme.of(context).textTheme.bodyMedium,
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
            SizedBox(height: 20),

            // Category Budgets
            Text(
              "Category Budgets",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ..._categoryBudgets.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(entry.value["icon"], size: 24, color: Theme.of(context).primaryColor),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        initialValue: entry.value["budget"].toStringAsFixed(0),
                        decoration: InputDecoration(
                          labelText: "Budget",
                          labelStyle: Theme.of(context).textTheme.bodyMedium,
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
            SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  _showAddCategoryDialog(context);
                },
                icon: Icon(Icons.add, color: Colors.white),
                label: Text(
                  "Add Category",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                ),
              ),
            ),

            // Save Button
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Save the budget data to backend or local storage
                  print("Total Budget: $_totalBudget");
                  print("Category Budgets: $_categoryBudgets");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: Text(
                  "Save",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    String? newCategoryName;
    IconData? selectedIcon = Icons.category;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add New Category"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: "Category Name"),
                    onChanged: (value) {
                      newCategoryName = value;
                    },
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<IconData>(
                    value: selectedIcon,
                    decoration: InputDecoration(labelText: "Select Icon"),
                    items: [
                      Icons.fastfood,
                      Icons.shopping_cart,
                      Icons.flight,
                      Icons.more_horiz,
                      Icons.home,
                      Icons.directions_car,
                    ].map((icon) {
                      return DropdownMenuItem<IconData>(
                        value: icon,
                        child: Icon(icon, color: Colors.purple),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedIcon = value;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (newCategoryName != null && selectedIcon != null) {
                  _addNewCategory(newCategoryName!, selectedIcon!);
                }
                Navigator.pop(context);
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }
}
