import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mywallet/models/account.dart';
import 'package:mywallet/services/forex_service.dart';
import 'package:mywallet/utils/formatters.dart';

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
    if (currencies.isNotEmpty) {
      _selectedCurrency = currencies.first;
      await _convertBalances(_selectedCurrency!);
    }
    setState(() => _loading = false);
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

  List<BarChartGroupData> get bars {
    final sorted =
        _convertedBalances.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.asMap().entries.map((entry) {
      final index = entry.key;
      final accountBalance = entry.value.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: accountBalance,
            width: 250 / _convertedBalances.length,
            borderRadius: BorderRadius.circular(6),
            color: Colors.primaries[index % Colors.primaries.length].withAlpha(
              204,
            ),
          ),
        ],
      );
    }).toList();
  }

  List<Account> get accountsSorted {
    final sorted =
        _convertedBalances.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => e.key).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currencies = widget.accounts.map((a) => a.currency).toSet().toList();
    final chartBars = bars;
    final chartAccounts = accountsSorted;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + Currency Dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Account Distribution",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
            const SizedBox(height: 24),

            // Chart
            _loading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                  height: 250,
                  child: BarChart(
                    key: ValueKey(_selectedCurrency),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOut,
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barGroups: chartBars,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipPadding: const EdgeInsets.all(8),
                          tooltipMargin: 8,
                          tooltipBorderRadius: BorderRadius.circular(8),
                          getTooltipColor:
                              (group) =>
                                  group.barRods.first.color ?? Colors.black,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final account = chartAccounts[group.x];
                            final value = formatNumber(
                              rod.toY,
                              currency: _selectedCurrency ?? 'PHP',
                            );
                            return BarTooltipItem(
                              "${account.name}\n$value",
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget:
                                (value, meta) => Text(
                                  formatNumber(
                                    value,
                                    currency: _selectedCurrency ?? 'PHP',
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine:
                            (value) => FlLine(
                              color: Colors.grey.withAlpha(40),
                              strokeWidth: 1,
                            ),
                      ),
                    ),
                  ),
                ),

            const SizedBox(height: 24),
            // Legend
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  chartAccounts.asMap().entries.map((entry) {
                    final index = entry.key;
                    final account = entry.value;
                    final color = Colors
                        .primaries[index % Colors.primaries.length]
                        .withAlpha(204);

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withAlpha(50),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            account.name,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
