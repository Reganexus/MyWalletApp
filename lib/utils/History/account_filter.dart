import 'package:flutter/material.dart';
import 'package:mywallet/models/account.dart';

class AccountFilterDropdown extends StatelessWidget {
  final List<Account> accounts;
  final Account? selectedAccount;
  final ValueChanged<Account?> onChanged;

  const AccountFilterDropdown({
    super.key,
    required this.accounts,
    required this.selectedAccount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (accounts.length <= 1) return const SizedBox();

    return DropdownButton<Account?>(
      style: TextStyle(
        fontSize: 14,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      value: selectedAccount,
      underline: const SizedBox(),
      hint: const Text("All Accounts"),
      items: [
        const DropdownMenuItem<Account?>(
          value: null,
          child: Text("All Accounts"),
        ),
        ...accounts.map(
          (a) => DropdownMenuItem<Account?>(value: a, child: Text(a.name)),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
