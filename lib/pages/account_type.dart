import 'package:flutter/material.dart';
import 'package:financial_app/components/add_list_item.dart';
import 'package:financial_app/components/input_dialog_box.dart';
import 'package:financial_app/data/local_database.dart';
import 'package:hive/hive.dart';

class AccountList extends StatefulWidget {
  const AccountList({super.key});

  @override
  _AccountListState createState() => _AccountListState();
}

class _AccountListState extends State<AccountList> {
  final _mybox = Hive.box('mybox');
  late ItemDatabase db;

  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    db = ItemDatabase();

    if (_mybox.get("ACCOUNTLIST") == null) {
      db.createInitialData();
    } else {
      db.loadData();
    }
  }

  void saveNewItem() {
    setState(() {
      db.accountList.add(_controller.text);
      _controller.clear();
    });
    Navigator.of(context).pop();
    db.updateDatabase();
  }

  void createNewItem() {
    showDialog(
      context: context,
      builder: (context) {
        return InputDialogBox(
          controller: _controller,
          onSave: saveNewItem,
        );
      },
    );
  }

  void deleteItem(int index) {
    setState(() {
      db.accountList.removeAt(index);
    });
    db.updateDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 27, 27, 29),
      appBar: AppBar(
        title: const Text('Edit Account Types'),
        actions: [
          IconButton(
            onPressed: createNewItem,
            icon: const Icon(Icons.playlist_add, size: 27),
          ),
          const SizedBox(width: 20),
        ],
        backgroundColor: Color(0xFF7C4DFF),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: db.accountList.length,
        itemBuilder: (context, index) {
          return AddListItem(
            taskName: db.accountList[index],
            deleteFunction: () => deleteItem(index),
          );
        },
      ),
    );
  }
}