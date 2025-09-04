import 'package:flutter/material.dart';
import 'package:mywallet/screens/pin_screen.dart';
import 'package:mywallet/utils/Design/color_utils.dart';

class ChangePinStarterScreen extends StatelessWidget {
  const ChangePinStarterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            Image.asset('lib/assets/images/lock.png', height: 200),

            const SizedBox(height: 32),

            // Title
            Text(
              "Add a PIN for Security",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "Protect your financial data by setting up a secure 4-digit PIN.",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const Spacer(flex: 3),

            // Button at bottom
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: FilledButton(
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
                  backgroundColor: ColorUtils.defaultColor,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Set PIN",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
