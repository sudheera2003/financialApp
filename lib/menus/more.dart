// import 'package:firebase_auth/firebase_auth.dart';
import 'package:financial_app/pages/expense_list.dart';
import 'package:financial_app/pages/income_list.dart';
import 'package:flutter/material.dart';
import 'package:financial_app/pages/currency_screen.dart';

class More extends StatefulWidget {
  const More({super.key});

  @override
  _MoreState createState() => _MoreState();
}

class _MoreState extends State<More> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 27, 27, 29),
      appBar: AppBar(
        title: const Text('More', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 27, 27, 29),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ExpenseList()),
                    );
                  },
                  child: Column(
                    children: const [
                      Icon(
                        Icons.payment,
                        color: Colors.white,
                        size: 35,
                      ),
                      Text('Expense',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 30,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const IncomeList()),
                    );
                  },
                  child: Column(
                    children: const [
                      Icon(
                        Icons.paid_rounded,
                        color: Colors.white,
                        size: 35,
                      ),
                      Text('Income',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 30,
                ),
                Column(
                  children: const [
                    Icon(
                      Icons.savings,
                      color: Colors.white,
                      size: 35,
                    ),
                    Text('Budget',
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CurrencyScreen()),
                    );
                  },
                  child: Column(
                    children: const [
                      Icon(
                        Icons.currency_exchange,
                        color: Colors.white,
                        size: 35,
                      ),
                      Text('Converter',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 30,
                ),
                Column(
                  children: const [
                    Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 35,
                    ),
                    Text('App Lock',
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                  ],
                ),
                const SizedBox(
                  width: 30,
                ),
                Column(
                  children: const [
                    Icon(
                      Icons.reviews,
                      color: Colors.white,
                      size: 35,
                    ),
                    Text('Feedback',
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
