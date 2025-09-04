// lib/app_providers.dart
import 'package:flutter/material.dart';
import 'package:mywallet/services/db_service.dart';
import 'package:provider/provider.dart';
import 'package:mywallet/providers/account_provider.dart';
import 'package:mywallet/providers/bill_provider.dart';
import 'package:mywallet/providers/goal_provider.dart';
import 'package:mywallet/providers/profile_provider.dart';
import 'package:mywallet/providers/theme_provider.dart';
import 'package:mywallet/providers/transaction_provider.dart';

MultiProvider buildAppProviders(Widget child, DBService dbService) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        lazy: false,
        create: (_) => AccountProvider(db: dbService)..loadAccounts(),
      ),
      ChangeNotifierProvider(
        lazy: false,
        create: (_) => BillProvider(db: dbService)..loadBills(),
      ),
      ChangeNotifierProxyProvider<AccountProvider, TransactionProvider>(
        lazy: false,
        create: (_) => TransactionProvider(db: dbService)..loadTransactions(),
        update: (_, accountProvider, txProvider) {
          txProvider!.accountProvider = accountProvider;
          return txProvider;
        },
      ),
      ChangeNotifierProvider(
        lazy: false,
        create: (_) => ProfileProvider(db: dbService)..loadProfile(),
      ),
      ChangeNotifierProvider(
        lazy: false,
        create: (_) => GoalProvider(db: dbService)..loadGoals(),
      ),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ],
    child: child,
  );
}
