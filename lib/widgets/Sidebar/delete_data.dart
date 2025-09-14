import 'package:flutter/material.dart';
import 'package:mywallet/providers/provider_reloader.dart';
import 'package:mywallet/services/db_service.dart';
import 'package:mywallet/utils/Design/overlay_message.dart';
import 'package:mywallet/utils/WidgetHelper/confirmation_dialog.dart';

class DeleteAllData extends StatefulWidget {
  const DeleteAllData({super.key});

  @override
  State<DeleteAllData> createState() => _DeleteAllDataState();
}

class _DeleteAllDataState extends State<DeleteAllData> {
  bool _isProcessing = false;

  Future<void> _deleteAll() async {
    setState(() => _isProcessing = true);

    try {
      final db = DBService();
      await db.clearAllData();

      if (!mounted) return;
      await ProviderReloader.reloadAll(context);

      if (!mounted) return;
      OverlayMessage.show(context, message: "All data deleted");

      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/dashboard', (route) => false);
    } catch (e) {
      if (!mounted) return;
      OverlayMessage.show(
        context,
        message: "Deletion failed: $e",
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: "Are you absolutely sure?",
      content:
          "This will wipe out everything from the database.\n\n"
          "This action cannot be undone.",
      confirmText: "Delete All",
      cancelText: "Cancel",
      confirmColor: Colors.red,
    );

    if (confirmed == true) {
      await _deleteAll();
    }
  }

  Widget _buildWarningCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.red,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              "This will permanently delete all accounts, bills, goals, and transactions. This action cannot be undone.",
              style: TextStyle(fontSize: 14, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _isProcessing ? null : _confirmDelete,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.red.withValues(alpha: 0.2),
                child: const Icon(Icons.delete_forever, color: Colors.red),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  "Delete All Data",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              if (_isProcessing)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.red,
                  ),
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
        title: const Text("Delete All Data"),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        scrolledUnderElevation: 0.0,
        elevation: 0.0,
        titleSpacing: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [_buildWarningCard(), _buildDeleteCard()],
      ),
    );
  }
}
