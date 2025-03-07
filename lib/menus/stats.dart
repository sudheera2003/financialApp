import 'package:flutter/material.dart';

class Stats extends StatefulWidget {
  const Stats({ super.key });

  @override
  _StatsState createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stats', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 27, 27, 29),
      ),
      body: Container(
        color: Color.fromARGB(255, 27, 27, 29),
      ),
    );
  }
}