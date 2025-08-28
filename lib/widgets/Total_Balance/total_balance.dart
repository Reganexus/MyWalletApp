import 'package:flutter/material.dart';
import 'package:mywallet/providers/account_provider.dart';
import 'package:mywallet/providers/profile_provider.dart';
import 'package:mywallet/services/forex_service.dart';
import 'package:mywallet/utils/formatters.dart';
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
    final profile = context.watch<ProfileProvider>().profile;

    if (accounts.isEmpty) {
      return const Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text("No accounts available."),
        ),
      );
    }

    // User preferred color (fallback if not set)
    final baseColor =
        profile?.colorPreference != null
            ? Color(int.parse(profile!.colorPreference!))
            : Colors.blue;

    // Group balances by currency
    final Map<String, double> grouped = {};
    for (final account in accounts) {
      grouped[account.currency] =
          (grouped[account.currency] ?? 0) + account.balance;
    }

    // Default to first currency
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

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            baseColor.withValues(alpha: 0.9),
            baseColor.withValues(alpha: 0.7),
            baseColor.withValues(alpha: 0.5),
            baseColor.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasMultipleCurrencies)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Balance",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  DropdownButton<String>(
                    dropdownColor: Colors.black87,
                    style: const TextStyle(color: Colors.white),
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
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            const SizedBox(height: 12),
            FutureBuilder<double>(
              future: convertTotal(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text(
                    "Calculating...",
                    style: TextStyle(color: Colors.white70),
                  );
                }
                if (snapshot.hasError) {
                  return Text(
                    "Error calculating total: ${snapshot.error}",
                    style: const TextStyle(color: Colors.redAccent),
                  );
                }
                final total = snapshot.data ?? 0;
                return Text(
                  formatFullBalance(
                    total,
                    currency: _selectedCurrency ?? 'PHP',
                  ),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ...grouped.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  "${entry.key}: ${formatFullBalance(entry.value, currency: entry.key)}",
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
