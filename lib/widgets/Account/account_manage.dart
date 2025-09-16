import 'package:flutter/material.dart';
import 'package:mywallet/models/account.dart';
import 'package:mywallet/providers/account_provider.dart';
import 'package:mywallet/providers/provider_reloader.dart';
import 'package:mywallet/utils/Design/overlay_message.dart';
import 'package:mywallet/utils/WidgetHelper/add_modal.dart';
import 'package:mywallet/utils/WidgetHelper/confirmation_dialog.dart';
import 'package:mywallet/widgets/Account/account_form.dart';
import 'package:provider/provider.dart';

class ManageAccountsScreen extends StatefulWidget {
  const ManageAccountsScreen({super.key});

  @override
  State<ManageAccountsScreen> createState() => _ManageAccountsScreenState();
}

class _ManageAccountsScreenState extends State<ManageAccountsScreen> {
  Future<void> _editAccount(Account account) async {
    await showDraggableModal(
      context: context,
      child: AccountForm(existingAccount: account),
    );

    if (!mounted) return;
    await ProviderReloader.reloadAll(context);
  }

  Future<void> _deleteAccount(Account account) async {
    final confirm = await showConfirmationDialog(
      context: context,
      title: "Delete Account",
      content: "Are you sure you want to delete ${account.name}?",
      confirmText: "Delete",
      confirmColor: Colors.red,
    );

    if (!mounted || confirm != true) return;

    try {
      // Delete the account
      await context.read<AccountProvider>().deleteAccount(account.id!);

      if (!mounted) return;
      await ProviderReloader.reloadAll(context);

      if (!mounted) return;
      OverlayMessage.show(
        context,
        message: "${account.name} deleted successfully!",
      );
    } catch (e) {
      if (!mounted) return;

      OverlayMessage.show(
        context,
        message: "${account.name} failed to delete: $e",
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccountProvider>();
    final accounts = provider.accounts;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Accounts"),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        scrolledUnderElevation: 0.0,
        elevation: 0.0,
        titleSpacing: 0,
      ),
      body:
          accounts.isEmpty
              ? const Center(child: Text("No accounts found"))
              : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: account.color.withValues(alpha: 0.2),
                        child: Icon(
                          categoryIcons[account.category],
                          color: account.color,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        account.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        "${account.currency} ${account.balance.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      trailing: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (_) {
                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      title: const Text("Edit"),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _editAccount(account);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      title: const Text("Delete"),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _deleteAccount(account);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: const Icon(Icons.more_vert),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
