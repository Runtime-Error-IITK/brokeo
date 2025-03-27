class Transaction {
  final String name;
  final double amount;
  final String date;
  final String time;

  Transaction({
    required this.name,
    required this.amount,
    required this.date,
    required this.time,
  });
}

class MerchantBackend {
  static List<Merchant> getMerchants() {
    return [
      Merchant("1230ABCD", "CC Canteen", null),
      Merchant("1231ABCD", "Hall 12 Canteen", null),
      Merchant("1232ABCD", "Z Square", null),
      Merchant("1234ABCD", "New Merchant", null)
      // Add more if needed
    ];
  }
}
/// Merchant Backend - TODO: Link to original backend and integrate functionalities
class Merchant {
  String id = "123456789";
  String name = "sample";
  String alaisname = "sample";
  String category = "Others";
  List<Transaction> transactions = [
    Transaction(
        name: "CC Canteen", amount: 200, date: "31 Jan'25", time: "7:00 pm"),
    Transaction(
        name: "CC Canteen", amount: 150, date: "18 Jan'25", time: "2:30 pm"),
    Transaction(
        name: "CC Canteen", amount: 300, date: "20 Dec'24", time: "5:00 pm"),
    Transaction(
        name: "CC Canteen", amount: 300, date: "20 Dec'24", time: "5:00 pm"),
    Transaction(
        name: "CC Canteen", amount: 300, date: "20 Dec'24", time: "5:00 pm"),
    Transaction(
        name: "CC Canteen", amount: 300, date: "20 Dec'24", time: "5:00 pm"),
    Transaction(
        name: "CC Canteen", amount: 300, date: "20 Dec'24", time: "5:00 pm"),
    Transaction(
        name: "CC Canteen", amount: 300, date: "20 Dec'24", time: "5:00 pm"),
    Transaction(
        name: "CC Canteen", amount: 300, date: "20 Dec'24", time: "5:00 pm"),
    Transaction(
        name: "CC Canteen", amount: 300, date: "20 Dec'24", time: "5:00 pm"),
    Transaction(
        name: "CC Canteen", amount: 300, date: "20 Dec'24", time: "5:00 pm"),
  ];
  double amount = 0;
  int spends = 0;

  void updateAmountSpends() {
    spends = 0;
    amount = 0.0;
    Transaction trans;
    for (trans in transactions) {
      spends = spends + 1;
      amount = amount + trans.amount;
    }
  }

  void addTransactions(Transaction trans) {
    transactions.add(trans);
    updateAmountSpends();
  }

  Merchant(String id, String name, String? cat) {
    this.id = id;
    this.name = name;
    this.category = cat ?? this.category;
    this.alaisname = name;
  }
}