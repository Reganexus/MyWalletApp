import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mywallet/providers/account_provider.dart';
import 'package:mywallet/services/forex_service.dart';
import 'package:provider/provider.dart';

class TotalBalanceWidget extends StatefulWidget {
  const TotalBalanceWidget({super.key});

  @override
  State<TotalBalanceWidget> createState() => _TotalBalanceWidgetState();
}

class _TotalBalanceWidgetState extends State<TotalBalanceWidget> {
  String? _selectedCurrency;

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<AccountProvider>().accounts;
    final formatter = NumberFormat("#,##0.00", "en_US");

    if (accounts.isEmpty) {
      return const Card(
        margin: EdgeInsets.all(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text("No accounts available."),
        ),
      );
    }

    // Group balances by currency
    final Map<String, double> grouped = {};
    for (final account in accounts) {
      grouped[account.currency] =
          (grouped[account.currency] ?? 0) + account.balance;
    }

    // Set default base currency if none selected
    _selectedCurrency ??= grouped.keys.first;

    // Convert total to selected currency
    Future<double> convertTotal() async {
      double total = 0;
      for (var entry in grouped.entries) {
        if (entry.key == _selectedCurrency) {
          total += entry.value;
        } else {
          final rate = await ForexService.getRate(
            entry.key,
            _selectedCurrency!,
          );
          total += rate != null ? entry.value * rate : entry.value;
        }
      }
      return total;
    }

    final hasMultipleCurrencies = grouped.keys.length > 1;

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasMultipleCurrencies)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Balance",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: _selectedCurrency,
                    items:
                        grouped.keys
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                    onChanged: (val) => setState(() => _selectedCurrency = val),
                  ),
                ],
              )
            else
              const Text(
                "Total Balance",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 8),
            FutureBuilder<double>(
              future: convertTotal(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Calculating...");
                }
                if (snapshot.hasError) {
                  return Text(
                    "Error calculating total: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red),
                  );
                }
                final total = snapshot.data ?? 0;
                return Text(
                  "${formatter.format(total)} $_selectedCurrency",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            const Text(
              "Breakdown",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            ...grouped.entries.map(
              (entry) => Text(
                "${entry.key} Accounts: ${formatter.format(entry.value)} ${entry.key}",
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
