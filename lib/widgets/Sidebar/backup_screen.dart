import 'package:flutter/material.dart';
import 'package:mywallet/providers/profile_provider.dart';
import 'package:mywallet/providers/provider_reloader.dart';
import 'package:mywallet/services/backup_service.dart';
import 'package:mywallet/utils/Design/overlay_message.dart';
import 'package:provider/provider.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final BackupService _backupService = BackupService();
  bool _isBackingUp = false;
  bool _isRestoring = false;

  Future<void> _backup() async {
    setState(() => _isBackingUp = true);

    try {
      final file = await _backupService.backupDatabase();

      if (!mounted) return;

      if (file != null) {
        OverlayMessage.show(context, message: "Backup saved at: ${file.path}");
      } else {
        OverlayMessage.show(
          context,
          message: "Backup canceled by user",
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      OverlayMessage.show(context, message: "Backup failed: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _isRestoring = true);

    try {
      await _backupService.restoreDatabase();

      if (!mounted) return;
      await ProviderReloader.reloadAll(context);

      if (!mounted) return;
      OverlayMessage.show(context, message: "Restore complete, data refreshed");

      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/dashboard', (route) => false);
    } catch (e) {
      if (!mounted) return;
      OverlayMessage.show(
        context,
        message: "Restore failed: $e",
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isLoading,
    Color? color,
  }) {
    final profile = context.watch<ProfileProvider>().profile;
    final baseColor =
        profile?.colorPreference != null
            ? Color(int.parse(profile!.colorPreference!))
            : Colors.blue;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isLoading ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: (color ?? Colors.blue).withValues(alpha: 0.2),
                child: Icon(icon, color: color ?? Colors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: baseColor),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Backup & Restore"),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        scrolledUnderElevation: 0.0,
        elevation: 0.0,
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          _buildActionCard(
            icon: Icons.backup,
            title: "Backup Database",
            subtitle: "Create a backup of all your data",
            onTap: _backup,
            isLoading: _isBackingUp,
            color: Colors.blue,
          ),
          _buildActionCard(
            icon: Icons.restore,
            title: "Restore Database",
            subtitle: "Restore from your latest backup",
            onTap: _restore,
            isLoading: _isRestoring,
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}
