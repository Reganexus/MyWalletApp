import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mywallet/providers/profile_provider.dart';
import 'package:mywallet/utils/Design/overlay_message.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  const About({super.key});

  // Helper widget for cleaner feature rows
  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
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
          // App Info Card
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
                  SizedBox(
                    width: double.infinity,
                    child: Image.asset(
                      'lib/assets/images/mywalletlogo.png',
                      height: 200,
                    ),
                  ),
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
                    style: const TextStyle(fontSize: 16, height: 1.4),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ),

          // Features Section
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
                    "Features",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: baseColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Modern minimalist list
                  _buildFeatureItem(
                    context,
                    icon: Icons.account_balance_wallet_outlined,
                    text: "Track Account Balances",
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.calendar_today_outlined,
                    text: "Bill Schedules",
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.trending_up_outlined,
                    text: "Track Income and Expense",
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.lock_outline,
                    text: "PIN Security",
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.backup_outlined,
                    text: "Backup and Restore",
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.history_outlined,
                    text: "View Transaction History",
                  ),
                ],
              ),
            ),
          ),

          // Support Section
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(Icons.email_outlined, color: baseColor),
              title: const Text("Support"),
              subtitle: const Text("Send us an email for help or feedback"),
              onTap: () async {
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: 'renzovinas7262@gmail.com',
                  query: Uri.encodeFull('subject=MyWallet App Support'),
                );

                try {
                  // 1. Try launching the native email app
                  if (await canLaunchUrl(emailUri)) {
                    await launchUrl(
                      emailUri,
                      mode: LaunchMode.externalApplication,
                    );
                    return;
                  }

                  // 2. Fallback: open Gmail web
                  final Uri gmailWeb = Uri.parse(
                    "https://mail.google.com/mail/?view=cm&fs=1&to=renzovinas7262@gmail.com&su=MyWallet%20App%20Support",
                  );
                  if (await canLaunchUrl(gmailWeb)) {
                    await launchUrl(
                      gmailWeb,
                      mode: LaunchMode.externalApplication,
                    );
                    return;
                  }
                } catch (e) {
                  debugPrint("Could not launch email: $e");
                }

                // 3. Last fallback: copy to clipboard
                await Clipboard.setData(
                  const ClipboardData(text: "renzovinas7262@gmail.com"),
                );
                if (context.mounted) {
                  OverlayMessage.show(
                    context,
                    message: "Email address copied to clipboard",
                    isError: false,
                  );
                }
              },
            ),
          ),

          // Privacy Policy
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

          // Terms of Service
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(Icons.article_outlined, color: baseColor),
              title: const Text("Terms of Service"),
              subtitle: const Text("Read the app usage terms"),
              onTap: () {},
            ),
          ),

          // Acknowledgements Section
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 24),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Acknowledgements",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: baseColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // FXRates logo (light/dark mode)
                  SizedBox(
                    width: double.infinity,
                    child:
                        Theme.of(context).brightness == Brightness.dark
                            ? Image.asset(
                              'lib/assets/images/fxrates_light.png',
                              height: 50,
                            )
                            : Image.asset(
                              'lib/assets/images/fxrates.png',
                              height: 50,
                            ),
                  ),
                ],
              ),
            ),
          ),

          // Footer copyright
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                "© ${DateTime.now().year} Renzo P. Viñas",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
