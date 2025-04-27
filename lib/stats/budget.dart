import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    widget.tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (widget.tabController.indexIsChanging || widget.tabController.index != _selectedTabIndex) {
      if (mounted) {
        setState(() {
          _selectedTabIndex = widget.tabController.index;
        });
      }
    }
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_onTabChanged);
    super.dispose();
  }

  String _getPeriodKey() {
    if (widget.selectedPeriod == 'Weekly') {
      final startOfWeek = widget.selectedMonth.subtract(Duration(days: widget.selectedMonth.weekday - 1));
      return '${startOfWeek.year}_${startOfWeek.month}_${startOfWeek.day}';
    } else if (widget.selectedPeriod == 'Monthly') {
      return '${widget.selectedMonth.year}_${widget.selectedMonth.month}';
    } else if (widget.selectedPeriod == 'Annually') {
      return '${widget.selectedMonth.year}';
    } else if (widget.selectedPeriod == 'Period') {
      return '${widget.selectedStartDate.year}_${widget.selectedStartDate.month}_${widget.selectedStartDate.day}_${widget.selectedEndDate.year}_${widget.selectedEndDate.month}_${widget.selectedEndDate.day}';
    }
    return 'default';
  }

  Future<Map<String, dynamic>> _getGroupedTransactions(String type) async {
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
    double totalTransactionAmount = 0.0;

    for (var txn in boxTransactions.values.cast<Transaction>()) {
      if (txn.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          txn.date.isBefore(endDate.add(const Duration(days: 1))) &&
          txn.type == type) {
        categoryTotals[txn.category] = (categoryTotals[txn.category] ?? 0) + txn.amount;
        totalTransactionAmount += txn.amount;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    String periodKey = _getPeriodKey();

    double totalBudgetAmount = 0.0;
    List<Map<String, dynamic>> transactions = categoryTotals.entries.map((entry) {
      String category = entry.key;
      double totalAmount = entry.value;
      double budgetAmount = prefs.getDouble("budget_${periodKey}_$category") ?? 0.0;
      totalBudgetAmount += budgetAmount;

      return {
        "category": category,
        "totalAmount": totalAmount,
        "budgetAmount": budgetAmount,
      };
    }).toList();

    double remainingBudget = totalBudgetAmount - totalTransactionAmount;

    return {
      "transactions": transactions,
      "totalBudgetAmount": totalBudgetAmount,
      "totalTransactionAmount": totalTransactionAmount,
      "remainingBudget": remainingBudget,
    };
  }

  @override
  Widget build(BuildContext context) {
    final transactionType = _selectedTabIndex == 0 ? "Income" : "Expenses";

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 27, 27, 29),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _getGroupedTransactions(transactionType),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final transactions = snapshot.hasData ? snapshot.data!["transactions"] : [];
              final totalBudgetAmount = snapshot.hasData ? snapshot.data!["totalBudgetAmount"] : 0.0;
              final totalTransactionAmount = snapshot.hasData ? snapshot.data!["totalTransactionAmount"] : 0.0;
              final remainingBudget = snapshot.hasData ? snapshot.data!["remainingBudget"] : 0.0;

              double progressValue = totalBudgetAmount > 0 ? (totalTransactionAmount / totalBudgetAmount) : 0.0;
              String usedPercentage = totalBudgetAmount > 0
                  ? '${(progressValue * 100).toStringAsFixed(2)}%'
                  : '0%';

              Color progressBarColor = totalTransactionAmount > totalBudgetAmount ? Colors.red : Colors.blue;

              return Column(
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
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BudgetSetting(
                                  selectedPeriod: widget.selectedPeriod,
                                  selectedMonth: widget.selectedMonth,
                                  selectedStartDate: widget.selectedStartDate,
                                  selectedEndDate: widget.selectedEndDate,
                                ),
                              ),
                            );

                            if (result == true) {
                              setState(() {});
                            }
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
                  totalBudgetAmount > 0
                      ? Text(
                          'Rs. ${remainingBudget.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        )
                      : Text(
                          'Set a budget',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(widget.selectedPeriod, style: const TextStyle(fontSize: 16, color: Colors.white)),
                            Text(
                              usedPercentage,
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: progressValue,
                          backgroundColor: Colors.grey,
                          valueColor: AlwaysStoppedAnimation<Color>(progressBarColor),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Rs. ${totalBudgetAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, color: Colors.white)),
                            Text('Rs. ${totalTransactionAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, color: Colors.white)),
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
                    double progressValue = txn["budgetAmount"] > 0
                        ? (txn["totalAmount"] / txn["budgetAmount"])
                        : 0.0;
                    String usedPercentage = txn["budgetAmount"] > 0
                        ? '${(progressValue * 100).toStringAsFixed(2)}%'
                        : '0%';

                    return Card(
                      color: Colors.grey[800],
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BudgetSetting(
                                selectedPeriod: widget.selectedPeriod,
                                selectedMonth: widget.selectedMonth,
                                selectedStartDate: widget.selectedStartDate,
                                selectedEndDate: widget.selectedEndDate,
                              ),
                            ),
                          );

                          if (result == true) {
                            setState(() {});
                          }
                        },
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(txn["category"], style: const TextStyle(color: Colors.white)),
                            Text(
                              'Budget: Rs. ${txn["budgetAmount"].toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.grey[400], fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LinearProgressIndicator(
                                  value: progressValue,
                                  backgroundColor: Colors.grey[600],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    txn["totalAmount"] > txn["budgetAmount"]
                                        ? Colors.red
                                        : Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  usedPercentage,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
              );
            },
          ),
        ),
      ),
    );
  }
}