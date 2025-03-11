import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:financial_app/Calender/transaction.dart'; // Import the Transaction class
import 'package:financial_app/Calender/boxes.dart'; // Import the boxTransactions // For DateFormat
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
  String selectedPeriod = 'Monthly'; // Default selected period
  DateTime _selectedMonth = DateTime.now(); // Track the selected month
  bool _showMonthPicker = false; // Track visibility of the month picker
  DateTime _selectedStartDate = DateTime.now(); // Track the selected start date
  DateTime _selectedEndDate = DateTime.now(); // Track the selected end date

  List<PieChartSectionData> sections = [];
  List<Map<String, dynamic>> categoryData = [];

  // Define a list of colors for categories
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

  // PageController to manage pages
  final PageController _pageController = PageController(initialPage: 0);
  // Track the current page index
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Listen for tab changes and update data accordingly
    _tabController.addListener(() {
      if (_tabController.indexIsChanging || _tabController.index != _currentPageIndex) {
        setState(() {
          _updateData();
        });
      }
    });

    _updateData();
  }

  void _updateData() {
    DateTime startDate;
    DateTime endDate;

    switch (selectedPeriod) {
      case 'Weekly':
        // Calculate the start of the week (Sunday)
        startDate = _selectedMonth.subtract(Duration(days: _selectedMonth.weekday)); // Sunday
        // Calculate the end of the week (Saturday)
        endDate = startDate.add(Duration(days: 6)); // Saturday
        break;
      case 'Monthly':
        startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
        endDate = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
        break;
      case 'Annually':
        startDate = DateTime(_selectedMonth.year, 1, 1); // Start of the year
        endDate = DateTime(_selectedMonth.year, 12, 31); // End of the year
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

    // Fetch transactions for the selected period
    final transactions = boxTransactions.values
        .cast<Transaction>()
        .where((txn) =>
            txn.date.isAfter(startDate.subtract(Duration(days: 1))) &&
            txn.date.isBefore(endDate.add(Duration(days: 1))))
        .toList();

    // Filter transactions based on the selected tab (Income or Expenses)
    final filteredTransactions = _tabController.index == 0
        ? transactions.where((txn) => txn.type == "Income").toList()
        : transactions.where((txn) => txn.type == "Expenses").toList();

    // Update Category Data
    final categoryMap = <String, double>{};
    for (var txn in filteredTransactions) {
      categoryMap[txn.category] = (categoryMap[txn.category] ?? 0) + txn.amount;
    }

    // Assign colors to categories dynamically
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

    // Update Pie Chart Data
    sections = categoryData.map((data) {
      return PieChartSectionData(
        value: data['amount'],
        color: data['color'],
        title: '${((data['amount'] / categoryData.fold(0.0, (sum, item) => sum + item['amount'])) * 100).toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: TextStyle(
          fontSize: 14, // Adjust font size as needed
          fontWeight: FontWeight.bold,
          color: Colors.white, // Set text color to white
        ),
      );
    }).toList();

    setState(() {});
  }

  void _changeMonth(int increment) {
    if (selectedPeriod == 'Period') {
      // Do nothing for "Period" option
      return;
    }
    setState(() {
      if (selectedPeriod == 'Annually') {
        // Change the year when "Annually" is selected
        _selectedMonth = DateTime(_selectedMonth.year + increment, _selectedMonth.month, 1);
      } else if (selectedPeriod == 'Weekly') {
        // Change the week when "Weekly" is selected
        _selectedMonth = _selectedMonth.add(Duration(days: 7 * increment));
      } else {
        // Change the month for other periods
        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + increment, 1);
      }
    });
    _updateData(); // Refresh data when the month/year changes
  }

  void _toggleMonthPicker() {
    setState(() {
      _showMonthPicker = !_showMonthPicker; // Toggle visibility
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
            // Customize the dialog background color
            dialogBackgroundColor: const Color.fromARGB(255, 49, 50, 56),
            // Customize the text color
            textTheme: TextTheme(
              bodyMedium: TextStyle(color: Colors.white), // Use bodyMedium instead of bodyText2
            ),
            // Customize the selected date color
            colorScheme: ColorScheme.dark(
              primary: Colors.red, 
              onPrimary: Colors.white, 
              surface: const Color.fromARGB(255, 49, 50, 56), 
              onSurface: Colors.white, 
            ),
            // Customize the button theme
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red, // Use foregroundColor instead of primary
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
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 49, 50, 56),
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
        // Stats Page
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
        // Budget Page
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
    // Remove the currency symbol (Rs.) from the amount string
    final cleanedAmount = amount.replaceAll('Rs. ', '');

    // Parse the cleaned amount into a double
    double amountValue;
    try {
      amountValue = double.parse(cleanedAmount);
    } catch (e) {
      // If parsing fails, use a fallback value (e.g., 0.0)
      print('Error parsing amount: $e');
      amountValue = 0.0;
    }

    // Calculate the total amount of all categories
    final totalAmount = categoryData.fold(0.0, (sum, item) => sum + item['amount']);

    // Calculate the percentage for the category
    final percentage = totalAmount > 0
        ? ((amountValue / totalAmount) * 100).toStringAsFixed(1)
        : '0.0'; // Fallback if totalAmount is 0

    return ListTile(
      leading: Container(
        width: 50, // Width of the rectangle
        height: 30, // Height of the rectangle
        decoration: BoxDecoration(
          color: color, // Background color of the rectangle
          borderRadius: BorderRadius.circular(5), // Rounded corners
        ),
        child: Center(
          child: Text(
            '$percentage%', // Display the percentage
            style: TextStyle(
              color: Colors.white, // Text color
              fontSize: 12, // Text size
              fontWeight: FontWeight.bold, // Bold text
            ),
          ),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 16, // Set title font size to 16
        ),
      ),
      trailing: Text(
        amount,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14, // Set trailing font size to 14
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