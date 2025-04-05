import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:brokeo/backend/services/providers/read_providers/category_stream_provider.dart';
import 'package:brokeo/backend/services/providers/write_providers/category_service.dart';
import 'package:brokeo/backend/models/category.dart';

class BudgetPage extends ConsumerStatefulWidget {
  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends ConsumerState<BudgetPage> {
  double _totalBudget = 0.0;
  final Map<String, double> _updatedBudgets = {};
  final TextEditingController _totalBudgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _totalBudgetController.text = _totalBudget.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _totalBudgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncCategories = ref.watch(categoryStreamProvider(const CategoryFilter()));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // Ensure constant white background
        elevation: 0, // Remove shadow for a flat look
        scrolledUnderElevation: 0, // Prevent elevation change on scroll
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
        title: Text(
          "Set Budget",
          style: TextStyle(
            color: Colors.black, // Black text for contrast
            fontWeight: FontWeight.bold, // Bold title
          ),
        ),
        centerTitle: true,
      ),
      body: asyncCategories.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error loading categories: $error")),
            );
          });
          return const SizedBox.shrink();
        },
        data: (categories) {
          // Calculate the total of category budgets
          final double categoriesTotal = categories.fold(
            0.0,
            (sum, category) => sum + (_updatedBudgets[category.categoryId] ?? category.budget),
          );

          // Initialize total budget to the sum of category budgets if not already set
          if (_totalBudget == 0.0) {
            _totalBudget = categoriesTotal;
            _totalBudgetController.text = _totalBudget.toStringAsFixed(0);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Budget Input
                Text(
                  "Total Budget",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _totalBudgetController,
                  decoration: const InputDecoration(
                    labelText: "",
                    prefixText: "₹",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _totalBudget = double.tryParse(value) ?? _totalBudget;
                    });
                  },
                ),
                const SizedBox(height: 16.0),

                // Category Budgets
                Text(
                  "Category Budgets",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8.0),
                ...categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          child: Image.asset(
                            'assets/category_icon/${category.name}.jpg', // Match icon with category name
                            width: 24,
                            height: 24,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            category.name,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: TextFormField(
                            initialValue: category.budget.toStringAsFixed(0),
                            decoration: const InputDecoration(
                              labelText: "Budget",
                              prefixText: "₹",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final updatedBudget = double.tryParse(value) ?? category.budget;
                              setState(() {
                                _updatedBudgets[category.categoryId] = updatedBudget;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                // Save Button
                const SizedBox(height: 16.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_totalBudget < categoriesTotal) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Total budget cannot be less than the sum of category budgets."),
                          ),
                        );
                        return;
                      }

                      final categoryService = ref.read(categoryServiceProvider);
                      if (categoryService != null) {
                        try {
                          for (var category in categories) {
                            final updatedBudget = _updatedBudgets[category.categoryId] ?? category.budget;
                            categoryService.updateCloudCategory(
                              CloudCategory(
                                categoryId: category.categoryId,
                                name: category.name,
                                budget: updatedBudget,
                                userId: category.userId,
                              ),
                            );
                          }
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Budget updated successfully!")),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Failed to update budget: $e")),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0), // Wider button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0), // More rounded corners
                      ),
                      backgroundColor: Colors.purple,
                    ),
                    child: Text(
                      "Save",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
