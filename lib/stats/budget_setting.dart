import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For DateFormat
import 'package:financial_app/Calender/modelhelper.dart'; // Import the ModalHelper
import 'budget_add.dart'; // Import the BudgetAdd widget

class BudgetSetting extends StatefulWidget {
  const BudgetSetting({super.key});

  @override
  _BudgetSettingState createState() => _BudgetSettingState();
}

class _BudgetSettingState extends State<BudgetSetting> with SingleTickerProviderStateMixin {
  String selectedPeriod = 'Monthly'; // Default selected period
  DateTime _selectedMonth = DateTime.now(); // Track the selected month
 // Track the selected point index

  late TabController _tabController; // TabController for managing tabs

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Initialize TabController
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose the TabController
    super.dispose();
  }

  // Method to open the BudgetAdd pop-up
  void _openBudgetAdd(BuildContext context, String category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BudgetAdd(
          category: category,
          onSave: (period, amount) {
            setState(() {}); // Refresh the UI
            print('Budget for $category: $amount ($period)');
          },
        );
      },
    );
  }

  // Helper method to get all weeks
  List<DateTimeRange> _getAllWeeks() {
    final List<DateTimeRange> allWeeks = [];
    DateTime currentStart = DateTime(2020); // Start from a specific year
    final DateTime now = DateTime.now();

    // Generate past weeks
    while (currentStart.isBefore(now)) {
      final currentEnd = currentStart.add(Duration(days: 6));
      allWeeks.add(DateTimeRange(start: currentStart, end: currentEnd));
      currentStart = currentStart.add(Duration(days: 7));
    }

    // Generate future weeks (up to 5 years ahead)
    currentStart = now;
    final DateTime futureLimit = DateTime(now.year + 5, now.month, now.day);
    while (currentStart.isBefore(futureLimit)) {
      final currentEnd = currentStart.add(Duration(days: 6));
      allWeeks.add(DateTimeRange(start: currentStart, end: currentEnd));
      currentStart = currentStart.add(Duration(days: 7));
    }

    return allWeeks;
  }

  // Get the weekly date range
  String _getWeeklyDateRange(DateTime date) {
    final allWeeks = _getAllWeeks();
    final weekIndex = _getWeekIndex(date);
    final weekRange = allWeeks[weekIndex];
    return '${DateFormat('MMMM yyyy').format(weekRange.start)} (${weekRange.start.day} - ${weekRange.end.day})';
  }

  // Helper method to get the index of the selected week
  int _getWeekIndex(DateTime date) {
    final allWeeks = _getAllWeeks();
    for (var i = 0; i < allWeeks.length; i++) {
      final weekRange = allWeeks[i];
      if (date.isAfter(weekRange.start.subtract(Duration(days: 1))) &&
          date.isBefore(weekRange.end.add(Duration(days: 1)))) {
        return i;
      }
    }
    return 0;
  }

  // Change month, week, or year based on the selected period
  void _changeMonth(int increment) {
    setState(() {
      if (selectedPeriod == 'Weekly') {
        // Change the week when "Weekly" is selected
        _selectedMonth = _selectedMonth.add(Duration(days: 7 * increment));
      } else if (selectedPeriod == 'Monthly') {
        // Change the month for "Monthly"
        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + increment, 1);
      } else if (selectedPeriod == 'Annually') {
        // Change the year for "Annually"
        _selectedMonth = DateTime(_selectedMonth.year + increment, _selectedMonth.month, 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final incomes = ModalHelper.getItems("Income"); // Fetch income items
    final expenses = ModalHelper.getItems("Expenses"); // Fetch expense items

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 49, 50, 56),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 49, 50, 56),
        title: const Text('Budget Setting'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100), // Adjust height to accommodate TabBar
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  // Implement the logic for showing the date range picker if needed
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: Colors.white),
                        onPressed: () => _changeMonth(-1),
                      ),
                      Text(
                        selectedPeriod == 'Weekly'
                            ? _getWeeklyDateRange(_selectedMonth) // Display weekly date range
                            : selectedPeriod == 'Monthly'
                                ? DateFormat('MMMM yyyy').format(_selectedMonth) // Display full month and year
                                : DateFormat('yyyy').format(_selectedMonth), // Display only the year
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: Colors.white),
                        onPressed: () => _changeMonth(1),
                      ),
                    ],
                  ),
                ),
              ),
              // Add TabBar here
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Income'),
                  Tab(text: 'Expenses'),
                ],
                indicatorColor: Colors.deepOrangeAccent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
              ),
            ],
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                selectedPeriod = value;
              });
            },
            itemBuilder: (BuildContext context) {
              return {'Weekly', 'Monthly', 'Annually'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(
                    choice,
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }).toList();
            },
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    selectedPeriod[0],
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Income Tab
          _buildCategorySection(incomes),
          // Expenses Tab
          _buildCategorySection(expenses),
        ],
      ),
    );
  }

  Widget _buildCategorySection(List<String> items) {
    return ListView(
      children: items.map((item) {
        return Card(
          color: Colors.grey[800],
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(
              item,
              style: TextStyle(color: Colors.white),
            ),
            trailing: Text(
              "Rs. 00",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              _openBudgetAdd(context, item); // Open the BudgetAdd pop-up
            },
          ),
        );
      }).toList(),
    );
  }


}