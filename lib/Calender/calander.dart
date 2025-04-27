import 'package:financial_app/Calender/dailyView.dart';
import 'package:financial_app/Calender/monthlyView.dart';
import 'package:financial_app/dashboard_page.dart';
import 'package:financial_app/navigation_menu.dart';
import 'package:flutter/material.dart';
import 'package:financial_app/Calender/boxes.dart';
import 'package:financial_app/Calender/mainForm.dart';
import 'package:financial_app/Calender/modelHelper.dart';
import 'package:financial_app/Calender/transaction.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:table_calendar/table_calendar.dart';

class ComplexTable extends StatefulWidget {
  final int initialTab;
  const ComplexTable({super.key, required this.initialTab});

  @override
  State<ComplexTable> createState() => _ComplexTableState();
}

class _ComplexTableState extends State<ComplexTable> with SingleTickerProviderStateMixin{
  DateTime _selectedMonth = DateTime.now();
  final Set<DateTime> _selectedDays = {};
  final CalendarController _calendarController = CalendarController();
  bool _showMonthPicker = false; 
  int _selectedYear = DateTime.now().year; 
  late TabController _tabController;
  

  @override
  void initState() {
    super.initState();
    _calendarController.displayDate = _selectedMonth;
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTab);
    
    // Add a listener to the TabController
    _tabController.addListener(() {
      print("Tab changed to index: ${_tabController.index}"); // Debugging
      setState(() {}); // Force the UI to rebuild
    });
  }

  @override
  void dispose() {
    // Remove the listener when the widget is disposed
    _tabController.removeListener(() {});
    _tabController.dispose();
    super.dispose();
  }

  void _changeMonth(int increment) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + increment, 1);
      _selectedYear = _selectedMonth.year;
      _calendarController.displayDate = _selectedMonth;
    });
  }

  void _onDaySelected(DateTime selectedDay) {
    DateTime normalizedDate = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    
    setState(() {
      if (_selectedDays.contains(normalizedDate)) {
        _selectedDays.remove(normalizedDate);
      } else {
        _selectedDays.add(normalizedDate);
      }
    });

    List<Transaction> transactions = boxTransactions.values
        .cast<Transaction>()
        .where((txn) => isSameDay(txn.date, normalizedDate))
        .toList();

    ModalHelper.showBottomSheetEvents(
      context,
      transactions,
      normalizedDate,
      onClose: () {
        setState(() {
          // This will refresh the calendar when the bottom sheet is closed
        });
      },
    );
  }

  String _incomeSet(DateTime date) {
    List<Transaction> transactions = boxTransactions.values
        .cast<Transaction>()
        .where((txn) => isSameDay(txn.date, date) && txn.type == "Income")
        .toList();

    if (transactions.isNotEmpty) {
      double totalIncome = transactions.fold(0.0, (sum, txn) => sum + txn.amount);

      return totalIncome.toStringAsFixed(2); 
    } else {
      return '';
    }
  }

  String _expensesSet(DateTime date) {
    List<Transaction> transactions = boxTransactions.values
        .cast<Transaction>()
        .where((txn) => isSameDay(txn.date, date) && txn.type == "Expenses")
        .toList();

    if (transactions.isNotEmpty) {
      double totalExpenses = transactions.fold(0.0, (sum, txn) => sum + txn.amount);

      return totalExpenses.toStringAsFixed(2); 
    } else {
      return '';
    }
  }
  double _calculateMonthlyIncome(DateTime month) {
    List<Transaction> transactions = boxTransactions.values
        .cast<Transaction>()
        .where((txn) =>
            txn.date.year == month.year &&
            txn.date.month == month.month &&
            txn.type == "Income")
        .toList();
    if(transactions.isNotEmpty){
      return transactions.fold(0.0, (sum, txn) => sum + txn.amount);
    }else{
      return 0.00;
    }
  }

  double _calculateMonthlyExpenses(DateTime month) {
    List<Transaction> transactions = boxTransactions.values
        .cast<Transaction>()
        .where((txn) =>
            txn.date.year == month.year &&
            txn.date.month == month.month &&
            txn.type == "Expenses")
        .toList();

    if(transactions.isNotEmpty){
      return transactions.fold(0.0, (sum, txn) => sum + txn.amount);
    }else{
      return 0.00;
    }
  }

  double _calculateMonthlyNetTotal(DateTime month) {
    double income = _calculateMonthlyIncome(month);
    double expenses = _calculateMonthlyExpenses(month);
    return income - expenses;
  }

    double _calculateAnnualIncome(DateTime month) {
    List<Transaction> transactions = boxTransactions.values
        .cast<Transaction>()
        .where((txn) =>
            txn.date.year == month.year &&
            txn.type == "Income")
        .toList();
    if(transactions.isNotEmpty){
      return transactions.fold(0.0, (sum, txn) => sum + txn.amount);
    }else{
      return 0.00;
    }
  }

  double _calculateAnnualExpenses(DateTime month) {
    List<Transaction> transactions = boxTransactions.values
        .cast<Transaction>()
        .where((txn) =>
            txn.date.year == month.year &&
            txn.type == "Expenses")
        .toList();

    if(transactions.isNotEmpty){
      return transactions.fold(0.0, (sum, txn) => sum + txn.amount);
    }else{
      return 0.00;
    }
  }

  double _calculateAnnualNetTotal(DateTime month) {
    double income = _calculateAnnualIncome(month);
    double expenses = _calculateAnnualExpenses(month);
    return income - expenses;
  }


  void _toggleMonthPicker() {
    setState(() {
      _showMonthPicker = !_showMonthPicker; 
    });
  }

  void _changeYear(int increment) {
    setState(() {
      _selectedYear += increment; // Increment or decrement the year
    });
  }

  List<Map<String, dynamic>> _createListForDailyView(DateTime month) {
  List<Transaction> transactions = boxTransactions.values
      .cast<Transaction>()
      .where((txn) =>
          txn.date.year == month.year &&
          txn.date.month == month.month)
      .toList();
  transactions.sort((a, b) => b.date.compareTo(a.date));

  List<Map<String, dynamic>> transactionList = transactions.map((txn) {
    return {
      'date': txn.date.toIso8601String(),
      'category': txn.category,
      'accountType': txn.accountType,
      'income': txn.type=="Income"?txn.amount:0.0,
      'expense': txn.type=="Expenses"?txn.amount:0.0,
    };
  }).toList();

  return transactionList;
}

 List<Map<String, dynamic>> _createListForMonthlyView(DateTime month) {
  List<Transaction> transactions = boxTransactions.values
      .cast<Transaction>()
      .where((txn) => txn.date.year == month.year)
      .toList();

  Map<int, Map<String, dynamic>> monthlyData = {};

  for (int month = 1; month <= 12; month++) {
    monthlyData[month] = {
      'month': month,
      'income': 0.0,
      'expense': 0.0,
    };
  }

  for (var txn in transactions) {
    int month = txn.date.month;
    if (txn.type == "Income") {
      monthlyData[month]!['income'] += txn.amount;
    } else if (txn.type == "Expenses") {
      monthlyData[month]!['expense'] += txn.amount;
    }
  }

  List<Map<String, dynamic>> transactionList = monthlyData.values.toList();

  transactionList.sort((a, b) => a['month'].compareTo(b['month']));

  return transactionList;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 49, 50, 56),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Color.fromARGB(255, 255, 255, 255),),
        title: Text('Calender', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 49, 50, 56),
        automaticallyImplyLeading: false, // Disable default back arrow
        leading: 
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white,), // You can use any icon
            onPressed: () {
              // Navigate wherever you want
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const NavigationMenu()),
                (route) => false,
              );
              // or Navigator.pop(context); or any custom function
            },
          ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF7C4DFF),
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MainForm(initialTab: 1), 
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white,),
      ),
      body: Stack(
        children: [
          
          Column(
            children: [
              Visibility(
                visible: _tabController.index != 2, // Hide for Monthly View tab
                child: GestureDetector(
                  onTap: _toggleMonthPicker, // Open month picker
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, color: Colors.white),
                          onPressed: () => _changeMonth(-1), // Navigate to the previous month
                        ),
                        Text(
                          DateFormat('MMMM yyyy').format(_selectedMonth), // Show full month and year
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Colors.white),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, color: Colors.white),
                          onPressed: () => _changeMonth(1), // Navigate to the next month
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Widget for Monthly View Tab
            Visibility(
              visible: _tabController.index == 2, // Show only for Monthly View tab
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _selectedMonth = DateTime(_selectedMonth.year - 1, 1); // Go to the previous year
                          _calendarController.displayDate = _selectedMonth;
                        });
                      },
                    ),
                    Text(
                      DateFormat('yyyy').format(_selectedMonth), // Show only the year
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _selectedMonth = DateTime(_selectedMonth.year + 1, 1); // Go to the next year
                          _calendarController.displayDate = _selectedMonth;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),


            Expanded(
              child: DefaultTabController(
                length: 3, 
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController, 
                      labelColor: Colors.white,
                      indicatorColor: Color(0xFF7C4DFF),
                      tabs: const [
                        Tab(text: "Daily View"),
                        Tab(text: "Calendar"),
                        Tab(text: "Monthly View"),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController, 
                        children: [
                          // Daily View
                          Column(
                            children: [
                              // Calendar Header (Income, Expenses, Total)
                              Container(
                                color: const Color.fromARGB(255, 49, 50, 56),
                                height: 60,
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        children: [
                                          const Text("Income", style: TextStyle(color: Colors.white, fontSize: 16)),
                                          Text(
                                            _calculateMonthlyIncome(_selectedMonth).toStringAsFixed(2),
                                            style: const TextStyle(color: Colors.blue, fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const Text("Exp.", style: TextStyle(color: Colors.white, fontSize: 16)),
                                          Text(
                                            _calculateMonthlyExpenses(_selectedMonth).toStringAsFixed(2),
                                            style: const TextStyle(color: Colors.red, fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const Text("Total", style: TextStyle(color: Colors.white, fontSize: 16)),
                                          Text(
                                            _calculateMonthlyNetTotal(_selectedMonth).toStringAsFixed(2),
                                            style: const TextStyle(color: Colors.white, fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                                  Divider(thickness: 1, height: 3, color: const Color.fromARGB(255, 112, 112, 112)),
                              Expanded(
                                child: DailyViewPage(
                                  transactions: _createListForDailyView(_selectedMonth),
                                ),
                              ),
                            ],
                          ),
                          // Calendar View
                          Stack(
                            children: [
                              Column(
                                children: [
                                  // Calendar Header (Income, Expenses, Total)
                                  Container(
                                    color: const Color.fromARGB(255, 49, 50, 56),
                                    height: 60,
                                    width: double.infinity,
                                    child: Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Column(
                                            children: [
                                              Text("Income", style: TextStyle(color: Colors.white, fontSize: 16)),
                                              Text(
                                                _calculateMonthlyIncome(_selectedMonth).toStringAsFixed(2),
                                                style: TextStyle(color: Colors.blue, fontSize: 14),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Text("Exp.", style: TextStyle(color: Colors.white, fontSize: 16)),
                                              Text(
                                                _calculateMonthlyExpenses(_selectedMonth).toStringAsFixed(2),
                                                style: TextStyle(color: Colors.red, fontSize: 14),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Text("Total", style: TextStyle(color: Colors.white, fontSize: 16)),
                                              Text(
                                                _calculateMonthlyNetTotal(_selectedMonth).toStringAsFixed(2),
                                                style: TextStyle(color: Colors.white, fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Divider(thickness: 1, height: 3, color: const Color.fromARGB(255, 112, 112, 112)),
                                  // Calendar
                                  Expanded(
                                    child: SfCalendar(
                                      viewHeaderHeight: 0,
                                      todayHighlightColor: Colors.black,
                                      controller: _calendarController,
                                      view: CalendarView.month,
                                      onViewChanged: (ViewChangedDetails details) {
                                        final DateTime newDate = details.visibleDates[details.visibleDates.length ~/ 2];
                                        if (newDate.month != _selectedMonth.month || newDate.year != _selectedMonth.year) {
                                          setState(() {
                                            _selectedMonth = DateTime(newDate.year, newDate.month, 1);
                                          });
                                        }
                                      },
                                      selectionDecoration: BoxDecoration(
                                        border: Border.all(color: Colors.white, width: 1),
                                        shape: BoxShape.rectangle,
                                      ),
                                      headerHeight: 0,
                                      onTap: (CalendarTapDetails details) {
                                        if (details.date != null) {
                                          _onDaySelected(details.date!);
                                        }
                                      },
                                      monthCellBuilder: (BuildContext context, MonthCellDetails details) {
                      
                                        // Get the first and last day of the current month
                                        DateTime firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
                                        DateTime lastDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
                            
                                        // Determine if the date is a leading or trailing date
                                        bool isLeadingDate = details.date.isBefore(firstDayOfMonth);
                                        bool isTrailingDate = details.date.isAfter(lastDayOfMonth);
                            
                                        // Determine background color based on date type
                                        Color backgroundColor;
                                        FontWeight fontWeight;
                                        if (isLeadingDate || isTrailingDate) {
                                          backgroundColor = const Color.fromARGB(255, 33, 34, 38); // Out-of-month dates
                                          fontWeight = FontWeight.w300;
                                        } else {
                                          backgroundColor = const Color.fromARGB(255, 49, 50, 56); // Current month dates
                                          fontWeight = FontWeight.w500;
                                        }
                            
                                        // Check if the current cell's date is today's date
                                        bool isToday = isSameDay(details.date, DateTime.now());
                            
                                        // Determine text color based on the day of the week
                                        Color textColor = Colors.white; // Default text color
                                        if (details.date.weekday == DateTime.saturday) {
                                          textColor = Colors.blue; // Saturday text color
                                        } else if (details.date.weekday == DateTime.sunday) {
                                          textColor = Colors.red; // Sunday text color
                                        }
                            
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: backgroundColor, // Set background color
                                            border: Border.all(
                                              color: const Color.fromARGB(255, 0, 0, 0), // Border color
                                              width: 0.5, // Border width (adjust as needed)
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              // Date in the top-left corner
                                              Container(
                                                color: isToday ? const Color.fromARGB(255, 255, 255, 255) : Colors.transparent,
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(8, 4, 0, 4), // Adjust the padding as needed
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        details.date.day.toString(),
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight: fontWeight,
                                                          color: isToday?Colors.black:textColor, // Use textColor for Saturday/Sunday
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                            
                                              // Income and Expense in the bottom-right corner
                                              Positioned(
                                                bottom: 7,
                                                right: 7,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      _incomeSet(details.date),
                                                      style: TextStyle(
                                                        color: const Color.fromARGB(255, 70, 111, 215), 
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                    Text(
                                                      _expensesSet(details.date),
                                                      style: TextStyle(
                                                        color: Colors.red, 
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      monthViewSettings: MonthViewSettings(
                                        dayFormat: 'EEE',
                                        appointmentDisplayMode: MonthAppointmentDisplayMode.none,
                                        showTrailingAndLeadingDates: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Monthly View
                          Column(
                            children: [
                              // Calendar Header (Income, Expenses, Total)
                              Container(
                                color: const Color.fromARGB(255, 49, 50, 56),
                                height: 60,
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        children: [
                                          const Text("Income", style: TextStyle(color: Colors.white, fontSize: 16)),
                                          Text(
                                            _calculateAnnualIncome(_selectedMonth).toStringAsFixed(2),
                                            style: const TextStyle(color: Colors.blue, fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const Text("Exp.", style: TextStyle(color: Colors.white, fontSize: 16)),
                                          Text(
                                            _calculateAnnualExpenses(_selectedMonth).toStringAsFixed(2),
                                            style: const TextStyle(color: Colors.red, fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const Text("Total", style: TextStyle(color: Colors.white, fontSize: 16)),
                                          Text(
                                            _calculateAnnualNetTotal(_selectedMonth).toStringAsFixed(2),
                                            style: const TextStyle(color: Colors.white, fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                                  Divider(thickness: 1, height: 3, color: const Color.fromARGB(255, 112, 112, 112)),
                              Expanded(
                                child: MonthlyViewPage(
                                  transactions: _createListForMonthlyView(_selectedMonth),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Month Picker Overlay
        if (_showMonthPicker)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleMonthPicker, // Close the month picker when tapping outside
              child: Container(
                color: Colors.black.withOpacity(0.5), // Semi-transparent background
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 60), // Adjust position
                  padding: const EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 56, 56, 56),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left, color: Colors.white),
                            onPressed: () => _changeYear(-1),
                          ),
                          Text(
                            _selectedYear.toString(),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.white),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right, color: Colors.white),
                            onPressed: () => _changeYear(1),
                          ),
                        ],
                      ),
                      const Divider(thickness: 1, color: Color.fromARGB(255, 112, 112, 112)),
                      GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 1.5,
                        ),
                        itemCount: 12,
                        itemBuilder: (context, index) {
                          DateTime month = DateTime(_selectedYear, index + 1, 1);
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedMonth = month;
                                _calendarController.displayDate = _selectedMonth;
                                _showMonthPicker = false; // Close after selection
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                DateFormat('MMM').format(month),
                                style: TextStyle(
                                  color: month.month == _selectedMonth.month ? Colors.red : Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
}