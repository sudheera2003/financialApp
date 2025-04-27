import 'package:financial_app/Calender/boxes.dart';
import 'package:financial_app/Calender/calander.dart';
import 'package:financial_app/Calender/transaction.dart';
import 'package:financial_app/stats/stats.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    List<Transaction> transactions = boxTransactions.values
        .cast<Transaction>()
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    List<Transaction> recentFive = transactions.take(5).toList();
    final String currentMonthName = DateFormat('MMMM').format(today);
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E), // Manually set dark background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Balance Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("YOUR BALANCE FOR CURRENT MONTH", style: TextStyle(color: Colors.white60)),
                      const SizedBox(height: 5),
                      Text("Rs. ${_calculateTotalForCurrentMonth(today).toStringAsFixed(2)}", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:[
                          ViewButton(icon: Icons.today, label: "Daily View",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ComplexTable(initialTab: 0,)),
                            );
                          },),
                          ViewButton(icon: Icons.calendar_month, label: "Calendar View",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ComplexTable(initialTab: 1,)),
                            );
                          },),
                          ViewButton(icon: Icons.bar_chart, label: "Monthly View",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ComplexTable(initialTab: 2,)),
                            );
                          },),
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Insight Banner
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => (Stats())),
                    );
                  },
                  borderRadius: BorderRadius.circular(16), // Match container radius
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5E35B1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.insights, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Let's check your Financial Insight for the month of $currentMonthName!",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text("Recent Financial Activities", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: recentFive.length,
                  itemBuilder: (context, index) {
                  final txn = recentFive[index];
                  return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor:txn.amount > 0 && txn.type == "Income"
                                        ? Colors.blue
                                        : Colors.red, 
                          child: Icon(Icons.attach_money, color: Colors.white),
                        ),
                        title: Text(txn.category, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        subtitle: Text("${txn.accountType} • ${DateFormat('dd MMM yyyy').format(txn.date)}", style: const TextStyle(fontSize: 12, color: Colors.white70)),
                        trailing: Text(
                          "Rs. ${txn.amount.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: txn.amount > 0 && txn.type == "Income"
                                        ? Colors.blue
                                        : Colors.red, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                
            ]),
          ),
        ),
      ),
    );
  }
}

class ViewButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const ViewButton({super.key, required this.icon, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF7C4DFF),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
        ],
      ),
    );
  }
}


  double _calculateTotalForCurrentMonth(DateTime month) {
    double income;
    double expenses;
    List<Transaction> transactionsIncome = boxTransactions.values
        .cast<Transaction>()
        .where((txn) =>
            txn.date.year == month.year &&
            txn.date.month == month.month &&
            txn.type == "Income")
        .toList();
    List<Transaction> transactionsExpenses = boxTransactions.values
      .cast<Transaction>()
      .where((txn) =>
          txn.date.year == month.year &&
          txn.date.month == month.month &&
          txn.type == "Expenses")
      .toList();
    if(transactionsIncome.isNotEmpty){
      income = transactionsIncome.fold(0.0, (sum, txn) => sum + txn.amount);
    }else{
      income = 0.00;
    }
    if(transactionsExpenses.isNotEmpty){
      expenses = transactionsExpenses.fold(0.0, (sum, txn) => sum + txn.amount);
    }else{
      expenses = 0.00;
    }
    return income - expenses;
  }

