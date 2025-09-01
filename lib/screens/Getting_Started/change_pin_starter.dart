import 'package:flutter/material.dart';
import 'package:mywallet/screens/pin_screen.dart';

class ChangePinStarterScreen extends StatelessWidget {
  const ChangePinStarterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(flex: 2),
            const Icon(Icons.lock_outline, size: 100, color: Colors.grey),
            const SizedBox(height: 24),
            Text(
              "Add a PIN for Security",
              style: Theme.of(
                context,
              ).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Protect your financial data by setting up a secure 4-digit PIN.",
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const Spacer(flex: 2),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) =>
                            const PinScreen(mode: PinMode.set, hasPin: false),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Set PIN"),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
