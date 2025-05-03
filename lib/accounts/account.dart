import 'package:financial_app/export_excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:financial_app/accounts/accCard.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  DateTime _selectedMonth = DateTime.now(); 
  int _selectedYear = DateTime.now().year;
  bool _showMonthPicker = false; 
  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + delta);
    });
  }
  void _changeYear(int delta) {
    setState(() {
      _selectedYear += delta; 
    });
  }

  void _toggleMonthPicker() {
    setState(() {
      _showMonthPicker = !_showMonthPicker; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color.fromARGB(255, 27, 27, 29),
      appBar: AppBar(
        title: Text('Accounts', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 27, 27, 29),
      ),
      body: Container(
        color: const Color.fromARGB(255, 27, 27, 29),
        child: Stack(
          children: [
            Column(
          children: [
            GestureDetector(
              onTap: _toggleMonthPicker, // Toggle month picker visibility
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                      onPressed: () => _changeMonth(-1), // Move to previous month
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(_selectedMonth), // Format the selected month/year
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.white),
                      onPressed: () => _changeMonth(1), // Move to next month
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: AccCard(selectedMonth: _selectedMonth), 
            ),
            SizedBox(
                    width: 220,
                    child: ElevatedButton(
                      onPressed: () {
                        _showExportOptions(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF7C4DFF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      child: Text("Export Data"),
                    )
            )
          ],
        ),
        if (_showMonthPicker)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleMonthPicker, 
              child: Container(
                color: Colors.black.withOpacity(0.2), 
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 60), 
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
      )
      ),
    );
  }

    void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromARGB(255, 56, 56, 56),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.calendar_month, color: Colors.white),
              title: Text("Export Selected Month", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                exportToExcel(filterType: 'month', selectedDate: _selectedMonth, context: context);
              },
            ),
            ListTile(
              leading: Icon(Icons.date_range, color: Colors.white),
              title: Text("Export Selected Year", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                exportToExcel(filterType: 'year', selectedDate: DateTime(_selectedYear), context: context);
              },
            ),
          ],
        );
      },
    );
  }
}


