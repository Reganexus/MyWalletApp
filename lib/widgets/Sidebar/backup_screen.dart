import 'package:flutter/material.dart';
import 'package:mywallet/providers/provider_reloader.dart';
import 'package:mywallet/services/backup_service.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final BackupService _backupService = BackupService();

  String _status = "No action yet";

  Future<void> _backup() async {
    try {
      final file = await _backupService.backupDatabase();
      if (file != null) {
        setState(() {
          _status = "Backup saved at: ${file.path}";
        });
      } else {
        setState(() {
          _status = "Backup canceled by user";
        });
      }
    } catch (e) {
      setState(() {
        _status = "Backup failed: $e";
      });
    }
  }

  Future<void> _restore() async {
    try {
      await _backupService.restoreDatabase();

      if (!mounted) return;

      await ProviderReloader.reloadAll(context);

      if (!mounted) return;

      setState(() {
        _status = "Database restored & data reloaded!";
      });

      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/dashboard', (route) => false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Restore complete, data refreshed")),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = "Restore failed: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Backup & Restore")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _backup,
              icon: const Icon(Icons.backup),
              label: const Text("Backup Database"),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _restore,
              icon: const Icon(Icons.restore),
              label: const Text("Restore Database"),
            ),
            const SizedBox(height: 24),
            Text(
              _status,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
