import 'package:flutter/material.dart';
import 'package:financial_app/Calender/boxes.dart';
import 'package:financial_app/Calender/transaction.dart';
import 'budget_setting.dart';

class Budget extends StatefulWidget {
  final TabController tabController;
  final DateTime selectedMonth;
  final String selectedPeriod;
  final DateTime selectedStartDate;
  final DateTime selectedEndDate;

  const Budget({
    super.key,
    required this.tabController,
    required this.selectedMonth,
    required this.selectedPeriod,
    required this.selectedStartDate,
    required this.selectedEndDate,
  });

  @override
  State<Budget> createState() => _BudgetState();
}

class _BudgetState extends State<Budget> {
  late int _selectedTabIndex;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.tabController.index;

    widget.tabController.addListener(() {
      if (widget.tabController.indexIsChanging || widget.tabController.index != _selectedTabIndex) {
        setState(() {
          _selectedTabIndex = widget.tabController.index;
        });
      }
    });
  }

  List<Map<String, dynamic>> _getGroupedTransactions(String type) {
    DateTime startDate;
    DateTime endDate;

    switch (widget.selectedPeriod) {
      case 'Weekly':
        startDate = widget.selectedMonth.subtract(Duration(days: widget.selectedMonth.weekday - 1));
        endDate = startDate.add(Duration(days: 6));
        break;
      case 'Monthly':
        startDate = DateTime(widget.selectedMonth.year, widget.selectedMonth.month, 1);
        endDate = DateTime(widget.selectedMonth.year, widget.selectedMonth.month + 1, 0);
        break;
      case 'Annually':
        startDate = DateTime(widget.selectedMonth.year, 1, 1);
        endDate = DateTime(widget.selectedMonth.year, 12, 31);
        break;
      case 'Period':
        startDate = widget.selectedStartDate;
        endDate = widget.selectedEndDate;
        break;
      default:
        startDate = DateTime.now();
        endDate = DateTime.now();
        break;
    }

    Map<String, double> categoryTotals = {};
    for (var txn in boxTransactions.values.cast<Transaction>()) {
      if (txn.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          txn.date.isBefore(endDate.add(const Duration(days: 1))) &&
          txn.type == type) {
        categoryTotals[txn.category] = (categoryTotals[txn.category] ?? 0) + txn.amount;
      }
    }

    return categoryTotals.entries
        .map((entry) => {"category": entry.key, "totalAmount": entry.value})
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final transactionType = _selectedTabIndex == 0 ? "Income" : "Expenses";
    final transactions = _getGroupedTransactions(transactionType);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 49, 50, 56),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Remaining (${widget.selectedPeriod})',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => BudgetSetting()),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 1.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Budget Setting >',
                          style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              const Text(
                'Rs. 0.00',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.selectedPeriod, style: const TextStyle(fontSize: 16, color: Colors.white)),
                    const SizedBox(height: 10),
                    const LinearProgressIndicator(
                      value: 0.0,
                      backgroundColor: Colors.grey,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Rs. 0.00', style: TextStyle(fontSize: 16, color: Colors.white)),
                        Text('0.00', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _selectedTabIndex == 0 ? 'Income' : 'Expenses',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              ...transactions.map((txn) {
                return Card(
                  color: Colors.grey[800],
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(txn["category"], style: const TextStyle(color: Colors.white)),
                    trailing: Text(
                      'Rs. ${txn["totalAmount"].toStringAsFixed(2)}',
                      style: TextStyle(
                        color: transactionType == "Income" ? Colors.blue : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
