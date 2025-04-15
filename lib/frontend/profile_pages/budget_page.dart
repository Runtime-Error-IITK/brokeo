import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart';
import 'package:brokeo/backend/services/providers/write_providers/user_metadata_service.dart';
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

  // Create a NumberFormat to format numbers with commas.
  final NumberFormat formatter = NumberFormat.decimalPattern();

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
    final asyncCategories =
        ref.watch(categoryStreamProvider(const CategoryFilter()));

    final asyncMetadata = ref.watch(userMetadataStreamProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // Constant white background
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
      body: asyncMetadata.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error loading metadata: $error")),
            );
          });
          return const SizedBox.shrink();
        },
        data: (metadata) {
          return asyncCategories.when(
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
                (sum, category) =>
                    sum +
                    (_updatedBudgets[category.categoryId] ?? category.budget),
              );

              // Update total budget and its controller text with formatted value
              _totalBudget = categoriesTotal;
              _totalBudgetController.text = _totalBudget.toStringAsFixed(0);

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total Budget Display with a box
                    Text(
                      "Total Budget",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        "₹${formatter.format(_totalBudget)}",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
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
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                              child: Image.asset(
                                'assets/category_icon/${category.name}.jpg',
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
                                initialValue: formatter.format(category.budget),
                                decoration: const InputDecoration(
                                  labelText: "Budget",
                                  prefixText: "₹",
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) async {
                                  final updatedBudget = double.tryParse(
                                          value.replaceAll(',', '')) ??
                                      category.budget;
                                  setState(() {
                                    _updatedBudgets[category.categoryId] =
                                        updatedBudget;
                                    _totalBudget = categories.fold(
                                      0.0,
                                      (sum, category) =>
                                          sum +
                                          (_updatedBudgets[
                                                  category.categoryId] ??
                                              category.budget),
                                    );
                                  });

                                  final categoryService =
                                      ref.read(categoryServiceProvider);
                                  if (categoryService != null) {
                                    await categoryService.updateCloudCategory(
                                      CloudCategory(
                                        categoryId: category.categoryId,
                                        name: category.name,
                                        budget: updatedBudget,
                                        userId: category.userId,
                                      ),
                                    );
                                  }
                                  // log(metadata.toString());
                                  final metadataService =
                                      ref.read(userMetadataServiceProvider);
                                  if (metadataService != null) {
                                    final newMetadata = {
                                      'budget': _totalBudget,
                                      'name': metadata['name'],
                                      'phone': metadata['phone'],
                                    };
                                    await metadataService.updateUserMetadata(
                                      metadata: newMetadata,
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
