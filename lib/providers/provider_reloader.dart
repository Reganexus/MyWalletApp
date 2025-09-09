import 'package:flutter/material.dart';
import 'package:mywallet/providers/goal_provider.dart';
import 'package:provider/provider.dart';
import 'package:mywallet/providers/account_provider.dart';
import 'package:mywallet/providers/bill_provider.dart';
import 'package:mywallet/providers/transaction_provider.dart';

class ProviderReloader {
  static Future<void> reloadAll(BuildContext context) async {
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );
    final accountProvider = Provider.of<AccountProvider>(
      context,
      listen: false,
    );
    final billProvider = Provider.of<BillProvider>(context, listen: false);
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);

    await Future.wait([
      transactionProvider.loadTransactions(),
      accountProvider.loadAccounts(),
      billProvider.loadBills(),
      goalProvider.loadGoals(),
    ]);
  }
}
