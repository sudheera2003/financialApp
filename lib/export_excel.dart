import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:financial_app/Calender/transaction.dart';
import 'package:financial_app/Calender/boxes.dart';

Future<void> exportToExcel({
  required BuildContext context,
  required String filterType,
  required DateTime selectedDate,
}) async {
  // Get and filter transactions
  List<Transaction> allTransactions = boxTransactions.values.cast<Transaction>().toList();
  allTransactions.sort((a, b) => a.date.compareTo(b.date));
  List<Transaction> filteredTransactions = filterType == 'month'
      ? allTransactions.where((txn) =>
          txn.date.year == selectedDate.year && txn.date.month == selectedDate.month).toList()
      : allTransactions.where((txn) => txn.date.year == selectedDate.year).toList();

  // Create a new Excel workbook
  final Workbook workbook = Workbook();
  
  // Add transactions sheet (default name is Sheet1)
  final Worksheet transactionsSheet = workbook.worksheets[0];
  // Rename the worksheet
  transactionsSheet.name = 'Financial Activities';
  
  // Add headers
  transactionsSheet.getRangeByIndex(1, 1).setText('Date');
  transactionsSheet.getRangeByIndex(1, 2).setText('Type');
  transactionsSheet.getRangeByIndex(1, 3).setText('Amount (Rs.)');
  transactionsSheet.getRangeByIndex(1, 4).setText('Category');
  transactionsSheet.getRangeByIndex(1, 5).setText('Account');
  
  // Format headers
  final Style headerStyle = workbook.styles.add('HeaderStyle');
  headerStyle.bold = true;
  headerStyle.backColor = '#4472C4';
  headerStyle.fontColor = '#FFFFFF';
  transactionsSheet.getRangeByIndex(1, 1, 1, 5).cellStyle = headerStyle;
  
  // Add transaction data
  for (int i = 0; i < filteredTransactions.length; i++) {
    final txn = filteredTransactions[i];
    transactionsSheet.getRangeByIndex(i + 2, 1).setText(DateFormat('yyyy-MM-dd').format(txn.date));
    transactionsSheet.getRangeByIndex(i + 2, 2).setText(txn.type);
    transactionsSheet.getRangeByIndex(i + 2, 3).setNumber(txn.amount);
    transactionsSheet.getRangeByIndex(i + 2, 4).setText(txn.category);
    transactionsSheet.getRangeByIndex(i + 2, 5).setText(txn.accountType);
  }
  
  // Auto-fit columns for better visibility
  transactionsSheet.autoFitColumn(1);
  transactionsSheet.autoFitColumn(2);
  transactionsSheet.autoFitColumn(3);
  transactionsSheet.autoFitColumn(4);
  transactionsSheet.autoFitColumn(5);

  // Add summary sheet
  final String summarySheetName = filterType == 'month' ? 'Monthly Summary' : 'Yearly Summary';
  final Worksheet summarySheet = workbook.worksheets.add();
  // Rename the worksheet
  summarySheet.name = summarySheetName;
  
  if (filterType == 'month') {
    // Monthly summary
    summarySheet.getRangeByIndex(1, 1).setText('Date');
    summarySheet.getRangeByIndex(1, 2).setText('Total Income (Rs.)');
    summarySheet.getRangeByIndex(1, 3).setText('Total Expense (Rs.)');
    summarySheet.getRangeByIndex(1, 1, 1, 3).cellStyle = headerStyle;
    
    int row = 2;
    for (int day = 1; day <= 31; day++) {
      try {
        DateTime dayDate = DateTime(selectedDate.year, selectedDate.month, day);
        final dayTxns = filteredTransactions.where((txn) =>
            txn.date.year == dayDate.year &&
            txn.date.month == dayDate.month &&
            txn.date.day == dayDate.day).toList();

        if (dayTxns.isEmpty) continue;

        double income = dayTxns
            .where((txn) => txn.type.toLowerCase() == 'income')
            .fold(0.0, (sum, txn) => sum + txn.amount);
        double expense = dayTxns
            .where((txn) => txn.type.toLowerCase() == 'expenses')
            .fold(0.0, (sum, txn) => sum + txn.amount);

        summarySheet.getRangeByIndex(row, 1).setText(DateFormat('yyyy-MM-dd').format(dayDate));
        summarySheet.getRangeByIndex(row, 2).setNumber(income);
        summarySheet.getRangeByIndex(row, 3).setNumber(expense);
        row++;
      } catch (_) {
        continue;
      }
    }
  } else {
    // Yearly summary
    summarySheet.getRangeByIndex(1, 1).setText('Month');
    summarySheet.getRangeByIndex(1, 2).setText('Total Income (Rs.)');
    summarySheet.getRangeByIndex(1, 3).setText('Total Expense (Rs.)');
    summarySheet.getRangeByIndex(1, 1, 1, 3).cellStyle = headerStyle;
    
    int row = 2;
    for (int month = 1; month <= 12; month++) {
      final monthTxns = filteredTransactions.where((txn) =>
          txn.date.year == selectedDate.year && txn.date.month == month).toList();

      if (monthTxns.isEmpty) continue;

      double income = monthTxns
          .where((txn) => txn.type.toLowerCase() == 'income')
          .fold(0.0, (sum, txn) => sum + txn.amount);
      double expense = monthTxns
          .where((txn) => txn.type.toLowerCase() == 'expenses')
          .fold(0.0, (sum, txn) => sum + txn.amount);

      summarySheet.getRangeByIndex(row, 1).setText(DateFormat('MMMM').format(DateTime(selectedDate.year, month)));
      summarySheet.getRangeByIndex(row, 2).setNumber(income);
      summarySheet.getRangeByIndex(row, 3).setNumber(expense);
      row++;
    }
  }
  
  // Auto-fit summary columns
  summarySheet.autoFitColumn(1);
  summarySheet.autoFitColumn(2);
  summarySheet.autoFitColumn(3);

  try {
    final directory = await getExternalStorageDirectory();
    final filename = filterType == 'month'
        ? "financial_activities_${DateFormat('yyyy_MM').format(selectedDate)}.xlsx"
        : "annual_financials_${selectedDate.year}.xlsx";
    final path = "${directory!.path}/$filename";

    // Save the workbook
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final File file = File(path);
    await file.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Excel exported: $filename")),
    );
  } catch (e) {
    workbook.dispose();
    print("❌ Failed to save file: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to export Excel file")),
    );
  }
}