import 'package:hive/hive.dart';

class ItemDatabase {
  List itemList = []; // list for expences
  List inList = []; // list for incomes
  final _mybox = Hive.box('mybox');

  void createInitialData() {
      itemList = [
      'Food',
      'Social life',
    ];

    inList = [
      'Salary',
      'Gifts',
    ];
    updateDatabase();
  }

  void loadData() {
      itemList = _mybox.get("ITEMLIST");
      inList = _mybox.get("INLIST");
  }

  void updateDatabase() {
      _mybox.put("ITEMLIST", itemList);
      _mybox.put("INLIST", inList);
  }

}