import 'package:flutter/material.dart';
import 'package:mywallet/models/transaction.dart';
import 'package:mywallet/services/forex_service.dart';
import 'package:mywallet/services/db_service.dart';
import 'package:mywallet/utils/formatters.dart';

class WeeklySpendingHeatmap extends StatefulWidget {
  final List<TransactionModel> transactions;

  const WeeklySpendingHeatmap({super.key, required this.transactions});

  @override
  State<WeeklySpendingHeatmap> createState() => _WeeklySpendingHeatmapState();
}

class _WeeklySpendingHeatmapState extends State<WeeklySpendingHeatmap> {
  String? _selectedCurrency;
  List<String> _currencies = [];
  Map<int, String> _accountCurrencyMap = {};
  bool _loading = true;
  List<List<double>> _weeklySpending = List.generate(
    4,
    (_) => List.filled(7, 0.0),
  );

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final accounts = await DBService().getAccounts();
    _accountCurrencyMap = {for (var a in accounts) a.id!: a.currency};
    final dbCurrencies = await DBService().getCurrencies();

    if (dbCurrencies.isNotEmpty) {
      _selectedCurrency = dbCurrencies.first;
      _currencies = dbCurrencies;
      await _calculateWeeklySpending();
    }

    setState(() => _loading = false);
  }

  Future<void> _calculateWeeklySpending() async {
    setState(() => _loading = true);

    // Reset
    _weeklySpending = List.generate(4, (_) => List.filled(7, 0.0));

    for (var tx in widget.transactions) {
      if (tx.type != "expense") continue;

      final accountCurrency = _accountCurrencyMap[tx.accountId] ?? 'PHP';
      double amount = tx.amount;

      if (_selectedCurrency != null && accountCurrency != _selectedCurrency) {
        final rate = await ForexService.getRate(
          accountCurrency,
          _selectedCurrency!,
        );
        if (rate != null) amount *= rate;
      }

      int week = (tx.date.day - 1) ~/ 7;
      int day = tx.date.weekday - 1;
      if (week < 4 && day < 7) {
        _weeklySpending[week][day] += amount;
      }
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    double maxSpending = _weeklySpending
        .expand((w) => w)
        .fold(0.0, (prev, e) => e > prev ? e : prev);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + Dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Weekly Spending",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                if (_currencies.length > 1)
                  DropdownButton<String>(
                    value: _selectedCurrency,
                    onChanged: (value) async {
                      if (value == null) return;
                      setState(() => _selectedCurrency = value);
                      await _calculateWeeklySpending();
                    },
                    items:
                        _currencies
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Heatmap
            _loading
                ? const Center(child: CircularProgressIndicator())
                : LayoutBuilder(
                  builder: (context, constraints) {
                    double cellSize = (constraints.maxWidth - 6 * 4) / 7;

                    return Column(
                      children: [
                        // Day labels
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:
                              dayLabels.map((label) {
                                return SizedBox(
                                  width: cellSize,
                                  child: Center(
                                    child: Text(
                                      label,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 12),

                        // Heatmap grid
                        SizedBox(
                          height: cellSize * 4 + 12,
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 7,
                                  crossAxisSpacing: 4,
                                  mainAxisSpacing: 4,
                                  childAspectRatio: 1,
                                ),
                            itemCount: 28,
                            itemBuilder: (context, index) {
                              int week = index ~/ 7;
                              int day = index % 7;
                              double value = _weeklySpending[week][day];

                              int alpha =
                                  maxSpending == 0
                                      ? 0
                                      : ((value / maxSpending) * 200 + 55)
                                          .clamp(55, 255)
                                          .toInt();

                              return Container(
                                width: cellSize,
                                height: cellSize,
                                decoration: BoxDecoration(
                                  color: Colors.purple.withAlpha(alpha),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    formatNumber(
                                      value,
                                      currency: _selectedCurrency ?? 'PHP',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}
