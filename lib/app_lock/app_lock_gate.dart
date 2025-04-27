import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

class AppLockGate extends StatefulWidget {
  final Widget child;
  const AppLockGate({super.key, required this.child});

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  bool _isUnlocked = false;
  bool _isCheckingAuth = true;
  AuthMode _authMode = AuthMode.biometric;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAuthStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isPinEnabled = prefs.getBool('pinEnabled') ?? false;
    final isBiometricEnabled = prefs.getBool('biometricEnabled') ?? false;
    final hasPin = (prefs.getString('appPin') ?? '').isNotEmpty;

    setState(() {
      _isUnlocked = !(isPinEnabled || isBiometricEnabled);
      _isCheckingAuth = false;
    });
  }

  void _switchToPin() {
    setState(() {
      _authMode = AuthMode.pin;
    });
  }

  void _switchToBiometric() {
    setState(() {
      _authMode = AuthMode.biometric;
    });
  }

  void _onAuthSuccess() {
    setState(() => _isUnlocked = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return const Scaffold(
        backgroundColor: Color.fromARGB(255, 27, 27, 29),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _isUnlocked 
        ? widget.child
        : _LockScreen(
            authMode: _authMode,
            onSuccess: _onAuthSuccess,
            onSwitchToPin: _switchToPin,
            onSwitchToBiometric: _switchToBiometric,
          );
  }
}

enum AuthMode { biometric, pin }

class _LockScreen extends StatelessWidget {
  final AuthMode authMode;
  final VoidCallback onSuccess;
  final VoidCallback onSwitchToPin;
  final VoidCallback onSwitchToBiometric;

  const _LockScreen({
    required this.authMode,
    required this.onSuccess,
    required this.onSwitchToPin,
    required this.onSwitchToBiometric,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 27, 27, 29),
        body: FutureBuilder(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            
            final prefs = snapshot.data as SharedPreferences;
            final isPinEnabled = prefs.getBool('pinEnabled') ?? false;
            final isBiometricEnabled = prefs.getBool('biometricEnabled') ?? false;
            final hasPin = (prefs.getString('appPin') ?? '').isNotEmpty;

            if (authMode == AuthMode.biometric && isBiometricEnabled) {
              return _BiometricAuth(
                onSuccess: onSuccess,
                onSwitchToPin: onSwitchToPin,
                canUseBiometric: isBiometricEnabled,
              );
            } else if (isPinEnabled && hasPin) {
              return PinAuthScreen(
                onSuccess: onSuccess,
                onSwitchToBiometric: onSwitchToBiometric,
                canUseBiometric: isBiometricEnabled,
              );
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) => onSuccess());
              return const Center(
                child: Text('No authentication method available', 
                  style: TextStyle(color: Colors.white)),
              );
            }
          },
        ),
      ),
    );
  }
}

class _BiometricAuth extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onSwitchToPin;
  final bool canUseBiometric;

  const _BiometricAuth({
    required this.onSuccess,
    required this.onSwitchToPin,
    required this.canUseBiometric,
  });

  @override
  State<_BiometricAuth> createState() => __BiometricAuthState();
}

class __BiometricAuthState extends State<_BiometricAuth> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAuthenticating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to unlock the app',
        options: const AuthenticationOptions(
          stickyAuth: false,
          biometricOnly: true,
        ),
      );

      if (authenticated && mounted) {
        widget.onSuccess();
      } else if (mounted) {
        setState(() => _errorMessage = 'Authentication cancelled');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Biometric authentication failed');
      }
    } finally {
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.fingerprint, size: 64, color: Colors.white),
          const SizedBox(height: 20),
          if (_isAuthenticating) ...[
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text('Authenticating...', style: TextStyle(color: Colors.white)),
          ] else if (_errorMessage != null) ...[
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
          ],
          TextButton(
            onPressed: widget.onSwitchToPin,
            child: const Text('Use PIN Instead', style: TextStyle(color: Color(0xFF7C4DFF),)),
          ),
          if (!_isAuthenticating && _errorMessage != null)
            TextButton(
              onPressed: _authenticate,
              child: const Text('Try Again', style: TextStyle(color: Color(0xFF7C4DFF),)),
            ),
        ],
      ),
    );
  }
}

class PinAuthScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onSwitchToBiometric;
  final bool canUseBiometric;

  const PinAuthScreen({
    super.key,
    required this.onSuccess,
    required this.onSwitchToBiometric,
    required this.canUseBiometric,
  });

  @override
  State<PinAuthScreen> createState() => _PinAuthScreenState();
}

class _PinAuthScreenState extends State<PinAuthScreen> {
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
        title: const Text('Enter PIN', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 27, 27, 29),
        automaticallyImplyLeading: false,
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
          if (widget.canUseBiometric)
            TextButton(
              onPressed: widget.onSwitchToBiometric,
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