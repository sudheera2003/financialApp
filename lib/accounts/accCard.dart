import 'package:financial_app/Calender/modelHelper.dart';
import 'package:flutter/material.dart';
import 'package:financial_app/Calender/boxes.dart'; // Import your boxes file
import 'package:financial_app/Calender/transaction.dart'; // Import your Transaction model
import 'package:intl/intl.dart'; // For date formatting

class AccCard extends StatelessWidget {
  final DateTime selectedMonth; // Add selectedMonth parameter

  const AccCard({super.key, required this.selectedMonth});

  @override
  Widget build(BuildContext context) {
    // Fetch all accounts (you can replace this with your logic)
    final List<String> accounts = ModalHelper.getItems("Account");

    return ListView(
      children: accounts.map((acc) {
        return Card(
          color: const Color(0xFF2A2A2A),
          margin: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            acc,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Rs. ${_incomeSet(acc)}',
                            style: const TextStyle(color: Colors.blue),
                          ),
                          Text(
                            'Rs. ${_expensesSet(acc)}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _incomeSet(String acc) {
    List<Transaction> transactions = boxTransactions.values
        .cast<Transaction>()
        .where((txn) =>
            txn.accountType == acc &&
            txn.type == "Income" &&
            _isSameMonth(txn.date, selectedMonth)) // Filter by selected month
        .toList();

    if (transactions.isNotEmpty) {
      double totalIncome = transactions.fold(0.0, (sum, txn) => sum + txn.amount);
      return totalIncome.toStringAsFixed(2); // Format to 2 decimal places
    } else {
      return '0.00'; // Default value if no transactions are found
    }
  }

  String _expensesSet(String acc) {
    List<Transaction> transactions = boxTransactions.values
        .cast<Transaction>()
        .where((txn) =>
            txn.accountType == acc &&
            txn.type == "Expenses" &&
            _isSameMonth(txn.date, selectedMonth)) // Filter by selected month
        .toList();

    if (transactions.isNotEmpty) {
      double totalExpenses = transactions.fold(0.0, (sum, txn) => sum + txn.amount);
      return totalExpenses.toStringAsFixed(2); // Format to 2 decimal places
    } else {
      return '0.00'; // Default value if no transactions are found
    }
  }

  // Helper function to check if two dates are in the same month/year
  bool _isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }
}