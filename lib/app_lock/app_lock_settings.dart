import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'set_pin_screen.dart';
import 'enter_pin_screen.dart';
import 'change_pin_screen.dart';

class AppLockSettings extends StatefulWidget {
  const AppLockSettings({super.key});

  @override
  _AppLockSettingsState createState() => _AppLockSettingsState();
}

class _AppLockSettingsState extends State<AppLockSettings> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isBiometricEnabled = false;
  bool _isPinEnabled = false;
  String _currentPin = '';
  bool _isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
    bool isDeviceSupported = await _localAuth.isDeviceSupported();
    setState(() {
      _isBiometricAvailable = canCheckBiometrics && isDeviceSupported;
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBiometricEnabled = prefs.getBool('biometricEnabled') ?? false;
      _isPinEnabled = prefs.getBool('pinEnabled') ?? false;
      _currentPin = prefs.getString('appPin') ?? '';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometricEnabled', _isBiometricEnabled);
    await prefs.setBool('pinEnabled', _isPinEnabled);
    if (_currentPin.isNotEmpty) {
      await prefs.setString('appPin', _currentPin);
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value && !_isBiometricAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric authentication not available on this device')),
      );
      return;
    }

    if (_isPinEnabled || !value) {
      // If pin is enabled or we're disabling biometric, just toggle
      setState(() {
        _isBiometricEnabled = value;
      });
      await _saveSettings();
    } else {
      // If no pin is set, we need to set a pin first
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SetPinScreen(requireCurrentPin: false)),
      );
      
      if (result != null && result is String && result.isNotEmpty) {
        setState(() {
          _isBiometricEnabled = value;
          _isPinEnabled = true;
          _currentPin = result;
        });
        await _saveSettings();
      }
    }
  }

  Future<void> _togglePin(bool value) async {
    if (value) {
      // Enable PIN - go to set pin screen
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SetPinScreen(requireCurrentPin: false)),
      );
      
      if (result != null && result is String && result.isNotEmpty) {
        setState(() {
          _isPinEnabled = true;
          _currentPin = result;
        });
        await _saveSettings();
      }
    } else {
      // Disable PIN - verify current PIN first
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EnterPinScreen(
            title: 'Enter current PIN to disable',
            onSuccess: () => Navigator.pop(context, true),
          ),
        ),
      );
      
      if (result == true) {
        setState(() {
          _isPinEnabled = false;
          _currentPin = '';
          // If biometric is enabled and no pin, keep biometric on
          // Otherwise, if no pin and no biometric, turn both off
          if (!_isBiometricEnabled) {
            _isBiometricEnabled = false;
          }
        });
        await _saveSettings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 27, 27, 29),
      appBar: AppBar(
        iconTheme: IconThemeData(color: const Color.fromARGB(255, 255, 255, 255),),
        title: const Text('App Lock Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF7C4DFF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Enable PIN', style: TextStyle(color: Colors.white)),
              value: _isPinEnabled,
              onChanged: _togglePin,
              activeColor: const Color(0xFF7C4DFF),
            ),
            if (_isBiometricAvailable)
              SwitchListTile(
                title: const Text('Enable Biometric', style: TextStyle(color: Colors.white)),
                value: _isBiometricEnabled,
                onChanged: _toggleBiometric,
                activeColor: const Color(0xFF7C4DFF),
              ),
            if (_isPinEnabled)
              ListTile(
                title: const Text('Change PIN', style: TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.arrow_forward, color: Colors.white),
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChangePinScreen(),
                    ),
                  );
                  if (result != null && result is String && result.isNotEmpty) {
                    setState(() {
                      _currentPin = result;
                    });
                    await _saveSettings();
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}