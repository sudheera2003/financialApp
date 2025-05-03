import 'package:excel/excel.dart';
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
  List<Transaction> allTransactions = boxTransactions.values.cast<Transaction>().toList();

  List<Transaction> filteredTransactions = filterType == 'month'
      ? allTransactions.where((txn) =>
          txn.date.year == selectedDate.year && txn.date.month == selectedDate.month).toList()
      : allTransactions.where((txn) => txn.date.year == selectedDate.year).toList();

  var excel = Excel.createExcel(); // This creates a default 'Sheet1'
  excel.delete('Sheet1'); // Delete it to avoid confusion

  String sheetName = 'Transactions';
  Sheet sheetObject = excel[sheetName];
  excel.setDefaultSheet(sheetName); // ✅ Important

  sheetObject.appendRow(['Date', 'Type', 'Amount (Rs.)', 'Category', 'Account']);

  for (var txn in filteredTransactions) {
    sheetObject.appendRow([
      DateFormat('yyyy-MM-dd').format(txn.date),
      txn.type,
      txn.amount.toString(),
      txn.category,
      txn.accountType,
    ]);
  }

  try {
    final directory = await getExternalStorageDirectory();
    final filename = filterType == 'month'
        ? "transactions_${DateFormat('yyyy_MM').format(selectedDate)}.xlsx"
        : "transactions_${selectedDate.year}.xlsx";
    final path = "${directory!.path}/$filename";

    final fileBytes = excel.encode();
    if (fileBytes == null) {
      throw Exception("Excel encoding failed");
    }

    final file = File(path);
    await file.create(recursive: true);
    await file.writeAsBytes(fileBytes);

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Excel exported: $filename")),
    );
  } catch (e) {
    print("❌ Failed to save file: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to export Excel file")),
    );
  }
}
