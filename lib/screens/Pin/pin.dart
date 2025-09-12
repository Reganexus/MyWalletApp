import 'package:flutter/material.dart';
import 'package:mywallet/providers/account_provider.dart';
import 'package:mywallet/providers/bill_provider.dart';
import 'package:mywallet/providers/profile_provider.dart';
import 'package:mywallet/utils/Design/overlay_message.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PinMode { unlock, set, change }

class PinScreen extends StatefulWidget {
  final PinMode mode;
  final bool hasPin;

  const PinScreen({super.key, required this.mode, required this.hasPin});

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

    // Load providers after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // Access providers safely after build
      final accountProvider = Provider.of<AccountProvider>(
        context,
        listen: false,
      );
      final billProvider = Provider.of<BillProvider>(context, listen: false);

      await accountProvider.loadAccounts();
      await billProvider.loadBills();
    });
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
        _showSuccess("PIN set successfully!");
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
      if (_isConfirmingPin) {
        if (_enteredPin == _tempPin) {
          await _savePin(_enteredPin);
          _showSuccess("PIN changed successfully!");
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
  }

  void _showError(String msg) {
    OverlayMessage.show(context, message: "Incorrect PIN", isError: true);
    setState(() {
      _enteredPin = "";
    });
  }

  void _showSuccess(String msg) {
    OverlayMessage.show(context, message: "PIN set successfully!");
  }

  void _goToDashboard() {
    Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
  }

  Widget _buildPinDots() {
    final profile = context.watch<ProfileProvider>().profile;
    final baseColor =
        profile?.colorPreference != null
            ? Color(int.parse(profile!.colorPreference!))
            : Colors.blue;
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
            color:
                filled
                    ? baseColor
                    : Theme.of(context).colorScheme.surface.withAlpha(100),
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
          color:
              icon == null
                  ? Theme.of(context).colorScheme.surface.withAlpha(40)
                  : Colors.transparent,
        ),
        child:
            icon != null
                ? Icon(icon, size: 32, color: Colors.white)
                : Text(
                  text,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final baseColor =
        profile?.colorPreference != null
            ? Color(int.parse(profile!.colorPreference!))
            : Colors.blue;

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

    // CORRECTED: Simplified logic for the leading icon
    final bool showBackButton = widget.mode == PinMode.change;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading:
            showBackButton
                ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                )
                : null,
        title: Text(
          widget.mode == PinMode.change ? "Change PIN" : "",
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [baseColor.withAlpha(230), baseColor.withAlpha(153)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                _buildPinDots(),
                const SizedBox(height: 40),

                // Keypad
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    children: [
                      for (var i = 1; i <= 9; i++)
                        _buildKeypadButton(i.toString()),
                      const SizedBox(),
                      _buildKeypadButton("0"),
                      _buildKeypadButton("back", icon: Icons.backspace),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
