import 'package:flutter/material.dart';
import 'package:mywallet/providers/theme_provider.dart';
import 'package:mywallet/providers/profile_provider.dart';
import 'package:mywallet/widgets/Sidebar/about.dart';
import 'package:mywallet/widgets/Sidebar/backup_screen.dart';
import 'package:mywallet/widgets/Sidebar/change_pin.dart';
import 'package:mywallet/widgets/Sidebar/delete_data.dart';
import 'package:mywallet/widgets/Sidebar/edit_profile_screen.dart';
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
          Consumer<ProfileProvider>(
            builder: (context, profileProvider, _) {
              final profile = profileProvider.profile;
              final username = profile?.username ?? "User";
              final colorPref = profile?.colorPreference;
              final bgColor =
                  colorPref != null ? Color(int.parse(colorPref)) : Colors.blue;

              return DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      bgColor.withValues(alpha: 0.6),
                      bgColor.withValues(alpha: 0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundImage:
                          profile?.profileImage != null
                              ? MemoryImage(profile!.profileImage!)
                              : null,
                      backgroundColor: bgColor.withValues(alpha: 0.2),
                      child:
                          profile?.profileImage == null
                              ? Icon(
                                Icons.person,
                                size: 36,
                                color: Colors.white,
                              )
                              : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Theme toggle
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text("Dark Mode"),
            trailing: Consumer2<ThemeProvider, ProfileProvider>(
              builder: (context, themeProvider, profileProvider, _) {
                final profile = profileProvider.profile;
                final userColor =
                    profile?.colorPreference != null
                        ? Color(int.parse(profile!.colorPreference!))
                        : Colors.blueGrey;

                return Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: themeProvider.toggleTheme,
                  activeThumbColor: Colors.white,
                  activeTrackColor: userColor,
                  inactiveThumbColor: userColor,
                  inactiveTrackColor: userColor.withValues(alpha: 0.5),
                  trackOutlineColor: WidgetStateProperty.all(Colors.white70),
                );
              },
            ),
          ),

          const Divider(),

          // Account & History
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Edit Profile"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
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
            leading: const Icon(Icons.bar_chart),
            title: const Text("Graphs"),
            onTap: () {
              Navigator.pushNamed(context, "/graph-options");
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const About()),
              );
            },
          ),
        ],
      ),
    );
  }
}
