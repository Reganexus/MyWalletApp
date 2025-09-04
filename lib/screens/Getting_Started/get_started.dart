import 'package:flutter/material.dart';
import 'package:mywallet/utils/Design/color_utils.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

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

            // App Logo
            Image.asset('lib/assets/images/mywalletlogo.png', height: 200),

            const SizedBox(height: 32),

            // Title
            Text(
              "Welcome to MyWallet",
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
                "Your all-in-one solution for managing personal finances. "
                "Track your income, expenses, and manage your accounts with ease.",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const Spacer(flex: 3),

            // Continue button at bottom
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: FilledButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/edit-profile-starter');
                },
                style: FilledButton.styleFrom(
                  backgroundColor: ColorUtils.defaultColor,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Continue",
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
