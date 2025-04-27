import 'package:flutter/material.dart';


class SetPinScreen extends StatefulWidget {
  final bool requireCurrentPin;
  
  const SetPinScreen({super.key, this.requireCurrentPin = false});
  
  @override
  _SetPinScreenState createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  String _enteredPin = '';
  String _confirmedPin = '';
  bool _isConfirming = false;
  String? _errorMessage;

  void _onNumberPressed(String number) {
    setState(() {
      if (_enteredPin.length < 4) {
        _enteredPin += number;
        _errorMessage = null;
        
        if (_enteredPin.length == 4) {
          if (!_isConfirming) {
            // First PIN entry - store and prepare for confirmation
            _confirmedPin = _enteredPin;
            _enteredPin = '';
            _isConfirming = true;
          } else {
            // Second PIN entry - compare with confirmed PIN
            if (_enteredPin == _confirmedPin) {
              Navigator.pop(context, _enteredPin);
            } else {
              _errorMessage = 'PINs do not match';
              _enteredPin = '';
              _confirmedPin = '';
              _isConfirming = false;
            }
          }
        }
      }
    });
  }

  void _onBackspacePressed() {
    setState(() {
      if (_enteredPin.isNotEmpty) {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 27, 27, 29),
      appBar: AppBar(
        title: const Text('Set PIN', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 27, 27, 29),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isConfirming ? 'Confirm your PIN' : 'Enter a new 4-digit PIN',
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < _enteredPin.length ? Color(0xFF7C4DFF) : Colors.grey,
                ),
              );
            }),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          const SizedBox(height: 40),
          _buildNumpad(),
        ],
      ),
    );
  }

  Widget _buildNumpad() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: 1.5,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      children: [
        for (int i = 1; i <= 9; i++)
          _buildNumberButton(i.toString()),
        Container(), // Empty space
        _buildNumberButton('0'),
        IconButton(
          icon: const Icon(Icons.backspace, color: Colors.white),
          onPressed: _onBackspacePressed,
        ),
      ],
    );
  }

  Widget _buildNumberButton(String number) {
    return InkWell(
      onTap: () => _onNumberPressed(number),
      child: Center(
        child: Text(
          number,
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}