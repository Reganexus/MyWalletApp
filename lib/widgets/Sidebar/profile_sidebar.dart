import 'package:flutter/material.dart';
import 'package:mywallet/widgets/Sidebar/backup_screen.dart';
import 'package:mywallet/widgets/Sidebar/change_pin.dart';
import 'package:mywallet/widgets/Sidebar/delete_data.dart';
import 'package:mywallet/widgets/Sidebar/transaction_history_page.dart';

class ProfileSidebar extends StatelessWidget {
  const ProfileSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blueGrey),
            child: Text(
              "Profile Sidebar",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
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
          const ListTile(
            leading: Icon(Icons.dark_mode),
            title: Text("Dark Mode"),
          ),
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
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              "Delete All Data",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DeleteAllData()),
              );
            },
          ),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text("About / Version"),
          ),
        ],
      ),
    );
  }
}
