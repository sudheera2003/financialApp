import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:financial_app/Calender/transaction.dart';
import 'package:financial_app/Calender/boxes.dart';
import 'category_detail.dart';
import 'budget.dart';
import 'custom_appbar.dart';

class Stats extends StatefulWidget {
  const Stats({Key? key}) : super(key: key);

  @override
  _StatsState createState() => _StatsState();
}

class _StatsState extends State<Stats> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedPeriod = 'Monthly';
  DateTime _selectedMonth = DateTime.now();
  bool _showMonthPicker = false;
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now();

  List<PieChartSectionData> sections = [];
  List<Map<String, dynamic>> categoryData = [];

  final List<Color> _categoryColors = [
    Colors.indigo,
    Colors.teal,
    Colors.pink,
    Colors.green,
    Colors.amber,
    Colors.red,
    Colors.cyan,
    Colors.blue,
    Colors.orange,
    Colors.purple,
  ];

  final PageController _pageController = PageController(initialPage: 0);
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _updateData();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging || _tabController.index != _currentPageIndex) {
      if (mounted) {
        setState(() {
          _updateData();
        });
      }
    }
  }

  void _updateData() {
    DateTime startDate;
    DateTime endDate;

    switch (selectedPeriod) {
      case 'Weekly':
        startDate = _selectedMonth.subtract(Duration(days: _selectedMonth.weekday));
        endDate = startDate.add(Duration(days: 6));
        break;
      case 'Monthly':
        startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
        endDate = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
        break;
      case 'Annually':
        startDate = DateTime(_selectedMonth.year, 1, 1);
        endDate = DateTime(_selectedMonth.year, 12, 31);
        break;
      case 'Period':
        startDate = _selectedStartDate;
        endDate = _selectedEndDate;
        break;
      default:
        startDate = DateTime.now();
        endDate = DateTime.now();
        break;
    }

    final transactions = boxTransactions.values
        .cast<Transaction>()
        .where((txn) =>
            txn.date.isAfter(startDate.subtract(Duration(days: 1))) &&
            txn.date.isBefore(endDate.add(Duration(days: 1))))
        .toList();

    final filteredTransactions = _tabController.index == 0
        ? transactions.where((txn) => txn.type == "Income").toList()
        : transactions.where((txn) => txn.type == "Expenses").toList();

    final categoryMap = <String, double>{};
    for (var txn in filteredTransactions) {
      categoryMap[txn.category] = (categoryMap[txn.category] ?? 0) + txn.amount;
    }

    int colorIndex = 0;
    categoryData = categoryMap.entries.map((entry) {
      final color = _categoryColors[colorIndex % _categoryColors.length];
      colorIndex++;
      return {
        'category': entry.key,
        'amount': entry.value,
        'color': color,
      };
    }).toList();

    sections = categoryData.map((data) {
      return PieChartSectionData(
        value: data['amount'],
        color: data['color'],
        title: '${((data['amount'] / categoryData.fold(0.0, (sum, item) => sum + item['amount'])) * 100).toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    if (mounted) {
      setState(() {});
    }
  }

  void _changeMonth(int increment) {
    if (selectedPeriod == 'Period') return;

    setState(() {
      if (selectedPeriod == 'Annually') {
        _selectedMonth = DateTime(_selectedMonth.year + increment, _selectedMonth.month, 1);
      } else if (selectedPeriod == 'Weekly') {
        _selectedMonth = _selectedMonth.add(Duration(days: 7 * increment));
      } else {
        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + increment, 1);
      }
    });
    _updateData();
  }

  void _toggleMonthPicker() {
    setState(() {
      _showMonthPicker = !_showMonthPicker;
    });
  }

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
            dialogBackgroundColor: const Color.fromARGB(255, 27, 27, 29),
            textTheme: TextTheme(
              bodyMedium: TextStyle(color: Colors.white),
            ),
            colorScheme: ColorScheme.dark(
              primary: Colors.red,
              onPrimary: Colors.white,
              surface: const Color.fromARGB(255, 27, 27, 29),
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
      _updateData();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 27, 27, 29),
      appBar: CustomAppBar(
        selectedPeriod: selectedPeriod,
        selectedMonth: _selectedMonth,
        selectedStartDate: _selectedStartDate,
        selectedEndDate: _selectedEndDate,
        onMonthChange: _changeMonth,
        onToggleMonthPicker: _toggleMonthPicker,
        onShowDateRangePicker: _showDateRangePicker,
        tabController: _tabController,
        onPeriodSelected: (value) {
          setState(() {
            selectedPeriod = value;
            _updateData();
          });
        },
        onPageChange: (index) {
          _pageController.jumpToPage(index);
        },
        currentPageIndex: _currentPageIndex,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        children: [
          Column(
            children: [
              SizedBox(height: 20),
              Container(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: categoryData.map((data) {
                    return buildCategoryItem(
                      data['category'],
                      'Rs. ${data['amount'].toStringAsFixed(2)}',
                      data['color'],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          Budget(
            tabController: _tabController,
            selectedMonth: _selectedMonth,
            selectedPeriod: selectedPeriod,
            selectedStartDate: _selectedStartDate,
            selectedEndDate: _selectedEndDate,
          ),
        ],
      ),
    );
  }

  Widget buildCategoryItem(String title, String amount, Color color) {
    final cleanedAmount = amount.replaceAll('Rs. ', '');
    double amountValue;
    try {
      amountValue = double.parse(cleanedAmount);
    } catch (e) {
      print('Error parsing amount: $e');
      amountValue = 0.0;
    }

    final totalAmount = categoryData.fold(0.0, (sum, item) => sum + item['amount']);
    final percentage = totalAmount > 0
        ? ((amountValue / totalAmount) * 100).toStringAsFixed(1)
        : '0.0';

    return ListTile(
      leading: Container(
        width: 50,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            '$percentage%',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      trailing: Text(
        amount,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailPage(
              categoryName: title,
              amount: amountValue,
              color: color,
            ),
          ),
        );
      },
    );
  }
}