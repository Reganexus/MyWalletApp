import 'package:flutter/material.dart';

class ProfileSidebar extends StatelessWidget {
  const ProfileSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: const [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blueGrey),
            child: Text(
              "Profile Sidebar",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          ListTile(leading: Icon(Icons.lock), title: Text("Change PIN")),
          ListTile(
            leading: Icon(Icons.cloud_upload),
            title: Text("Backup to Google Drive"),
          ),
          ListTile(leading: Icon(Icons.dark_mode), title: Text("Dark Mode")),
          ListTile(
            leading: Icon(Icons.history),
            title: Text("Transaction History"),
          ),
          ListTile(leading: Icon(Icons.info), title: Text("About / Version")),
        ],
      ),
    );
  }
}
