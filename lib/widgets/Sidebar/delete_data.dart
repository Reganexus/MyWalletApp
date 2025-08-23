import 'package:flutter/material.dart';
import 'package:mywallet/providers/provider_reloader.dart';
import 'package:mywallet/services/db_service.dart';

class DeleteAllData extends StatefulWidget {
  const DeleteAllData({super.key});

  @override
  State<DeleteAllData> createState() => _DeleteAllDataState();
}

class _DeleteAllDataState extends State<DeleteAllData> {
  Future<void> _deleteAll() async {
    // Clear DB
    final db = DBService();
    await db.clearAllData();

    if (!mounted) return;

    // Reload providers
    await ProviderReloader.reloadAll(context);

    if (!mounted) return;

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/dashboard', (route) => false);

    // ✅ Safe: only call messenger after async + mounted check
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("✅ All data deleted")));
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Are you absolutely sure?"),
            content: const Text(
              "This will wipe out everything from the database.\n\n"
              "Do you want to continue?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text("Delete All"),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _deleteAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delete All Data"),
        backgroundColor: Colors.red.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "⚠️ Warning",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "This will permanently delete all accounts, bills, and transactions.\n\n"
              "This action cannot be undone.",
              style: TextStyle(fontSize: 16),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete_forever, color: Colors.white),
                label: const Text("Delete All Data"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 24,
                  ),
                ),
                onPressed: _confirmDelete,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
