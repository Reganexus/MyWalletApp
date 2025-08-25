import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mywallet/models/account.dart';
import 'package:mywallet/services/forex_service.dart';

class AccountDistributionGraph extends StatefulWidget {
  final List<Account> accounts;

  const AccountDistributionGraph({super.key, required this.accounts});

  @override
  State<AccountDistributionGraph> createState() =>
      _AccountDistributionGraphState();
}

class _AccountDistributionGraphState extends State<AccountDistributionGraph> {
  String? _selectedCurrency;
  Map<Account, double> _convertedBalances = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initConversion();
  }

  Future<void> _initConversion() async {
    final currencies = widget.accounts.map((a) => a.currency).toSet().toList();
    _selectedCurrency = currencies.first; // default to first currency
    await _convertBalances(_selectedCurrency!);
  }

  Future<void> _convertBalances(String targetCurrency) async {
    setState(() => _loading = true);

    Map<Account, double> newBalances = {};
    for (var account in widget.accounts) {
      double balance = account.balance;
      if (account.currency != targetCurrency) {
        final rate = await ForexService.getRate(
          account.currency,
          targetCurrency,
        );
        if (rate != null) balance *= rate;
      }
      newBalances[account] = balance;
    }

    setState(() {
      _convertedBalances = newBalances;
      _loading = false;
    });
  }

  String _formatNumber(double value) {
    if (value >= 1e6) return "${(value / 1e6).toStringAsFixed(1)}M";
    if (value >= 1e3) return "${(value / 1e3).toStringAsFixed(1)}K";
    return value.toStringAsFixed(0);
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + Dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Account Distribution",
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
                ? const Center(child: CircularProgressIndicator())
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
                                final balance = entry.value.value;

                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: balance,
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
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget:
                                (value, meta) => Text(
                                  _formatNumber(value),
                                  style: const TextStyle(fontSize: 12),
                                ),
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
                  _convertedBalances.entries.toList().asMap().entries.map((
                    entry,
                  ) {
                    final index = entry.key;
                    final account = entry.value.key;
                    final color = Colors
                        .primaries[index % Colors.primaries.length]
                        .withAlpha(204);

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 16, height: 16, color: color),
                        const SizedBox(width: 8),
                        Text(
                          account.name,
                          style: const TextStyle(fontSize: 14),
                        ),
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
