// List of default categories to create.
import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;

final List<Map<String, dynamic>> defaultCategories = [
  {'budget': 0, 'name': 'Groceries'},
  {'budget': 0, 'name': 'Health'},
  {'budget': 0, 'name': 'Travel'},
  {'budget': 0, 'name': 'Food and Drinks'},
  {'budget': 0, 'name': 'EMI'},
  {'budget': 0, 'name': 'Entertainment'},
  {'budget': 0, 'name': 'Investment'},
  {'budget': 0, 'name': 'Others'},
];

/// Checks if the default categories exist for the user. If not, creates them.
Future<void> ensureDefaultCategories(String userId) async {
  final firestore = FirebaseFirestore.instance;
  final userCategoriesRef = firestore
      .collection('categories')
      .doc(userId)
      .collection('userCategories');

  // Check if there's at least one category document.
  final snapshot = await userCategoriesRef.limit(1).get();

  if (snapshot.docs.isEmpty) {
    // No categories exist; create the defaults.
    await _createDefaultCategories(userId);
  }
}

/// Creates default category documents using a Firestore batch.
Future<void> _createDefaultCategories(String userId) async {
  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();
  final userCategoriesRef = firestore
      .collection('categories')
      .doc(userId)
      .collection('userCategories');

  for (final category in defaultCategories) {
    // Generate a new document reference with an auto-generated ID.
    final docRef = userCategoriesRef.doc();
    batch.set(docRef, {
      'budget': category['budget'],
      'name': category['name'],
      'userId': userId,
      // You can add more fields if needed.
    });
  }

  // Commit the batch write.
  await batch.commit();
}
