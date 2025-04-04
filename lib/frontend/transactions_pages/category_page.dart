import 'package:brokeo/backend/models/category.dart';
import 'package:brokeo/backend/models/transaction.dart' show Transaction;
import 'package:brokeo/backend/services/providers/read_providers/transaction_stream_provider.dart'
    show TransactionFilter, transactionStreamProvider;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CategoryPage extends ConsumerStatefulWidget {
  final Category category;
  const CategoryPage({super.key, required this.category});

  @override
  CategoryPageState createState() => CategoryPageState();
}

class CategoryPageState extends ConsumerState<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    final transactionFilter =
        TransactionFilter(categoryId: category.categoryId);
    final asyncTransactions =
        ref.watch(transactionStreamProvider(transactionFilter));

    return asyncTransactions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("User error: $error")),
            );
          });
          return SizedBox.shrink();
        },
        data: (transactions) {
          final now = DateTime.now();

          final List<List<Transaction>> filteredTransactions = [];

          for (int i = 5; i >= 0; i--) {
            final month = DateTime(now.year, now.month - i);
            final monthTransactions = transactions.where((transaction) {
              return transaction.date.year == month.year &&
                  transaction.date.month == month.month;
            }).toList();
            filteredTransactions.add(monthTransactions);
          }
        });
  }
}
