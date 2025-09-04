import 'package:flutter/material.dart';
import 'package:mywallet/utils/Design/color_utils.dart';
import 'package:mywallet/widgets/Sidebar/edit_profile_screen.dart';

class EditProfileStarterScreen extends StatelessWidget {
  const EditProfileStarterScreen({super.key});

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

            // App Logo with shadow
            Image.asset('lib/assets/images/sparkling.png', height: 200),

            const SizedBox(height: 32),

            // Title
            Text(
              "Personalize Your Experience",
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
                "Set a username, profile picture, and a theme color "
                "to make the app feel like yours.",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const Spacer(flex: 3),

            // Edit Profile button at bottom
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
                      builder: (_) => const EditProfileScreen(hasPin: false),
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
                  "Edit Profile",
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
