import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mywallet/models/account.dart';
import 'package:mywallet/services/forex_service.dart';

class BalanceByCurrencyChart extends StatefulWidget {
  final List<Account> accounts;

  const BalanceByCurrencyChart({super.key, required this.accounts});

  @override
  State<BalanceByCurrencyChart> createState() => _BalanceByCurrencyChartState();
}

class _BalanceByCurrencyChartState extends State<BalanceByCurrencyChart> {
  String? _selectedCurrency;
  Map<String, double> _convertedBalances = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _initConversion();
  }

  Future<void> _initConversion() async {
    final currencies = widget.accounts.map((a) => a.currency).toSet().toList();
    _selectedCurrency = currencies.first;
    await _convertBalances(_selectedCurrency!);
  }

  Future<void> _convertBalances(String targetCurrency) async {
    setState(() => _loading = true);

    Map<String, double> newBalances = {};
    for (var account in widget.accounts) {
      double balance = account.balance;
      if (account.currency != targetCurrency) {
        final rate = await ForexService.getRate(
          account.currency,
          targetCurrency,
        );
        if (rate != null) balance *= rate;
      }
      newBalances[account.currency] =
          (newBalances[account.currency] ?? 0) + balance;
    }

    setState(() {
      _convertedBalances = newBalances;
      _loading = false;
    });
  }

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return "${(value / 1000000).toStringAsFixed(1)}M";
    } else if (value >= 1000) {
      return "${(value / 1000).toStringAsFixed(1)}K";
    } else {
      return value.toStringAsFixed(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencies = widget.accounts.map((a) => a.currency).toSet().toList();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Title + Dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Balance by Currency",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (currencies.length > 1)
                  DropdownButton<String>(
                    value: _selectedCurrency,
                    onChanged: (value) async {
                      if (value == null) return;
                      setState(() => _selectedCurrency = value);
                      await _convertBalances(value);
                    },
                    items:
                        currencies
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Chart or Loader
            _loading
                ? const CircularProgressIndicator()
                : SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barGroups:
                          _convertedBalances.entries
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) {
                                final index = entry.key;
                                // e.g. "USD"
                                final balanceInTarget =
                                    entry.value.value; // e.g. 11,000 PHP

                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: balanceInTarget,
                                      width: 40,
                                      borderRadius: BorderRadius.circular(6),
                                      color: Colors
                                          .primaries[index %
                                              Colors.primaries.length]
                                          .withAlpha(204),
                                    ),
                                  ],
                                );
                              })
                              .toList(),

                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false, // we’ll use legend instead
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                _formatNumber(value),
                                style: const TextStyle(fontSize: 12),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          left: BorderSide(color: Colors.grey.shade300),
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine:
                            (value) => FlLine(
                              color: Colors.grey.withAlpha(51),
                              strokeWidth: 1,
                            ),
                      ),
                    ),
                  ),
                ),

            // Legend
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children:
                  _convertedBalances.keys.toList().asMap().entries.map((entry) {
                    final index = entry.key;
                    final currency = entry.value;
                    final color = Colors
                        .primaries[index % Colors.primaries.length]
                        .withAlpha(204);

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 16, height: 16, color: color),
                        const SizedBox(width: 8),
                        Text(currency, style: const TextStyle(fontSize: 14)),
                      ],
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
