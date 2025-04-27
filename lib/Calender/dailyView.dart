import 'package:flutter/material.dart';

class DailyViewPage extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;

  const DailyViewPage({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
    return  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 50, color: Colors.grey),
            const SizedBox(height: 10),
            const Text(
              "No data available",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
  }
    // Group transactions by date
    Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
    for (var transaction in transactions) {
      DateTime date = DateTime.parse(transaction['date']);
      String formattedDate = "${date.day} ${_getWeekday(date.weekday)}";
      if (!groupedTransactions.containsKey(formattedDate)) {
        groupedTransactions[formattedDate] = [];
      }
      groupedTransactions[formattedDate]!.add(transaction);
    }

    return ListView(
      children: groupedTransactions.keys.map((date) {
        List<Map<String, dynamic>> dateTransactions = groupedTransactions[date]!;
        double totalIncome = dateTransactions.fold(0.0, (sum, item) => sum + item['income']);
        double totalExpense = dateTransactions.fold(0.0, (sum, item) => sum + item['expense']);

        List<String> dateParts = date.split(' ');
        String day = dateParts[0];
        String weekday = dateParts[1];

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
                          day,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            weekday,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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
                const Divider(color: Colors.grey),
                ...dateTransactions.map((transaction) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                transaction['category'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                transaction['accountType'],
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Rs. ${transaction['income'].toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.blue),
                              ),
                              Text(
                                'Rs. ${transaction['expense'].toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }
}