import 'package:flutter/material.dart';

class AddListItem extends StatefulWidget {
  String taskName;
  VoidCallback deleteFunction;

  AddListItem({ super.key, required this.taskName, required this.deleteFunction });

  @override
  _AddListItemState createState() => _AddListItemState();
}

class _AddListItemState extends State<AddListItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
        color: const Color.fromARGB(255, 35, 35, 37),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              IconButton(onPressed: widget.deleteFunction, icon: Icon(Icons.do_not_disturb_on, color: Colors.redAccent,)),
              SizedBox(width: 20,),
              Text(widget.taskName,style: TextStyle(color: Colors.white),),
            ],
          ),
        ),
      ),
    );
  }
}