import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // For charts
import 'package:intl/intl.dart'; // For DateFormat
import 'package:financial_app/Calender/transaction.dart'; // Import the Transaction class
import 'package:financial_app/Calender/boxes.dart'; // Import the boxTransactions

class CategoryDetailPage extends StatefulWidget {
  final String categoryName;
  final Color color;

  const CategoryDetailPage({
    Key? key,
    required this.categoryName,
    required this.color,
    required double amount,
  }) : super(key: key);

  @override
  _CategoryDetailPageState createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  String selectedPeriod = 'Monthly'; // Default selected period
  DateTime _selectedMonth = DateTime.now(); // Track the selected month
  DateTime _selectedStartDate = DateTime.now(); // Track the selected start date
  DateTime _selectedEndDate = DateTime.now(); // Track the selected end date
  int? _selectedIndex; // Track the selected point index

  // Add variables to track visible year range
  int _visibleStartYear = DateTime.now().year - 5; // Start year for visible range
  int _visibleEndYear = DateTime.now().year + 5; // End year for visible range

  // Add a ScrollController for horizontal scrolling
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Add a listener to detect scroll events
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        // User scrolled to the end (future years)
        _loadMoreYears(forward: true);
      } else if (_scrollController.position.pixels == _scrollController.position.minScrollExtent) {
        // User scrolled to the start (past years)
        _loadMoreYears(forward: false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the controller to avoid memory leaks
    super.dispose();
  }

  // Load more years dynamically
  void _loadMoreYears({required bool forward}) {
    setState(() {
      if (forward) {
        // Load future years
        _visibleEndYear += 5; // Extend the visible range by 5 years
      } else {
        // Load past years
        _visibleStartYear -= 5; // Extend the visible range by 5 years
      }
    });
  }

  // Fetch transactions for the selected category and period
  List<double> _getDataForPeriod() {
    final transactions = boxTransactions.values
        .cast<Transaction>()
        .where((txn) => txn.category == widget.categoryName)
        .toList();

    if (selectedPeriod == 'Annually') {
      // Fetch data for the visible year range
      final yearlyData = List<double>.filled(_visibleEndYear - _visibleStartYear + 1, 0.0);

      for (var txn in transactions) {
        final year = txn.date.year;
        if (year >= _visibleStartYear && year <= _visibleEndYear) {
          final yearIndex = year - _visibleStartYear;
          yearlyData[yearIndex] += txn.amount;
        }
      }

      return yearlyData;
    } else if (selectedPeriod == 'Weekly') {
      // Fetch data for all weeks
      final allWeeks = _getAllWeeks();
      final weeklyData = List<double>.filled(allWeeks.length, 0.0);

      for (var txn in transactions) {
        for (var i = 0; i < allWeeks.length; i++) {
          final weekRange = allWeeks[i];
          if (txn.date.isAfter(weekRange.start.subtract(Duration(days: 1))) &&
              txn.date.isBefore(weekRange.end.add(Duration(days: 1)))) {
            weeklyData[i] += txn.amount;
            break;
          }
        }
      }

      return weeklyData;
    } else {
      // Fetch data for 12 months (default behavior)
      final monthlyData = List<double>.filled(12, 0.0);

      for (var txn in transactions) {
        if (txn.date.year == _selectedMonth.year) {
          final month = txn.date.month - 1; // Convert month to index (0-11)
          monthlyData[month] += txn.amount;
        }
      }

      return monthlyData;
    }
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

  // Calculate total amount for the selected period
  double _getTotalAmountForPeriod() {
    final transactions = boxTransactions.values
        .cast<Transaction>()
        .where((txn) => txn.category == widget.categoryName)
        .toList();

    if (selectedPeriod == 'Annually') {
      // Calculate total amount for the selected year
      return transactions
          .where((txn) => txn.date.year == _selectedMonth.year)
          .fold(0.0, (sum, txn) => sum + txn.amount);
    } else if (selectedPeriod == 'Weekly') {
      // Calculate total amount for the selected week
      final allWeeks = _getAllWeeks();
      final weekIndex = _getWeekIndex(_selectedMonth);
      final weekRange = allWeeks[weekIndex];
      return transactions
          .where((txn) =>
              txn.date.isAfter(weekRange.start.subtract(Duration(days: 1))) &&
              txn.date.isBefore(weekRange.end.add(Duration(days: 1))))
          .fold(0.0, (sum, txn) => sum + txn.amount);
    } else {
      // Calculate total amount for the selected month
      return transactions
          .where((txn) =>
              txn.date.year == _selectedMonth.year &&
              txn.date.month == _selectedMonth.month)
          .fold(0.0, (sum, txn) => sum + txn.amount);
    }
  }

  // Change month, week, or year based on the selected period
  void _changeMonth(int increment) {
    if (selectedPeriod == 'Period') {
      // Do nothing for "Period" option
      return;
    }
    setState(() {
      if (selectedPeriod == 'Annually') {
        // Change the year when "Annually" is selected
        _selectedMonth = DateTime(_selectedMonth.year + increment, _selectedMonth.month, 1);

        // Update the visible year range to center the selected year
        _visibleStartYear = _selectedMonth.year - 5; // Start from 5 years before the selected year
        _visibleEndYear = _selectedMonth.year + 5; // End at 5 years after the selected year

        // Update selected index for annual view
        _selectedIndex = 5; // Center the selected year in the visible range
      } else if (selectedPeriod == 'Weekly') {
        // Change the week when "Weekly" is selected
        _selectedMonth = _selectedMonth.add(Duration(days: 7 * increment)); // Increment or decrement by 7 days
        _selectedIndex = _getWeekIndex(_selectedMonth); // Update selected index for weekly view
      } else {
        // Change the month for other periods
        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + increment, 1);
        _selectedIndex = _selectedMonth.month - 1; // Update selected index for monthly view
      }

      // Scroll to the selected point after changing the period
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_selectedIndex != null) {
          final double scrollPosition = _selectedIndex! * 100; // Adjust based on your data point width
          _scrollController.animateTo(
            scrollPosition,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    });
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

  // Get the weekly date range
  String _getWeeklyDateRange(DateTime date) {
    final allWeeks = _getAllWeeks();
    final weekIndex = _getWeekIndex(date);
    final weekRange = allWeeks[weekIndex];
    return '${DateFormat('MMMM yyyy').format(weekRange.start)} (${weekRange.start.day} - ${weekRange.end.day})';
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
    }
  }

  // Helper method to create spots for the line chart
  

  List<FlSpot> _createSpots() {
    var data = _getDataForPeriod();
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value;
      return FlSpot(index.toDouble(), value); // x is double, y is double
    }).toList();
  }

// Helper method to get the account type for the selected category
String _getAccountTypeForCategory() {
  final transactions = boxTransactions.values
      .cast<Transaction>()
      .where((txn) => txn.category == widget.categoryName)
      .toList();

  if (transactions.isNotEmpty) {
    // Filter transactions based on the selected period
    List<Transaction> filteredTransactions = [];

    if (selectedPeriod == 'Annually') {
      // Filter transactions for the selected year
      filteredTransactions = transactions
          .where((txn) => txn.date.year == _selectedMonth.year)
          .toList();
    } else if (selectedPeriod == 'Weekly') {
      // Filter transactions for the selected week
      final allWeeks = _getAllWeeks();
      final weekIndex = _getWeekIndex(_selectedMonth);
      final weekRange = allWeeks[weekIndex];
      filteredTransactions = transactions
          .where((txn) =>
              txn.date.isAfter(weekRange.start.subtract(Duration(days: 1))) &&
              txn.date.isBefore(weekRange.end.add(Duration(days: 1))))
          .toList();
    } else {
      // Filter transactions for the selected month
      filteredTransactions = transactions
          .where((txn) =>
              txn.date.year == _selectedMonth.year &&
              txn.date.month == _selectedMonth.month)
          .toList();
    }

    if (filteredTransactions.isNotEmpty) {
      // Return the account type of the most recent transaction in the filtered list
      filteredTransactions.sort((a, b) => b.date.compareTo(a.date)); // Sort by date (most recent first)
      return filteredTransactions.first.accountType;
    }
  }

  return 'No Account Type'; // Default value if no transactions are found
}

@override
Widget build(BuildContext context) {
  final totalAmount = _getTotalAmountForPeriod();
  final spots = _createSpots();
  final accountType = _getAccountTypeForCategory(); // Fetch the account type

  // Calculate the maximum Y value from the spots
  final maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);

  return Scaffold(
    backgroundColor: const Color.fromARGB(255, 49, 50, 56),
    appBar: AppBar(
      backgroundColor: const Color.fromARGB(255, 49, 50, 56),
      title: Text(widget.categoryName),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(60), // Adjust height as needed
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
                          ? DateFormat('yyyy').format(_selectedMonth) // Display only the year for "Annually"
                          : selectedPeriod == 'Weekly'
                              ? _getWeeklyDateRange(_selectedMonth) // Display weekly date range
                              : selectedPeriod == 'Period'
                                  ? '${DateFormat('MM/dd/yyyy').format(_selectedStartDate)} - ${DateFormat('MM/dd/yyyy').format(_selectedEndDate)}' // Display date range for "Period"
                                  : DateFormat('MMMM yyyy').format(_selectedMonth), // Display full month and year for other periods
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
          ],
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (String value) {
            setState(() {
              selectedPeriod = value;
              _selectedIndex = null; // Reset selected index when period changes
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
    body: Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Line Chart Section
          Container(
            height: 300, // Increased container height
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 39, 40, 46),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20, top: 20, left: 20, right: 20), // Adjusted padding
              child: SingleChildScrollView(
                controller: _scrollController, // Attach the ScrollController
                scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                child: SizedBox(
                  width: spots.length * 100, // Adjust width based on the number of data points
                  child: Stack(
                    children: [
                      LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (selectedPeriod == 'Weekly') {
                                    // Display week ranges for "Weekly"
                                    final allWeeks = _getAllWeeks();
                                    if (value.toInt() < allWeeks.length) {
                                      final weekRange = allWeeks[value.toInt()];
                                      return Transform.rotate(
                                        angle: -0.5, // Rotate labels
                                        child: Container(
                                          margin: const EdgeInsets.only(top: 10),
                                          child: Text(
                                            '${DateFormat('MM/dd').format(weekRange.start)} - ${DateFormat('MM/dd').format(weekRange.end)}',
                                            style: TextStyle(color: Colors.white, fontSize: 8), // Reduced font size
                                          ),
                                        ),
                                      );
                                    }
                                  } else if (selectedPeriod == 'Annually') {
                                    // Display years for "Annually"
                                    final year = _visibleStartYear + value.toInt();
                                    return Container(
                                      margin: const EdgeInsets.only(top: 20),
                                      child: Text(
                                        year.toString(),
                                        style: TextStyle(color: Colors.white, fontSize: 10),
                                      ),
                                    );
                                  } else if (selectedPeriod == 'Monthly') {
                                    // Display months for other periods
                                    final months = [
                                      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                                    ];
                                    return Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      child: Text(
                                        months[value.toInt()],
                                        style: TextStyle(color: Colors.white, fontSize: 10),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                                reservedSize: 30, // Space for labels
                                interval: 1, // Ensure each week is represented
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false), // Disable left titles
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: widget.color,
                              barWidth: 2,
                              belowBarData: BarAreaData(
                                show: true,
                                color: widget.color.withOpacity(0.1),
                              ),
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 3,
                                    color: widget.color,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Add custom label for the selected point
                      if (_selectedIndex != null && _selectedIndex! < spots.length)
                        Positioned(
                          left: (spots[_selectedIndex!].x / (spots.length - 1)) * (spots.length * 100 - 40),
                          top: 250 - (spots[_selectedIndex!].y / maxY) * 200 - 20,
                          child: Text(
                            spots[_selectedIndex!].y.toStringAsFixed(2),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 30),

          // Details Section
          Text(
            'Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 39, 40, 46),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _buildDetailRow('Category', widget.categoryName, accountType: accountType), // Pass the fetched account type
                SizedBox(height: 10),
                _buildDetailRow(
                  selectedPeriod == 'Annually' ? 'Annual Amount' : 'Monthly Amount',
                  'Rs. ${totalAmount.toStringAsFixed(2)}',
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// Helper method to build a detail row
Widget _buildDetailRow(String label, String value, {String? accountType}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
      if (accountType != null) // Display account type if provided
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            'Account: $accountType',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ),
    ],
  );
}
}