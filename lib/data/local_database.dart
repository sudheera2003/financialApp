import 'package:hive/hive.dart';

class ItemDatabase {
  // Lists to store income and expense categories
  List<String> itemList = []; // List for expenses
  List<String> inList = []; // List for incomes

  // Hive box to store data
  final _mybox = Hive.box('mybox');

  // Initialize the database
  void createInitialData() {
    // Default expense categories
    itemList = [
      'Food',
      'Social life',
    ];

    // Default income categories
    inList = [
      'Salary',
      'Gifts',
    ];

    // Save the initial data to Hive
    updateDatabase();
  }

  // Load data from Hive
  void loadData() {
    itemList = _mybox.get("ITEMLIST", defaultValue: []).cast<String>();
    inList = _mybox.get("INLIST", defaultValue: []).cast<String>();
  }


  void updateDatabase() {
    _mybox.put("ITEMLIST", itemList);
    _mybox.put("INLIST", inList);
  }


  void addExpenseCategory(String category) {
    itemList.add(category);
    updateDatabase();
  }


  void addIncomeCategory(String category) {
    inList.add(category);
    updateDatabase();
  }


  void removeExpenseCategory(int index) {
    if (index >= 0 && index < itemList.length) {
      itemList.removeAt(index);
      updateDatabase();
    }
  }


  void removeIncomeCategory(int index) {
    if (index >= 0 && index < inList.length) {
      inList.removeAt(index);
      updateDatabase();
    }
  }

  void clearExpenseCategories() {
    itemList.clear();
    updateDatabase();
  }

  void clearIncomeCategories() {
    inList.clear();
    updateDatabase();
  }
}