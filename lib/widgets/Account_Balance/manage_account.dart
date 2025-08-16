import 'package:flutter/material.dart';
import 'package:mywallet/models/account.dart';
import 'package:mywallet/providers/account_provider.dart';
import 'package:mywallet/widgets/Account_Balance/add_account_modal.dart';
import 'package:mywallet/widgets/confirmation_dialog.dart';
import 'package:provider/provider.dart';

class ManageAccountsScreen extends StatefulWidget {
  const ManageAccountsScreen({super.key});

  @override
  State<ManageAccountsScreen> createState() => _ManageAccountsScreenState();
}

class _ManageAccountsScreenState extends State<ManageAccountsScreen> {
  Future<void> _editAccount(Account account) async {
    // Open bottom sheet directly, confirmation is inside AddAccountForm
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 1.0,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                    left: 16,
                    right: 16,
                    top: 20,
                  ),
                  child: AddAccountForm(existingAccount: account),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteAccount(Account account) async {
    final confirm = await showConfirmationDialog(
      context: context,
      title: "Delete Account",
      content: "Are you sure you want to delete ${account.name}?",
    );

    if (!mounted || confirm != true) return;

    context.read<AccountProvider>().deleteAccount(account.id!);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccountProvider>();
    final accounts = provider.accounts;

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Accounts")),
      body:
          accounts.isEmpty
              ? const Center(child: Text("No accounts found"))
              : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  return Card(
                    color: account.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: Icon(
                        categoryIcons[account.category],
                        color: Colors.black54,
                        size: 32,
                      ),
                      title: Text(
                        account.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        "${account.currency} ${account.balance.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () => _editAccount(account),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteAccount(account),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
