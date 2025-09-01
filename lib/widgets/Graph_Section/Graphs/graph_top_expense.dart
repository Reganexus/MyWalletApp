import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mywallet/models/transaction.dart';
import 'package:mywallet/providers/account_provider.dart';
import 'package:mywallet/providers/profile_provider.dart';
import 'package:mywallet/services/forex_service.dart';
import 'package:mywallet/utils/Design/chart_legend.dart';
import 'package:mywallet/utils/Design/formatters.dart';
import 'package:provider/provider.dart';

class TopExpenseGraph extends StatefulWidget {
  final List<TransactionModel> transactions;

  const TopExpenseGraph({super.key, required this.transactions});

  @override
  State<TopExpenseGraph> createState() => _TopExpenseGraphState();
}

class _TopExpenseGraphState extends State<TopExpenseGraph> {
  String? _selectedCurrency;
  Map<int, String> _accountCurrencyMap = {};
  Map<String, double> _convertedExpenses = {};
  bool _loading = true;
  bool _hasExpenses = false;

  @override
  void initState() {
    super.initState();
    _prepareData();
  }

  Future<void> _prepareData() async {
    await _updateExpenses();
  }

  Future<void> _updateExpenses() async {
    setState(() => _loading = true);

    final accounts = context.read<AccountProvider>().accounts;
    _accountCurrencyMap = {for (var a in accounts) a.id!: a.currency};

    final currencies = _accountCurrencyMap.values.toSet().toList();

    if (currencies.isNotEmpty) {
      if (_selectedCurrency == null ||
          !currencies.contains(_selectedCurrency)) {
        _selectedCurrency = currencies.first;
      }
    } else {
      _selectedCurrency = null;
    }

    Map<String, double> categoryTotals = {};

    // Corrected logic to check for expense transactions
    _hasExpenses = widget.transactions.any((tx) => tx.type == 'expense');

    for (var tx in widget.transactions) {
      if (tx.type != 'expense' || _selectedCurrency == null) continue;

      final accountCurrency = _accountCurrencyMap[tx.accountId] ?? 'PHP';
      double amount = tx.amount;

      if (accountCurrency != _selectedCurrency) {
        final rate = await ForexService.getRate(
          accountCurrency,
          _selectedCurrency!,
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

  List<BarChartGroupData> get _bars {
    final sorted =
        _convertedExpenses.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final expenseLength = _convertedExpenses.length;

    return sorted.asMap().entries.map((entry) {
      final i = entry.key;
      final e = entry.value;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: e.value,
            color: Colors.primaries[i % Colors.primaries.length].withAlpha(199),
            width: expenseLength == 1 ? 150 : 250 / expenseLength,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  List<String> get _labels {
    final sorted =
        _convertedExpenses.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => e.key).toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final accounts = context.watch<AccountProvider>().accounts;
    final currencies = accounts.map((a) => a.currency).toSet().toList();

    bool needsUpdate = false;

    for (var a in accounts) {
      if (_accountCurrencyMap[a.id] != a.currency) {
        _accountCurrencyMap[a.id!] = a.currency;
        needsUpdate = true;
      }
    }

    if (currencies.isNotEmpty) {
      if (_selectedCurrency == null ||
          !currencies.contains(_selectedCurrency)) {
        _selectedCurrency = currencies.first;
        needsUpdate = true;
      }
    } else {
      if (_selectedCurrency != null) {
        _selectedCurrency = null;
        needsUpdate = true;
      }
    }

    if (needsUpdate) {
      _updateExpenses();
    }
  }

  @override
  void didUpdateWidget(covariant TopExpenseGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.transactions != oldWidget.transactions) {
      _updateExpenses();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<AccountProvider>().accounts;
    final currencies = accounts.map((a) => a.currency).toSet().toList();
    final showDropdown = currencies.length > 1;
    final profile = context.watch<ProfileProvider>().profile;
    final baseColor =
        profile?.colorPreference != null
            ? Color(int.parse(profile!.colorPreference!))
            : Colors.blue;

    if (accounts.isEmpty || !_hasExpenses) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Expense Categories",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              if (showDropdown)
                DropdownButton<String>(
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  value: _selectedCurrency,
                  onChanged: (value) async {
                    if (value == null) return;
                    setState(() => _selectedCurrency = value);
                    await _updateExpenses();
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
              ? Center(child: CircularProgressIndicator(color: baseColor))
              : SizedBox(
                height: 250,
                child: BarChart(
                  key: ValueKey(_selectedCurrency),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut,
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    barGroups: _bars,
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
                        getTooltipColor:
                            (group) =>
                                group.barRods.first.color ?? Colors.black,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final category = _labels[group.x];
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
          ChartLegend(labels: _labels),
        ],
      ),
    );
  }
}
