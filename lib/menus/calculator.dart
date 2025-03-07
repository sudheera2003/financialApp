import 'package:flutter/material.dart';

class Calculator extends StatefulWidget {
  const Calculator({ super.key });

  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 27, 27, 29),
        appBar: AppBar(
          title: Text('Calculator'),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 27, 27, 29),
          foregroundColor: Colors.white,
        ),
    );
  }
}