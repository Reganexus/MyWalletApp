import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final TextEditingController _pinController = TextEditingController();
  String? _savedPin;
  bool _isSettingNewPin = false;

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
      _isSettingNewPin = pin == null;
    });
  }

  Future<void> _savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("app_pin", pin);
  }

  void _submitPin() async {
    if (_isSettingNewPin) {
      if (_pinController.text.length == 4) {
        await _savePin(_pinController.text);
        setState(() {
          _isSettingNewPin = false;
          _savedPin = _pinController.text;
        });
        _goToDashboard();
      }
    } else {
      if (_pinController.text == _savedPin) {
        _goToDashboard();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Incorrect PIN")));
      }
    }
  }

  void _goToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isSettingNewPin ? "Set a 4-digit PIN" : "Enter PIN",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  counterText: "",
                ),
                onSubmitted: (_) => _submitPin(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitPin,
                child: Text(_isSettingNewPin ? "Set PIN" : "Unlock"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
