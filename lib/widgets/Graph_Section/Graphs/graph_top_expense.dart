import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mywallet/models/transaction.dart';
import 'package:mywallet/services/db_service.dart';
import 'package:mywallet/services/forex_service.dart';
import 'package:mywallet/utils/formatters.dart';

class TopExpenseGraph extends StatefulWidget {
  final List<TransactionModel> transactions;

  const TopExpenseGraph({super.key, required this.transactions});

  @override
  State<TopExpenseGraph> createState() => _TopExpenseGraphState();
}

class _TopExpenseGraphState extends State<TopExpenseGraph> {
  String? _selectedCurrency;
  List<String> _currencies = [];
  Map<int, String> _accountCurrencyMap = {};
  Map<String, double> _convertedExpenses = {};
  bool _loading = true;

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
      await _convertExpenses(_selectedCurrency!);
    }

    setState(() => _loading = false);
  }

  Future<void> _convertExpenses(String targetCurrency) async {
    setState(() => _loading = true);

    Map<String, double> categoryTotals = {};
    for (var tx in widget.transactions) {
      if (tx.type != 'expense') continue;

      final accountCurrency = _accountCurrencyMap[tx.accountId] ?? 'PHP';
      double amount = tx.amount;

      if (accountCurrency != targetCurrency) {
        final rate = await ForexService.getRate(
          accountCurrency,
          targetCurrency,
        );
        if (rate != null) amount *= rate;
      }

      categoryTotals[tx.category] = (categoryTotals[tx.category] ?? 0) + amount;
    }

    setState(() {
      _convertedExpenses = categoryTotals;
      _loading = false;
    });
  }

  List<BarChartGroupData> get topExpenseBars {
    final sorted =
        _convertedExpenses.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.asMap().entries.map((entry) {
      final i = entry.key;
      final e = entry.value;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: e.value,
            color: Colors.primaries[i % Colors.primaries.length].withAlpha(244),
            width: 250 / _convertedExpenses.length,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  List<String> get topExpenseLabels {
    final sorted =
        _convertedExpenses.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => e.key).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bars = topExpenseBars;
    final labels = topExpenseLabels;

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
                  "Expense Categories",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                if (_currencies.length > 1)
                  DropdownButton<String>(
                    value: _selectedCurrency,
                    onChanged: (value) async {
                      if (value == null) return;
                      setState(() => _selectedCurrency = value);
                      await _convertExpenses(value);
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
                      barGroups: bars,
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                formatNumber(
                                  value,
                                  currency: _selectedCurrency ?? 'PHP',
                                ),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              );
                            },
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
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipPadding: const EdgeInsets.all(8),
                          tooltipMargin: 8,
                          tooltipBorderRadius: BorderRadius.circular(8),
                          getTooltipColor: (group) {
                            return group.barRods.first.color ?? Colors.black;
                          },
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final category = labels[group.x];
                            final value = formatNumber(
                              rod.toY,
                              currency: _selectedCurrency ?? 'PHP',
                            );
                            return BarTooltipItem(
                              "$category\n$value",
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
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
                  labels.asMap().entries.map((entry) {
                    final index = entry.key;
                    final label = entry.value;
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
                            label,
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
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
