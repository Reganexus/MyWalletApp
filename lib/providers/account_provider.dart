// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:mywallet/models/account.dart';
import 'package:mywallet/services/db_service.dart';
import 'package:mywallet/services/forex_service.dart';

class AccountProvider extends ChangeNotifier {
  final DBService db;
  AccountProvider({required this.db});

  List<Account> _accounts = [];
  final Map<String, double> _forexRates = {};

  List<Account> get accounts => _accounts;

  double? getPhpRate(String currency) => _forexRates[currency];

  Future<void> loadAccounts() async {
    try {
      final accounts = await db.getAccounts();
      final currencies =
          accounts.map((a) => a.currency).where((c) => c != "PHP").toSet();

      final rates = <String, double>{};
      for (var currency in currencies) {
        final rate = await ForexService.getRate(currency, "PHP");
        if (rate != null) rates[currency] = rate;
      }

      _accounts = accounts;
      _forexRates
        ..clear()
        ..addAll(rates);
    } catch (e) {
      print("❌ Failed to load accounts: $e");
    }

    notifyListeners();
  }

  Future<void> addAccount(Account account) async {
    await db.insertAccount(account);
    await loadAccounts();
  }

  Future<void> updateAccount(Account account) async {
    await db.updateAccount(account);
    await loadAccounts();
  }

  Future<void> deleteAccount(int id) async {
    await db.deleteAccount(id);
    await loadAccounts();
  }

  Future<void> deductFromAccount(int accountId, double amount) async {
    try {
      final account = _accounts.firstWhere((acc) => acc.id == accountId);

      if (account.balance < amount) {
        throw Exception("Insufficient funds in ${account.name}");
      }

      final updatedAccount = account.copyWith(
        balance: account.balance - amount,
      );

      await db.updateAccount(updatedAccount);
      await loadAccounts();
    } catch (e) {
      print("❌ Failed to deduct from account: $e");
      rethrow;
    }
  }

  List<String> get availableCurrencies {
    return accounts.map((acc) => acc.currency).toSet().toList();
  }
}
