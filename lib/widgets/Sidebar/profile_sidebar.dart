import 'package:flutter/material.dart';
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
          const ListTile(leading: Icon(Icons.lock), title: Text("Change PIN")),
          const ListTile(
            leading: Icon(Icons.cloud_upload),
            title: Text("Backup to Google Drive"),
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

          const ListTile(
            leading: Icon(Icons.info),
            title: Text("About / Version"),
          ),
        ],
      ),
    );
  }
}
