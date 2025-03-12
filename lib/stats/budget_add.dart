import 'package:flutter/material.dart';

class BudgetAdd extends StatefulWidget {
  final String category;
  final Function(double amount) onSave;

  const BudgetAdd({
    super.key,
    required this.category,
    required this.onSave,
  });

  @override
  _BudgetAddState createState() => _BudgetAddState();
}

class _BudgetAddState extends State<BudgetAdd> {
  String amount = '0';
  final TextEditingController _amountController = TextEditingController();

  void _updateAmount(String value) {
    setState(() {
      if (amount == '0') {
        amount = value;
      } else {
        amount += value;
      }
      _amountController.text = amount;
    });
  }

  void _clearAmount() {
    setState(() {
      amount = '0';
      _amountController.text = amount;
    });
  }

  void _deleteLastDigit() {
    setState(() {
      if (amount.length > 1) {
        amount = amount.substring(0, amount.length - 1);
      } else {
        amount = '0';
      }
      _amountController.text = amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.category,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.none,
                decoration: InputDecoration(
                  hintText: 'Enter Amount',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[700],
                ),
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
                readOnly: true,
              ),
              const SizedBox(height: 16),
              // Number Pad
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                childAspectRatio: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  '7', '8', '9',
                  '4', '5', '6',
                  '1', '2', '3',
                  'C', '0', '⌫',
                ].map((String button) {
                  return ElevatedButton(
                    onPressed: () {
                      if (button == 'C') {
                        _clearAmount();
                      } else if (button == '⌫') {
                        _deleteLastDigit();
                      } else {
                        _updateAmount(button);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      button,
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent
                    ),
                    child: const Text('Cancel',style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final double parsedAmount = double.parse(amount);
                      widget.onSave(parsedAmount);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 26, 26, 26),
                    ),
                    child: const Text('Save',style: TextStyle(color: Colors.white)),
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