import 'package:flutter/material.dart';
import 'package:financial_app/Calender/form.dart';
import 'boxes.dart';
import 'calculator.dart';
import 'transaction.dart';
import 'package:intl/intl.dart';

class ModalHelper {
  static void openCalendar({
    required BuildContext context,
    required Function(DateTime) onDateSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.42,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CalendarDatePicker(
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  onDateChanged: (selectedDate) {
                    onDateSelected(selectedDate);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static void openCalculator({
    required BuildContext context,
    required TextEditingController controller,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.415,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: CalculatorScreen(controller: controller),
              ),
            ],
          ),
        );
      },
    );
  }

  static void openSelectionModal_1({
    required BuildContext context,
    required TextEditingController controller,
    required Function(IconData) onIconSelected,
  }) {
    final List<Map<String, dynamic>> items = [
      {"icon": Icons.home, "text": "Home"},
      {"icon": Icons.work, "text": "Work"},
      {"icon": Icons.school, "text": "School"},
      {"icon": Icons.shopping_cart, "text": "Shopping"},
      {"icon": Icons.sports_soccer, "text": "Sports"},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(12),
          height: MediaQuery.of(context).size.height * 0.50,
          child: Column(
            children: [
              const Text(
                "Select an Option",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        leading: Icon(items[index]["icon"], color: Colors.blue),
                        title: Text(items[index]["text"]),
                        onTap: () {
                          controller.text = items[index]["text"];
                          onIconSelected(items[index]["icon"]);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static void openSelectionModal_2({
    required BuildContext context,
    required TextEditingController controller,
  }) {
    final List<Map<String, dynamic>> items = [
      {"text": "Account"},
      {"text": "Cash"},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(12),
          height: MediaQuery.of(context).size.height * 0.50,
          child: Column(
            children: [
              const Text(
                "Select an Option",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        
                        title: Text(items[index]["text"]),
                        onTap: () {
                          controller.text = items[index]["text"];
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

static Future<void> showBottomSheetEvents(BuildContext context, List<Transaction> transactions, DateTime selectedDate, {VoidCallback? onClose}) async {
  DateTime date;
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allow the bottom sheet to take up more screen space
    isDismissible: true, // Allow closing by tapping outside (default behavior)
    enableDrag: false,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder( // Allows bottom sheet to rebuild when state changes
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Transactions on ${DateFormat.yMMMd().format(selectedDate)}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),

                // Show a message when there are no transactions for the selected date
                transactions.isEmpty
                    ? SizedBox(
                      height: MediaQuery.of(context).size.height * 0.510,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline, size: 50, color: Colors.grey),
                            SizedBox(height: 10),
                            Text(
                              "No transactions for this date",
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                    : SizedBox(
                        height: MediaQuery.of(context).size.height * 0.510,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final txn = transactions[index];
                            return ListTile(
                              leading: Icon(Icons.category, color: Colors.blue),
                              title: Text(txn.category),
                              subtitle: Text(txn.accountType),
                              trailing: Text(
                                "Rs. ${txn.amount.toStringAsFixed(2)}",
                                style: TextStyle(
                                  color: txn.amount > 0 && txn.type == "Income" ? Colors.green : Colors.red,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () async {
                                date = txn.date;
                                bool? result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FormScreen(type: txn.type, transaction: txn),
                                  ),
                                );

                                if (result == true) {
                                  // Re-fetch updated transactions for the same date
                                  List<Transaction>? updatedTransactions = boxTransactions.values
                                      .where((t) => t.date == date) // Filter by same date
                                      .cast<Transaction>()
                                      .toList();

                                  // Refresh bottom sheet UI
                                  setState(() {
                                    transactions.clear();
                                    transactions.addAll(updatedTransactions);
                                  });
                                }
                              },
                            );
                          },
                        ),
                      ),
              ],
            ),
          );
        },
      );
    },
  ).then((_) {
    if (onClose != null) {
      onClose(); // Trigger the callback to refresh the calendar
    }
  });
}




}
