import 'package:flutter/material.dart';
import 'package:financial_app/Calender/boxes.dart';
import 'package:financial_app/Calender/calander.dart';
import 'package:financial_app/Calender/transaction.dart';
import 'package:intl/intl.dart';
import 'modelHelper.dart';

class FormScreen extends StatefulWidget {
  final Transaction? transaction; // Nullable transaction for editing
  final bool showAppBar;
  final String? type;

  const FormScreen(
      {super.key, this.transaction, this.showAppBar = true, this.type});

  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  late TextEditingController _controller_date;
  late TextEditingController _controller_amount;
  late TextEditingController _controller_category;
  late TextEditingController _controller_account;
  IconData? _selectedIcon;

  @override
  void initState() {
    super.initState();

    // Pre-fill fields if editing an existing transaction
    _controller_date = TextEditingController(
      text: widget.transaction != null
          ? DateFormat.yMMMd().format(widget.transaction!.date)
          : "",
    );
    _controller_amount = TextEditingController(
      text: widget.transaction?.amount.toString() ?? "",
    );
    _controller_category = TextEditingController(
      text: widget.transaction?.category ?? "",
    );
    _controller_account = TextEditingController(
      text: widget.transaction?.accountType ?? "",
    );

    // If editing, set icons (optional if stored)
    _selectedIcon = null;
  }

  void clearForm() {
    setState(() {
      _controller_date.clear();
      _controller_amount.clear();
      _controller_category.clear();
      _controller_account.clear();
      _selectedIcon = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    String type = widget.type ?? "";
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.showAppBar
          ? AppBar(
              title: Text(type),
              centerTitle: true,
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          margin: EdgeInsets.all(0),
          child: Column(
            children: [
              // Date Field
              Row(
                children: [
                  SizedBox(
                      width: 70,
                      child: Text("Date", style: TextStyle(fontSize: 16))),
                  SizedBox(width: 20),
                  Expanded(
                    child: TextField(
                      controller: _controller_date,
                      readOnly: true,
                      onTap: () {
                        ModalHelper.openCalendar(
                          context: context,
                          onDateSelected: (selectedDate) {
                            setState(() {
                              _controller_date.text =
                                  DateFormat.yMMMd().format(selectedDate);
                            });
                          },
                        );
                      },
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),

              // Amount Field
              Row(
                children: [
                  SizedBox(
                      width: 70,
                      child: Text("Amount", style: TextStyle(fontSize: 16))),
                  SizedBox(width: 20),
                  Expanded(
                    child: TextField(
                      controller: _controller_amount,
                      readOnly: true,
                      onTap: () {
                        ModalHelper.openCalculator(
                            context: context, controller: _controller_amount);
                      },
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),

              // Category Field
              Row(
                children: [
                  SizedBox(
                      width: 70,
                      child: Text("Category", style: TextStyle(fontSize: 16))),
                  SizedBox(width: 20),
                  Expanded(
                    child: TextField(
                      controller: _controller_category,
                      readOnly: true,
                      decoration: InputDecoration(
                        prefixIcon: _selectedIcon != null
                            ? Icon(_selectedIcon, color: Colors.blue)
                            : null,
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      onTap: () {
                        ModalHelper.openSelectionModal_1(
                          context: context,
                          controller: _controller_category,
                          onIconSelected: (icon) {
                            setState(() {
                              _selectedIcon = icon;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),

              // Account Field
              Row(
                children: [
                  SizedBox(
                      width: 70,
                      child: Text("Account", style: TextStyle(fontSize: 16))),
                  SizedBox(width: 20),
                  Expanded(
                    child: TextField(
                      controller: _controller_account,
                      readOnly: true,
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      onTap: () {
                        ModalHelper.openSelectionModal_2(
                          context: context,
                          controller: _controller_account,
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  // Save Button (Works for both New & Existing Transactions)
                  SizedBox(
                    width: 220,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_controller_date.text.isEmpty ||
                            _controller_amount.text.isEmpty ||
                            _controller_category.text.isEmpty ||
                            _controller_account.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Please fill all the fields')),
                          );
                          return;
                        }

                        double? amount =
                            double.tryParse(_controller_amount.text);
                        if (amount == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Please enter a valid amount')),
                          );
                          return;
                        }

                        try {
                          if (widget.transaction == null) {
                            // Create New Transaction
                            String uniqueKey =
                                'txn_${DateTime.now().millisecondsSinceEpoch}';
                            boxTransactions.put(
                              uniqueKey,
                              Transaction(
                                amount: amount,
                                category: _controller_category.text,
                                accountType: _controller_account.text,
                                date: DateFormat.yMMMd()
                                    .parse(_controller_date.text),
                                type: type,
                              ),
                            );
                          } else {
                            // Update Existing Transaction
                            widget.transaction!.amount = amount;
                            widget.transaction!.category =
                                _controller_category.text;
                            widget.transaction!.accountType =
                                _controller_account.text;
                            widget.transaction!.date =
                                DateFormat.yMMMd().parse(_controller_date.text);
                            boxTransactions.put(
                                widget.transaction!.key, widget.transaction!);
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Transaction saved successfully!')),
                          );
                          
                         if(widget.transaction == null){
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ComplexTable(initialTab: 1,),
                              ),
                              (route) => false, // Remove all routes from the stack
                            );
                         }else{
                            Navigator.pop(context, true);
                         }
                        } on Exception catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Error saving transaction: $e')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 202, 34, 104),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text("Save"),
                    ),
                  ),
                  SizedBox(width: 20),

                  // Conditional Button: Delete if Editing, Clear if New
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.transaction != null
                          ? () {
                              // Delete the transaction if it exists
                              boxTransactions.delete(widget.transaction!.key);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Transaction deleted successfully!')),
                              );
                              Navigator.pop(context, true);
                            }
                          : clearForm, // Clear the form if creating a new transaction
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.transaction != null
                            ? Colors.red
                            : Colors.transparent,
                        foregroundColor: widget.transaction != null
                            ? Colors.white
                            : Color.fromARGB(255, 78, 8, 8),
                        elevation: widget.transaction != null ? 2 : 0,
                        shadowColor: widget.transaction != null
                            ? Colors.redAccent
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        side: widget.transaction == null
                            ? BorderSide(
                                color: Color.fromARGB(125, 0, 0, 0), width: 1)
                            : BorderSide.none,
                      ),
                      child:
                          Text(widget.transaction != null ? "Delete" : "Clear"),
                    ),
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