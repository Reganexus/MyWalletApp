import 'package:flutter/material.dart';
import 'package:mywallet/providers/account_provider.dart';
import 'package:mywallet/utils/add_modal.dart';
import 'package:mywallet/utils/currency_filter.dart';
import 'package:mywallet/utils/layout_pref.dart';
import 'package:mywallet/widgets/Account_Balance/account_empty.dart';
import 'package:mywallet/widgets/Account_Balance/account_list_view.dart';
import 'package:mywallet/widgets/Account_Balance/add_account_modal.dart';
import 'package:mywallet/widgets/Account_Balance/manage_account.dart';
import 'package:mywallet/utils/add_manage.dart';
import 'package:provider/provider.dart';

class AccountBalanceWidget extends StatefulWidget {
  const AccountBalanceWidget({super.key});

  @override
  State<AccountBalanceWidget> createState() => _AccountBalanceWidgetState();
}

class _AccountBalanceWidgetState extends State<AccountBalanceWidget> {
  String? _selectedCurrency;
  bool _isGrid = false;
  late final _layoutPref = const LayoutPreference("account_balance_isGrid");

  @override
  void initState() {
    super.initState();
    _layoutPref.load().then((value) {
      if (mounted) setState(() => _isGrid = value);
    });
  }

  void _toggleLayout() {
    setState(() => _isGrid = !_isGrid);
    _layoutPref.save(_isGrid);
  }

  void _handleAddAccount() {
    showDraggableModal(
      context: context,
      child: const AddAccountForm(existingAccount: null),
    );
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

        if (accounts.isEmpty) {
          return EmptyAccountsState(onAdd: _handleAddAccount);
        }

        // Get unique currencies
        final currencies =
            accounts.map((a) => a.currency).toSet().toList()..sort();
        _selectedCurrency ??= currencies.length > 1 ? "All" : currencies.first;

        final filteredAccounts =
            _selectedCurrency == "All"
                ? accounts
                : accounts
                    .where((a) => a.currency == _selectedCurrency)
                    .toList();

        final rates = {
          for (var a in filteredAccounts)
            a.currency: provider.getPhpRate(a.currency),
        };

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Text(
                    "Accounts",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  CurrencyFilter(
                    currencies: currencies,
                    selectedCurrency: _selectedCurrency,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCurrency = val);
                    },
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _toggleLayout,
                    child: Icon(
                      _isGrid ? Icons.view_list : Icons.grid_view,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AccountActions(
                    onAdd: _handleAddAccount,
                    onManage: _handleManageAccounts,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AccountListView(
                accounts: filteredAccounts,
                rates: rates,
                isGrid: _isGrid,
              ),
            ],
          ),
        );
      },
    );
  }
}
