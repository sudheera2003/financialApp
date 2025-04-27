
import 'package:financial_app/components/add_list_item.dart';
import 'package:financial_app/components/input_dialog_box.dart';
import 'package:financial_app/data/local_database.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class IncomeList extends StatefulWidget {
  const IncomeList({ super.key });
  

  @override
  _IncomeListState createState() => _IncomeListState();
}

class _IncomeListState extends State<IncomeList> {

  final _mybox = Hive.box('mybox');
  late ItemDatabase db;

  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    db = ItemDatabase();
    // if this is the first item open the app create default data
    if (_mybox.get("INLIST") == null) {
      db.createInitialData();
    } else {
      db.loadData(); // Load existing data
    }
  }

    void saveNewItem() {
      setState(() {
        db.inList.add(_controller.text);
        _controller.clear();
      });
      Navigator.of(context).pop();
      db.updateDatabase();
    }

    void createNewItem() {
      showDialog(
        context: context, 
        builder: (context) {
          return  InputDialogBox(
            controller: _controller,
            onSave: saveNewItem,
          );
        }
      );
    }
    
    void deleteItem(int index) {
      setState(() {
        db.inList.removeAt(index);
      });
      db.updateDatabase();
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 27, 27, 29),
      appBar: AppBar(
        title: Text('Edit Incomes Categories'),
        actions: [
          IconButton(onPressed: createNewItem, icon: Icon(Icons.playlist_add,size: 27,)),
          SizedBox(width: 20,),
        ],
        backgroundColor: Color(0xFF7C4DFF),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: db.inList.length,
        itemBuilder: (context, index) {
          return AddListItem(taskName: db.inList[index],deleteFunction: () => deleteItem(index),);
        },
      ),
    );
  }
}