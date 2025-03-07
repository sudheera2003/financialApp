// import 'package:firebase_auth/firebase_auth.dart';
import 'package:financial_app/pages/expense_list.dart';
import 'package:financial_app/pages/income_list.dart';
import 'package:flutter/material.dart';

class More extends StatefulWidget {
  const More({super.key});

  @override
  _MoreState createState() => _MoreState();
}

class _MoreState extends State<More> {
// void signOutUser(){
//   FirebaseAuth.instance.signOut();
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 27, 27, 29),
      appBar: AppBar(
        title: Text('More', style: TextStyle(color: Colors.white)),
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
                    children: [
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
                    children: [
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
                  children: [
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
                Column(
                  children: [
                    Icon(
                      Icons.currency_exchange,
                      color: Colors.white,
                      size: 35,
                    ),
                    Text('Converter',
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                  ],
                ),
                const SizedBox(
                  width: 30,
                ),
                Column(
                  children: [
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
                  children: [
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
