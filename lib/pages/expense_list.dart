
import 'package:financial_app/components/add_list_item.dart';
import 'package:financial_app/components/input_dialog_box.dart';
import 'package:financial_app/data/local_database.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ExpenseList extends StatefulWidget {
  const ExpenseList({ super.key });
  

  @override
  _ExpenseListState createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {

  final _mybox = Hive.box('mybox');
  ItemDatabase db = ItemDatabase();

  @override
  void initState() {
    // if this is the first item open the app create default data
    if(_mybox.get("ITEMLIST") == null){
      db.createInitialData();
    }else{
      db.loadData();
    }
  }
  
  final _controller = TextEditingController();

  
    // List itemList = [
    //   'Food',
    //   'Social life',
    // ];

    void saveNewItem() {
      setState(() {
        db.itemList.add(_controller.text);
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
        db.itemList.removeAt(index);
      });
      db.updateDatabase();
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 27, 27, 29),
      appBar: AppBar(
        title: Text('Edit Expenses Categories'),
        actions: [
          IconButton(onPressed: createNewItem, icon: Icon(Icons.playlist_add,size: 27,)),
          SizedBox(width: 20,),
        ],
        backgroundColor: Colors.deepOrangeAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: db.itemList.length,
        itemBuilder: (context, index) {
          return AddListItem(taskName: db.itemList[index],deleteFunction: () => deleteItem(index),);
        },
      ),
    );
  }
}