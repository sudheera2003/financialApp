import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  _ChangePinScreenState createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  String _currentPin = '';
  String _newPin = '';
  String _confirmedNewPin = '';
  int _step = 1; // 1 = enter current, 2 = enter new, 3 = confirm new
  String? _errorMessage;

  Future<void> _verifyCurrentPin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('appPin') ?? '';
    
    if (_currentPin == savedPin) {
      setState(() {
        _step = 2;
        _currentPin = '';
        _errorMessage = null;
      });
    } else {
      setState(() {
        _errorMessage = 'Incorrect current PIN';
        _currentPin = '';
      });
    }
  }

  void _onNumberPressed(String number) {
    setState(() {
      if (_step == 1 && _currentPin.length < 4) {
        _currentPin += number;
      } else if (_step == 2 && _newPin.length < 4) {
        _newPin += number;
      } else if (_step == 3 && _confirmedNewPin.length < 4) {
        _confirmedNewPin += number;
      }
      
      _errorMessage = null;
      
      if (_step == 1 && _currentPin.length == 4) {
        _verifyCurrentPin();
      } else if (_step == 2 && _newPin.length == 4) {
        setState(() {
          _step = 3;
        });
      } else if (_step == 3 && _confirmedNewPin.length == 4) {
        if (_newPin == _confirmedNewPin) {
          Navigator.pop(context, _newPin);
        } else {
          setState(() {
            _errorMessage = 'PINs do not match';
            _newPin = '';
            _confirmedNewPin = '';
            _step = 2;
          });
        }
      }
    });
  }

  void _onBackspacePressed() {
    setState(() {
      if (_step == 1 && _currentPin.isNotEmpty) {
        _currentPin = _currentPin.substring(0, _currentPin.length - 1);
      } else if (_step == 2 && _newPin.isNotEmpty) {
        _newPin = _newPin.substring(0, _newPin.length - 1);
      } else if (_step == 3 && _confirmedNewPin.isNotEmpty) {
        _confirmedNewPin = _confirmedNewPin.substring(0, _confirmedNewPin.length - 1);
      }
    });
  }

  String get _stepTitle {
    switch (_step) {
      case 1: return 'Enter current PIN';
      case 2: return 'Enter new PIN';
      case 3: return 'Confirm new PIN';
      default: return '';
    }
  }

  String get _displayPin {
    switch (_step) {
      case 1: return _currentPin;
      case 2: return _newPin;
      case 3: return _confirmedNewPin;
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 27, 27, 29),
      appBar: AppBar(
        title: const Text('Change PIN', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 27, 27, 29),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _stepTitle,
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
                  color: index < _displayPin.length ? Color(0xFF7C4DFF) : Colors.grey,
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