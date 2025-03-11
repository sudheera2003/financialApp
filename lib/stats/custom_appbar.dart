import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String selectedPeriod;
  final DateTime selectedMonth;
  final DateTime selectedStartDate;
  final DateTime selectedEndDate;
  final Function(int) onMonthChange;
  final Function() onToggleMonthPicker;
  final Function(BuildContext) onShowDateRangePicker;
  final TabController tabController;
  final Function(String) onPeriodSelected;
  final Function(int) onPageChange;
  final int currentPageIndex;

  const CustomAppBar({
    Key? key,
    required this.selectedPeriod,
    required this.selectedMonth,
    required this.selectedStartDate,
    required this.selectedEndDate,
    required this.onMonthChange,
    required this.onToggleMonthPicker,
    required this.onShowDateRangePicker,
    required this.tabController,
    required this.onPeriodSelected,
    required this.onPageChange,
    required this.currentPageIndex,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(170); // Increased height to fix overflow

  String _getWeeklyDateRange(DateTime selectedMonth) {
    final startDate = selectedMonth.subtract(Duration(days: selectedMonth.weekday));
    final endDate = startDate.add(Duration(days: 6));
    return '${DateFormat('MMMM yyyy').format(startDate)} (${startDate.day} - ${endDate.day})';
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 49, 50, 56),
      title: Row(
        children: [
          _buildNavButton(context, 'Stats', 0),
          const SizedBox(width: 10),
          _buildNavButton(context, 'Budget', 1),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                if (selectedPeriod == 'Period') {
                  onShowDateRangePicker(context);
                } else {
                  onToggleMonthPicker();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                      onPressed: () => onMonthChange(-1),
                    ),
                    Text(
                      selectedPeriod == 'Annually'
                          ? DateFormat('yyyy').format(selectedMonth)
                          : selectedPeriod == 'Weekly'
                              ? _getWeeklyDateRange(selectedMonth)
                              : selectedPeriod == 'Period'
                                  ? '${DateFormat('MM/dd/yyyy').format(selectedStartDate)} - ${DateFormat('MM/dd/yyyy').format(selectedEndDate)}'
                                  : DateFormat('MMMM yyyy').format(selectedMonth),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.white),
                      onPressed: () => onMonthChange(1),
                    ),
                  ],
                ),
              ),
            ),
            TabBar(
              controller: tabController,
              indicatorColor: Colors.deepOrangeAccent,
              labelColor: Colors.white,
              tabs: const [
                Tab(text: 'Income'),
                Tab(text: 'Expenses'),
              ],
            ),
          ],
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: onPeriodSelected,
          itemBuilder: (BuildContext context) {
            return {'Weekly', 'Monthly', 'Annually', 'Period'}.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(
                  choice,
                  style: const TextStyle(color: Colors.white),
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
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
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
    );
  }

  Widget _buildNavButton(BuildContext context, String title, int index) {
    return GestureDetector(
      onTap: () {
        onPageChange(index); // Update the current page index
        
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: currentPageIndex == index ? Colors.deepOrangeAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: currentPageIndex == index ? Colors.deepOrangeAccent : Colors.white,
            width: 1,
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}