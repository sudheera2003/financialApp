import 'package:flutter/material.dart';
import 'package:financial_app/Calender/form.dart';
import 'boxes.dart';
import 'calculator.dart';
import 'transaction.dart';
import 'package:intl/intl.dart';

class ModalHelper {
  static List<String> getItems(String listType) {
    switch (listType) {
      case "Income":
        return ["Allowance", "Salary", "Petty cash", "Bonus"];
      case "Expenses":
        return ["Food", "Transport", "Entertainment", "Healthcare"];
      case "Account":
        return ["Cash", "Accounts", "Card"];
      default:
        return [];
    }
  }

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

  static void openSelectionModal({
    required BuildContext context,
    required TextEditingController controller,
    required String listType,
  }) {
    final List<String> items = getItems(listType);

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
                        title: Text(items[index]),
                        onTap: () {
                          controller.text = items[index];
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

  static Future<void> showBottomSheetEvents(
    BuildContext context,
    List<Transaction> transactions,
    DateTime selectedDate, {
    VoidCallback? onClose,
  }) async {
    DateTime date = selectedDate; // Initialize `date` with `selectedDate`

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Transactions on ${DateFormat.yMMMd().format(selectedDate)}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  transactions.isEmpty
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height * 0.510,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.info_outline, size: 50, color: Colors.grey),
                                const SizedBox(height: 10),
                                const Text(
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
                                leading: const Icon(Icons.category, color: Colors.blue),
                                title: Text(txn.category),
                                subtitle: Text(txn.accountType),
                                trailing: Text(
                                  "Rs. ${txn.amount.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color: txn.amount > 0 && txn.type == "Income"
                                        ? Colors.green
                                        : Colors.red,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () async {
                                  bool? result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FormScreen(type: txn.type, transaction: txn),
                                    ),
                                  );

                                  if (result == true) {
                                    List<Transaction> updatedTransactions =
                                        boxTransactions.values
                                            .where((t) => t.date == date)
                                            .cast<Transaction>()
                                            .toList();

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
        onClose();
      }
    });
  }
}
