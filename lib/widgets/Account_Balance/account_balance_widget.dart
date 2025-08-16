import 'package:flutter/material.dart';
import 'package:mywallet/models/account.dart';
import 'package:mywallet/providers/account_provider.dart';
import 'package:mywallet/utils/formatters.dart';
import 'package:mywallet/widgets/Account_Balance/add_account_modal.dart';
import 'package:mywallet/widgets/Account_Balance/manage_account.dart';
import 'package:provider/provider.dart';

class AccountBalanceWidget extends StatefulWidget {
  const AccountBalanceWidget({super.key});

  @override
  State<AccountBalanceWidget> createState() => _AccountBalanceWidgetState();
}

class _AccountBalanceWidgetState extends State<AccountBalanceWidget> {
  void _handleAddAccount() {
    showAddAccountModal(context: context);
  }

  Future<void> _handleManageAccounts() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ManageAccountsScreen()),
    );

    if (!mounted) return;

    if (updated == true) {
      context.read<AccountProvider>().loadAccounts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(
      builder: (context, provider, _) {
        final accounts = provider.accounts;

        return Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (accounts.isEmpty) ...[
                const SizedBox(height: 50),
                const Text(
                  "No accounts yet",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextButton.icon(
                  onPressed: _handleAddAccount,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Account"),
                ),
              ] else ...[
                // Show accounts
                ...accounts.map(
                  (account) => _AccountCard(
                    account: account,
                    phpRate: provider.getPhpRate(account.currency),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: _handleAddAccount,
                      icon: const Icon(Icons.add),
                      label: const Text("Add Account"),
                    ),
                    const SizedBox(width: 16),
                    TextButton.icon(
                      onPressed: _handleManageAccounts,
                      icon: const Icon(Icons.settings),
                      label: const Text("Manage Accounts"),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AccountCard extends StatelessWidget {
  final Account account;
  final double? phpRate;

  const _AccountCard({required this.account, required this.phpRate});

  Widget _buildPhpBalance() {
    if (account.currency == "PHP") {
      return const SizedBox.shrink();
    }

    if (phpRate == null) {
      return const Text(
        "Fetching FX...",
        style: TextStyle(fontSize: 12, color: Colors.white54),
      );
    }

    return Text(
      formatBalance("PHP", account.balance * phpRate!),
      style: const TextStyle(fontSize: 12, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      color: account.color,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(
              categoryIcons[account.category],
              size: 40,
              color: Colors.black54,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  formatBalance(account.currency, account.balance),
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
                _buildPhpBalance(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
