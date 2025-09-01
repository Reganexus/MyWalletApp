import 'package:flutter/material.dart';
import 'package:mywallet/providers/profile_provider.dart';
import 'package:provider/provider.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final baseColor =
        profile?.colorPreference != null
            ? Color(int.parse(profile!.colorPreference!))
            : Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: const Text("About / Version"),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        scrolledUnderElevation: 0,
        elevation: 0,
        titleSpacing: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "MyWallet",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: baseColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Version 1.0.0",
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "MyWallet is a simple, intuitive app to help you manage your finances, "
                    "track transactions, bills, and accounts. You can backup, restore, and "
                    "secure your data with a PIN.",
                    style: TextStyle(fontSize: 16, height: 1.4),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ),

          // Optional extra cards
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(Icons.contact_support, color: baseColor),
              title: const Text("Support"),
              subtitle: const Text("Contact us for help or feedback"),
              onTap: () {},
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(Icons.privacy_tip, color: baseColor),
              title: const Text("Privacy Policy"),
              subtitle: const Text("Read our privacy and data policies"),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
