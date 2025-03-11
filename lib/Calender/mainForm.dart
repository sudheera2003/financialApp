import 'package:flutter/material.dart';
import 'package:financial_app/Calender/form.dart';

class MainForm extends StatefulWidget {
  final int initialTab; // Default tab index
  const MainForm({super.key, this.initialTab = 0});

  @override
  _MainFormState createState() => _MainFormState();
}

class _MainFormState extends State<MainForm> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String title = "Income"; // Default title

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
    _tabController.addListener(() {
      if (mounted) { // Ensure the widget is still active
        setState(() {
          title = _tabController.index == 0 ? "Income" : "Expenses";
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 49, 50, 56),
        title: Text(title,style: TextStyle(color: Colors.white)), // Dynamic title based on selected tab
        bottom: TabBar(
          indicatorColor: Colors.deepOrangeAccent,
          labelColor: Colors.white,
          controller: _tabController, // Attach the controller
          tabs: const [
            Tab(icon: Icon(Icons.attach_money), text: "Income"),
            Tab(icon: Icon(Icons.money_off), text: "Expenses"),
          ],
        ),
      ),
      body: TabBarView(
        
        controller: _tabController,
        children: const [
          FormScreen(type: "Income", showAppBar: false),
          FormScreen(type: "Expenses", showAppBar: false),
        ],
      ),
    );
  }
}
