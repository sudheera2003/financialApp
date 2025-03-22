import 'package:flutter/material.dart';

class MonthlyViewPage extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;

  const MonthlyViewPage({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: transactions.map((monthData) {
        // Extract data for the month
        int month = monthData['month'];
        double totalIncome = monthData['income'];
        double totalExpense = monthData['expense'];

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          _getMonth(month), // Convert month number to name
                          style: const TextStyle(
                            fontSize: 15,
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
                          'Income: Rs. ${totalIncome.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.blue),
                        ),
                        Text(
                          'Expense: Rs. ${totalExpense.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getMonth(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }
}