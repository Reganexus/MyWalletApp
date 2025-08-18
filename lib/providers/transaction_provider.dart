import 'package:flutter/foundation.dart';
import 'package:mywallet/models/transaction.dart';
import 'package:mywallet/providers/account_provider.dart';
import 'package:mywallet/services/db_service.dart';

class TransactionProvider with ChangeNotifier {
  final DBService db;
  late AccountProvider accountProvider; // not final, injected later

  TransactionProvider({required this.db});

  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => _transactions;

  Future<void> loadTransactions() async {
    _transactions = await db.getTransactions();
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel tx) async {
    await db.insertTransaction(tx);

    final account = accountProvider.accounts.firstWhere(
      (a) => a.id == tx.accountId,
      orElse: () => throw Exception("Account not found"),
    );

    double newBalance = account.balance;
    if (tx.type == "income") {
      newBalance += tx.amount;
    } else if (tx.type == "expense") {
      newBalance -= tx.amount;
    }

    final updatedAccount = account.copyWith(balance: newBalance);
    await accountProvider.updateAccount(updatedAccount);

    await loadTransactions();
  }

  Future<void> deleteTransaction(TransactionModel tx) async {
    final account = accountProvider.accounts.firstWhere(
      (a) => a.id == tx.accountId,
      orElse: () => throw Exception("Account not found"),
    );

    double newBalance = account.balance;
    if (tx.type == "income") {
      newBalance -= tx.amount; // undo income
    } else if (tx.type == "expense") {
      newBalance += tx.amount; // undo expense
    }

    final updatedAccount = account.copyWith(balance: newBalance);
    await accountProvider.updateAccount(updatedAccount);

    await db.deleteTransaction(tx.id!);
    await loadTransactions();
  }
}
