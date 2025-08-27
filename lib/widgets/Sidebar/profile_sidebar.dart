import 'package:flutter/material.dart';
import 'package:mywallet/providers/theme_provider.dart';
import 'package:mywallet/widgets/Sidebar/backup_screen.dart';
import 'package:mywallet/widgets/Sidebar/change_pin.dart';
import 'package:mywallet/widgets/Sidebar/delete_data.dart';
import 'package:mywallet/widgets/Sidebar/transaction_history_page.dart';
import 'package:provider/provider.dart';

class ProfileSidebar extends StatelessWidget {
  const ProfileSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blueGrey),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white70,
                  child: Icon(Icons.person, size: 32, color: Colors.blueGrey),
                ),
                SizedBox(height: 12),
                Text(
                  "User Profile",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),

          // Theme toggle
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text("Dark Mode"),
            trailing: Consumer<ThemeProvider>(
              builder:
                  (context, themeProvider, _) => Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: themeProvider.toggleTheme,
                  ),
            ),
          ),
          const Divider(),

          // Account & History
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("Transaction History"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TransactionHistoryPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Change PIN"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePinPage()),
              );
            },
          ),
          const Divider(),

          // Backup & Data
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text("Backup & Restore"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BackupScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text("Delete All Data"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DeleteAllData()),
              );
            },
          ),
          const Divider(),

          // About / Version
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About / Version"),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "MyWallet",
                applicationVersion: "v1.0.0",
                children: const [Text("Personal finance tracker app")],
              );
            },
          ),
        ],
      ),
    );
  }
}
