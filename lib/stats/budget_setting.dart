import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:financial_app/Calender/modelhelper.dart';
import 'budget_add.dart';

class BudgetSetting extends StatefulWidget {
  final String selectedPeriod;
  final DateTime selectedMonth;
  final DateTime selectedStartDate;
  final DateTime selectedEndDate;

  const BudgetSetting({
    super.key,
    required this.selectedPeriod,
    required this.selectedMonth,
    required this.selectedStartDate,
    required this.selectedEndDate,
  });

  @override
  _BudgetSettingState createState() => _BudgetSettingState();
}

class _BudgetSettingState extends State<BudgetSetting> with SingleTickerProviderStateMixin {
  late String selectedPeriod;
  late DateTime _selectedMonth;
  late DateTime _selectedStartDate;
  late DateTime _selectedEndDate;
  late TabController _tabController;


  Map<String, double> budgetAmounts = {};

  @override
  void initState() {
    super.initState();
    selectedPeriod = widget.selectedPeriod;
    _selectedMonth = widget.selectedMonth;
    _selectedStartDate = widget.selectedStartDate;
    _selectedEndDate = widget.selectedEndDate;
    _tabController = TabController(length: 2, vsync: this);
    _loadBudgetAmounts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Method to load stored budget data
  Future<void> _loadBudgetAmounts() async {
    final prefs = await SharedPreferences.getInstance();
    String periodKey = _getPeriodKey();
    setState(() {
      budgetAmounts = Map.fromEntries(
        prefs.getKeys()
            .where((key) => key.startsWith("budget_${periodKey}_"))
            .map((key) => MapEntry(
                  key.replaceFirst("budget_${periodKey}_", ""), prefs.getDouble(key) ?? 0.0,
                )),
      );
    });
  }

  // Method to save budget data with period
  Future<void> _saveBudgetAmount(String category, double amount) async {
    final prefs = await SharedPreferences.getInstance();
    String periodKey = _getPeriodKey();
    await prefs.setDouble("budget_${periodKey}_$category", amount);
  }

  // Helper method to generate a period key based on the selected period
  String _getPeriodKey() {
    if (selectedPeriod == 'Weekly') {
      final startOfWeek = _selectedMonth.subtract(Duration(days: _selectedMonth.weekday - 1));
      return '${startOfWeek.year}_${startOfWeek.month}_${startOfWeek.day}';
    } else if (selectedPeriod == 'Monthly') {
      return '${_selectedMonth.year}_${_selectedMonth.month}';
    } else if (selectedPeriod == 'Annually') {
      return '${_selectedMonth.year}';
    } else if (selectedPeriod == 'Period') {
      return '${_selectedStartDate.year}_${_selectedStartDate.month}_${_selectedStartDate.day}_${_selectedEndDate.year}_${_selectedEndDate.month}_${_selectedEndDate.day}';
    }
    return 'default';
  }

  // Open BudgetAdd pop-up
  void _openBudgetAdd(BuildContext context, String category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BudgetAdd(
          category: category,
          onSave: (amount) async {
            setState(() {
              budgetAmounts[category] = amount;
            });
            await _saveBudgetAmount(category, amount);
            Navigator.pop(context, true);
          },
        );
      },
    );
  }

  // Change month, week, or year based on the selected period
  void _changeMonth(int increment) {
    setState(() {
      if (selectedPeriod == 'Annually') {
        _selectedMonth = DateTime(_selectedMonth.year + increment, _selectedMonth.month, 1);
      } else if (selectedPeriod == 'Weekly') {
        _selectedMonth = _selectedMonth.add(Duration(days: 7 * increment));
      } else {
        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + increment, 1);
      }
      _loadBudgetAmounts();
    });
  }

  // Show date range picker for "Period" option
  Future<void> _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(
        start: _selectedStartDate,
        end: _selectedEndDate,
      ),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            dialogBackgroundColor: const Color.fromARGB(255, 49, 50, 56),
            textTheme: TextTheme(
              bodyMedium: TextStyle(color: Colors.white),
            ),
            colorScheme: ColorScheme.dark(
              primary: Colors.red,
              onPrimary: Colors.white,
              surface: const Color.fromARGB(255, 49, 50, 56),
              onSurface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != DateTimeRange(start: _selectedStartDate, end: _selectedEndDate)) {
      setState(() {
        _selectedStartDate = picked.start;
        _selectedEndDate = picked.end;
      });
      _loadBudgetAmounts();
    }
  }

  // Get the weekly date range
  String _getWeeklyDateRange(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));
    return '${DateFormat('MMMM yyyy').format(startOfWeek)} (${startOfWeek.day} - ${endOfWeek.day})';
  }

  @override
  Widget build(BuildContext context) {
    final incomes = ModalHelper.getItems("Income");
    final expenses = ModalHelper.getItems("Expenses");

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 49, 50, 56),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 49, 50, 56),
        title: const Text('Budget Setting',style: TextStyle(color: Colors.white),),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  if (selectedPeriod == 'Period') {
                    _showDateRangePicker(context);
                  }
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
                        selectedPeriod == 'Annually'
                            ? DateFormat('yyyy').format(_selectedMonth)
                            : selectedPeriod == 'Weekly'
                                ? _getWeeklyDateRange(_selectedMonth)
                                : selectedPeriod == 'Period'
                                    ? '${DateFormat('MM/dd/yyyy').format(_selectedStartDate)} - ${DateFormat('MM/dd/yyyy').format(_selectedEndDate)}'
                                    : DateFormat('MMMM yyyy').format(_selectedMonth),
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
                _loadBudgetAmounts();
              });
            },
            itemBuilder: (BuildContext context) {
              return {'Weekly', 'Monthly', 'Annually', 'Period'}.map((String choice) {
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
                  SizedBox(width: 4),
                  Icon(
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
          _buildCategorySection(incomes),
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
              "Rs. ${budgetAmounts[item]?.toStringAsFixed(2) ?? '0.00'}",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              _openBudgetAdd(context, item);
            },
          ),
        );
      }).toList(),
    );
  }
}