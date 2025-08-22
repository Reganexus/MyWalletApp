import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';

enum PinMode { unlock, set, change }

class PinScreen extends StatefulWidget {
  final PinMode mode;

  const PinScreen({super.key, required this.mode});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _enteredPin = "";
  String? _savedPin;
  String? _tempPin;
  bool _isConfirmingPin = false;
  bool _isVerifyingOldPin = false;

  @override
  void initState() {
    super.initState();
    _loadPin();
  }

  Future<void> _loadPin() async {
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString("app_pin");
    setState(() {
      _savedPin = pin;
      if (widget.mode == PinMode.change) {
        _isVerifyingOldPin = true;
      }
    });
  }

  Future<void> _savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("app_pin", pin);
  }

  void _onKeyPressed(String key) {
    setState(() {
      if (key == "back") {
        if (_enteredPin.isNotEmpty) {
          _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        }
      } else {
        if (_enteredPin.length < 4) {
          _enteredPin += key;
        }
      }
    });

    if (_enteredPin.length == 4) {
      _submitPin();
    }
  }

  void _submitPin() async {
    if (widget.mode == PinMode.unlock) {
      _handleUnlock();
    } else if (widget.mode == PinMode.set) {
      _handleSetPin();
    } else if (widget.mode == PinMode.change) {
      _handleChangePin();
    }
  }

  void _handleUnlock() {
    if (_enteredPin == _savedPin) {
      _goToDashboard();
    } else {
      _showError("Incorrect PIN");
    }
  }

  void _handleSetPin() async {
    if (_isConfirmingPin) {
      if (_enteredPin == _tempPin) {
        await _savePin(_enteredPin);
        _goToDashboard();
      } else {
        _showError("PINs do not match. Try again.");
      }
    } else {
      _tempPin = _enteredPin;
      _enteredPin = "";
      _isConfirmingPin = true;
      setState(() {});
    }
  }

  void _handleChangePin() async {
    if (_isVerifyingOldPin) {
      if (_enteredPin == _savedPin) {
        _enteredPin = "";
        _isVerifyingOldPin = false;
        setState(() {});
      } else {
        _showError("Incorrect old PIN");
      }
    } else {
      _handleSetPin();
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    setState(() {
      _enteredPin = "";
      _isConfirmingPin = false;
      _tempPin = null;
    });
  }

  void _goToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        bool filled = index < _enteredPin.length;
        return Container(
          margin: const EdgeInsets.all(8),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? Colors.blueGrey : Colors.grey[300],
          ),
        );
      }),
    );
  }

  Widget _buildKeypadButton(String text, {IconData? icon}) {
    return GestureDetector(
      onTap: () => _onKeyPressed(text),
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(8),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blueGrey[100],
        ),
        child:
            icon != null
                ? Icon(icon, size: 28, color: Colors.blueGrey[900])
                : Text(
                  text,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[900],
                  ),
                ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String title = "";
    if (widget.mode == PinMode.unlock) {
      title = "Enter PIN";
    } else if (widget.mode == PinMode.set) {
      title = _isConfirmingPin ? "Confirm your PIN" : "Set a 4-digit PIN";
    } else if (widget.mode == PinMode.change) {
      if (_isVerifyingOldPin) {
        title = "Enter old PIN";
      } else {
        title = _isConfirmingPin ? "Confirm new PIN" : "Enter new PIN";
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              _buildPinDots(),
              const SizedBox(height: 40),

              // Keypad
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                padding: const EdgeInsets.symmetric(horizontal: 60),
                children: [
                  for (var i = 1; i <= 9; i++) _buildKeypadButton(i.toString()),
                  const SizedBox(),
                  _buildKeypadButton("0"),
                  _buildKeypadButton("back", icon: Icons.backspace),
                ],
              ),

              if (_isConfirmingPin) ...[
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isConfirmingPin = false;
                      _enteredPin = "";
                      _tempPin = null;
                    });
                  },
                  child: const Text("Go back"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
