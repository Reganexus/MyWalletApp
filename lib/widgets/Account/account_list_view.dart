import 'package:flutter/material.dart';
import 'package:mywallet/models/account.dart';
import 'package:mywallet/widgets/Account/account_card.dart';

class AccountListView extends StatelessWidget {
  final List<Account> accounts;
  final Map<String, double?> rates;
  final bool isGrid;

  const AccountListView({
    super.key,
    required this.accounts,
    required this.rates,
    this.isGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isGrid) {
      return GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children:
            accounts
                .map(
                  (account) => AccountCard(
                    account: account,
                    phpRate: rates[account.currency],
                    compact: true,
                  ),
                )
                .toList(),
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final account = accounts[index];
        return AccountCard(account: account, phpRate: rates[account.currency]);
      },
      separatorBuilder: (_, _) => const SizedBox(height: 16),
    );
  }
}
