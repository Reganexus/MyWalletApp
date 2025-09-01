import 'package:flutter/material.dart';
import 'package:mywallet/widgets/Sidebar/edit_profile_screen.dart';

class EditProfileStarterScreen extends StatelessWidget {
  const EditProfileStarterScreen({super.key});

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
            const Icon(Icons.person_outline, size: 100, color: Colors.grey),
            const SizedBox(height: 24),
            Text(
              "Personalize Your Experience",
              style: Theme.of(
                context,
              ).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Set a username, profile picture, and a theme color to make the app feel like yours.",
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const Spacer(flex: 2),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EditProfileScreen(hasPin: false),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Edit Profile"),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
