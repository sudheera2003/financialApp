import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorScreen extends StatefulWidget {
    final TextEditingController controller;
    const CalculatorScreen({super.key, required this.controller});

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {


  List<String> operators = ['+', '-', '×', '÷'];
  bool isNewExpression = true;

  void evaluateExpression() {
    String userInput = widget.controller.text;

    try {
      // Replace '×' with '*' and '÷' with '/' for valid math parsing
      userInput = userInput.replaceAll('×', '*').replaceAll('÷', '/');

      Parser parser = Parser();
      Expression exp = parser.parse(userInput);
      ContextModel cm = ContextModel();

      double result = exp.evaluate(EvaluationType.REAL, cm);

      setState(() {
        widget.controller.text = result.toStringAsFixed(2);
      });
    } catch (e) {
      setState(() {
        widget.controller.text = "Error"; // Display error if invalid input
      });
    }
  }

   @override
  Widget build(BuildContext context) {
        return CalculatorGrid(
            onKeyPressed: (String value) {
              setState(() {
                if (value == '⌫') {
                  // Backspace functionality
                  if (widget.controller.text.isNotEmpty) {
                    
                    if (widget.controller.text.isNotEmpty && widget.controller.text.startsWith('(') && (widget.controller.text.endsWith('×')||widget.controller.text.endsWith('÷'))) {
                      widget.controller.text = widget.controller.text.substring(1, widget.controller.text.length - 2);
                    }else{
                      widget.controller.text = widget.controller.text.substring(0, widget.controller.text.length - 1);
                    }
                    if (widget.controller.text.isEmpty) {
                      isNewExpression = true;
                    }
                  }
                } else if (value == 'OK' || value == '=') {
                  if(!isNewExpression)evaluateExpression();
                  isNewExpression = true;
                  if (value == 'OK') {
                    Navigator.pop(context);
                    isNewExpression = true;
                  }
                } else {
                  if (operators.contains(value)) {
                    if (!isNewExpression) {
                      if (operators.any((op) => widget.controller.text.endsWith(op))){
                        if (widget.controller.text.isNotEmpty && widget.controller.text.startsWith('(') && (widget.controller.text.endsWith('×')||widget.controller.text.endsWith('÷'))) {
                          widget.controller.text = widget.controller.text.substring(1, widget.controller.text.length - 2);
                        }else{
                          widget.controller.text = widget.controller.text.substring(0, widget.controller.text.length - 1);
                        }
                      }else if(widget.controller.text.endsWith('.')){widget.controller.text = widget.controller.text.substring(0, widget.controller.text.length - 1);}
                      switch (value) {
                        case '+':
                          widget.controller.text += value;
                          break;
                        case '-':
                          widget.controller.text += value;
                          break;
                        case '×':
                          if(widget.controller.text.endsWith(')')){
                            widget.controller.text += value;
                          }else{
                            widget.controller.text = ('(${widget.controller.text})×');
                          }
                          break;
                        case '÷':
                          if(widget.controller.text.endsWith(')')){
                            widget.controller.text += value;
                          }else{
                            widget.controller.text = ('(${widget.controller.text})÷');
                          }
                          break;
                      }
                    }
                  } else if (value == '.') {
                    List<String> parts = widget.controller.text.split(RegExp(r'[+\-×÷]'));
                    String lastNumber = parts.isNotEmpty ? parts.last : '';
                    if (operators.any((op) => widget.controller.text.endsWith(op))||widget.controller.text.isEmpty){
                      widget.controller.text += '0.';
                      isNewExpression = false;
                    } else if (!lastNumber.contains('.')) {
                      widget.controller.text += value;
                    }
                  }else{
                    if (isNewExpression) {
                      widget.controller.text = value;
                      isNewExpression = false;
                    } else {
                      widget.controller.text += value;
                    }
                  }
                }
              });
            }
        );
      }
  }

  
class CalculatorGrid extends StatelessWidget {
  final Function(String) onKeyPressed;

  CalculatorGrid({super.key, required this.onKeyPressed});

  final List<List<String>> buttons = [
    ['+', '-', '×', '÷'],
    ['7', '8', '9', '='],
    ['4', '5', '6', '.'],
    ['1', '2', '3', '⌫'],
    ['', '0', '', 'OK'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: buttons.map((row) {
        return Row(
          children: row.map((text) {
            return buildButton(text);
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget buildButton(String text) {
    bool isOKButton = text == "OK";
    return Expanded(
      flex: isOKButton ? 1 : 1, // "OK" button is bigger
      child: InkWell(
        onTap: () => onKeyPressed(text),
        child: Material(
          color: Colors.transparent, // Make the Material background transparent
          child: Container(
            height: 75,
            decoration: BoxDecoration(
              color: isOKButton ? Colors.redAccent : Colors.black54,
              border: Border.all(color: const Color.fromARGB(255, 255, 255, 255), width: 2),
            ),
            child: Center(
              child: text.isNotEmpty
                  ? text == "⌫"
                      ? Icon(Icons.backspace_outlined, color: Colors.white, size: 24)
                      : Text(
                          text,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        )
                  : SizedBox(), // Empty space for missing button
            ),
          ),
        ),
      ),
    );
  }
    

}
