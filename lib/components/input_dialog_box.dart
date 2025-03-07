import 'package:flutter/material.dart';

class InputDialogBox extends StatefulWidget {

  final TextEditingController controller;
  VoidCallback onSave;

  InputDialogBox({super.key, required this.controller,required this.onSave}); 

  @override
  _InputDialogBoxState createState() => _InputDialogBoxState();
}

class _InputDialogBoxState extends State<InputDialogBox> {

  @override
  Widget build(BuildContext context,) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: AlertDialog(
        backgroundColor: const Color.fromARGB(255, 27, 27, 29),
        content: SizedBox(
          height: 200,
          // width: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: const Text(
                  'Add Expenses',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: widget.controller,
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepOrangeAccent),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepOrangeAccent),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.controller.clear();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: widget.onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save'),
                  ),
                  
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
