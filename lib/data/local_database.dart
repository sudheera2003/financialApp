import 'package:hive/hive.dart';

class ItemDatabase {
  // Lists to store income, expense, and account categories
  List<String> itemList = []; // List for expenses
  List<String> inList = []; // List for incomes
  List<String> accountList = []; // List for accounts

  // Hive box to store data
  final _mybox = Hive.box('mybox');

  // Initialize the database
  void createInitialData() {
    // Default expense categories
    itemList = [
      'Food',
      'Social life',
      'Pets',
      'Transport',
      'Culture',
      'Household',
      'Apparel',
      'Beauty',
      'Health',
      'Education',
      'Gifts',
      'other',
    ];

    // Default income categories
    inList = [
      'Allowance',
      'Salary',
      'Petty cash',
      'Bonus',
      'other',
    ];

    // Default account types
    accountList = [
      'Cash',
      'Accounts',
      'Card',
    ];

    // Save the initial data to Hive
    updateDatabase();
  }

  // Load data from Hive
void loadData() {
  if (_mybox.get("ITEMLIST") == null || _mybox.get("INLIST") == null || _mybox.get("ACCOUNTLIST") == null) {
    // First time ever opening the app
    createInitialData();
  } else {
    // Data already exists
    itemList = _mybox.get("ITEMLIST", defaultValue: []).cast<String>();
    inList = _mybox.get("INLIST", defaultValue: []).cast<String>();
    accountList = _mybox.get("ACCOUNTLIST", defaultValue: []).cast<String>();
  }
}


  // Update the database with current lists
  void updateDatabase() {
    _mybox.put("ITEMLIST", itemList);
    _mybox.put("INLIST", inList);
    _mybox.put("ACCOUNTLIST", accountList);
  }

  // Add a new expense category
  void addExpenseCategory(String category) {
    itemList.add(category);
    updateDatabase();
  }

  // Add a new income category
  void addIncomeCategory(String category) {
    inList.add(category);
    updateDatabase();
  }

  // Add a new account type
  void addAccountCategory(String account) {
    accountList.add(account);
    updateDatabase();
  }

  // Remove an expense category by index
  void removeExpenseCategory(int index) {
    if (index >= 0 && index < itemList.length) {
      itemList.removeAt(index);
      updateDatabase();
    }
  }

  // Remove an income category by index
  void removeIncomeCategory(int index) {
    if (index >= 0 && index < inList.length) {
      inList.removeAt(index);
      updateDatabase();
    }
  }


  void removeAccountCategory(int index) {
    if (index >= 0 && index < accountList.length) {
      accountList.removeAt(index);
      updateDatabase();
    }
  }

  // Clear all expense categories
  void clearExpenseCategories() {
    itemList.clear();
    updateDatabase();
  }

  // Clear all income categories
  void clearIncomeCategories() {
    inList.clear();
    updateDatabase();
  }

  // Clear all account types
  void clearAccountCategories() {
    accountList.clear();
    updateDatabase();
  }
}