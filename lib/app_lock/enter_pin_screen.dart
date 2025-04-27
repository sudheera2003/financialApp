import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnterPinScreen extends StatefulWidget {
  final String title;
  final VoidCallback onSuccess;
  
  const EnterPinScreen({super.key, required this.title, required this.onSuccess});
  
  @override
  _EnterPinScreenState createState() => _EnterPinScreenState();
}

class _EnterPinScreenState extends State<EnterPinScreen> {
  String _enteredPin = '';
  String? _errorMessage;

  Future<void> _verifyPin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('appPin') ?? '';
    
    if (_enteredPin == savedPin) {
      widget.onSuccess();
    } else {
      setState(() {
        _errorMessage = 'Incorrect PIN';
        _enteredPin = '';
      });
    }
  }

  void _onNumberPressed(String number) {
    setState(() {
      if (_enteredPin.length < 4) {
        _enteredPin += number;
        _errorMessage = null;
        
        if (_enteredPin.length == 4) {
          _verifyPin();
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
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 27, 27, 29),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
          TextButton(
            onPressed: () async {
              final localAuth = LocalAuthentication();
              try {
                final authenticated = await localAuth.authenticate(
                  localizedReason: 'Authenticate to access the app',
                );
                if (authenticated) {
                  widget.onSuccess();
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Biometric authentication failed: $e')),
                );
              }
            },
            child: const Text('Use Biometric Instead', style: TextStyle(color: Color(0xFF7C4DFF))),
          ),
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