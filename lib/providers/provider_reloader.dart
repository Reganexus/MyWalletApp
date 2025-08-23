import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mywallet/providers/account_provider.dart';
import 'package:mywallet/providers/bill_provider.dart';
import 'package:mywallet/providers/transaction_provider.dart';

class ProviderReloader {
  static Future<void> reloadAll(BuildContext context) async {
    // ✅ Capture providers before any await
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );
    final accountProvider = Provider.of<AccountProvider>(
      context,
      listen: false,
    );
    final billProvider = Provider.of<BillProvider>(context, listen: false);

    // ✅ Run async refreshes without touching context again
    await Future.wait([
      transactionProvider.loadTransactions(),
      accountProvider.loadAccounts(),
      billProvider.loadBills(),
    ]);
  }
}
