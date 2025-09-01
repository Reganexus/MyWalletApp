import 'package:flutter/material.dart';
import 'package:mywallet/providers/profile_provider.dart';
import 'package:mywallet/providers/provider_reloader.dart';
import 'package:mywallet/services/backup_service.dart';
import 'package:provider/provider.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final BackupService _backupService = BackupService();
  bool _isProcessing = false;

  Future<void> _showSnackBar(String message, {Color? color}) async {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Future<void> _backup() async {
    setState(() => _isProcessing = true);
    try {
      final file = await _backupService.backupDatabase();
      if (file != null) {
        await _showSnackBar(
          "Backup saved at: ${file.path}",
          color: Colors.green,
        );
      } else {
        await _showSnackBar("Backup canceled by user", color: Colors.orange);
      }
    } catch (e) {
      await _showSnackBar("Backup failed: $e", color: Colors.red);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _isProcessing = true);
    try {
      await _backupService.restoreDatabase();
      if (!mounted) return;

      await ProviderReloader.reloadAll(context);
      if (!mounted) return;

      await _showSnackBar(
        "Restore complete, data refreshed",
        color: Colors.green,
      );

      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/dashboard', (route) => false);
    } catch (e) {
      await _showSnackBar("Restore failed: $e", color: Colors.red);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
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
        onTap: _isProcessing ? null : onTap,
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
              if (_isProcessing)
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
            color: Colors.blue,
          ),
          _buildActionCard(
            icon: Icons.restore,
            title: "Restore Database",
            subtitle: "Restore from your latest backup",
            onTap: _restore,
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}
