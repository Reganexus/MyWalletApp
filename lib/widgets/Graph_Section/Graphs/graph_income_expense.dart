import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:mywallet/models/transaction.dart';
import 'package:mywallet/providers/account_provider.dart';
import 'package:mywallet/providers/profile_provider.dart';
import 'package:mywallet/services/forex_service.dart';
import 'package:mywallet/utils/Design/formatters.dart';
import 'package:provider/provider.dart';

class IncomeExpenseTrendGraph extends StatefulWidget {
  final List<TransactionModel> transactions;

  const IncomeExpenseTrendGraph({super.key, required this.transactions});

  @override
  State<IncomeExpenseTrendGraph> createState() =>
      _IncomeExpenseTrendGraphState();
}

class _IncomeExpenseTrendGraphState extends State<IncomeExpenseTrendGraph> {
  String? _selectedCurrency;
  Map<int, String> _accountCurrencyMap = {};
  List<FlSpot> _incomeSpots = [];
  List<FlSpot> _expenseSpots = [];
  List<DateTime> _dailyViewDates = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _updateTransactions();
  }

  @override
  void didUpdateWidget(covariant IncomeExpenseTrendGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.transactions != oldWidget.transactions) {
      _updateTransactions();
    }
  }

  Future<void> _updateTransactions() async {
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

    if (_selectedCurrency != null) {
      final allUniqueDates =
          widget.transactions
              .map((tx) => DateTime(tx.date.year, tx.date.month, tx.date.day))
              .toSet();

      // Check for 2 or more unique days to display the graph
      if (allUniqueDates.length >= 2) {
        final Map<DateTime, double> dailyIncomeTotals = {};
        final Map<DateTime, double> dailyExpenseTotals = {};

        for (final tx in widget.transactions) {
          final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
          final accountCurrency = _accountCurrencyMap[tx.accountId] ?? 'PHP';
          double amount = tx.amount;
          if (accountCurrency != _selectedCurrency) {
            final rate = await ForexService.getRate(
              accountCurrency,
              _selectedCurrency!,
            );
            if (rate != null) amount *= rate;
          }

          if (tx.type == 'income') {
            dailyIncomeTotals[date] = (dailyIncomeTotals[date] ?? 0) + amount;
          } else if (tx.type == 'expense') {
            dailyExpenseTotals[date] = (dailyExpenseTotals[date] ?? 0) + amount;
          }
        }

        _dailyViewDates =
            allUniqueDates.toList()..sort((a, b) => a.compareTo(b));
        if (_dailyViewDates.length > 10) {
          _dailyViewDates = _dailyViewDates.sublist(
            _dailyViewDates.length - 10,
          );
        }

        _incomeSpots = List.generate(_dailyViewDates.length, (i) {
          final date = _dailyViewDates[i];
          return FlSpot(i.toDouble(), dailyIncomeTotals[date] ?? 0);
        });

        _expenseSpots = List.generate(_dailyViewDates.length, (i) {
          final date = _dailyViewDates[i];
          return FlSpot(i.toDouble(), dailyExpenseTotals[date] ?? 0);
        });
      } else {
        // If less than 2 days, clear all graph data to not display anything
        _dailyViewDates = [];
        _incomeSpots = [];
        _expenseSpots = [];
      }
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<AccountProvider>().accounts;
    final profile = context.watch<ProfileProvider>().profile;
    final currencies = accounts.map((a) => a.currency).toSet().toList();
    final showDropdown = currencies.length > 1;
    final baseColor =
        profile?.colorPreference != null
            ? Color(int.parse(profile!.colorPreference!))
            : Colors.blue;

    // Check if there are at least two days of data to display the graph
    if (_dailyViewDates.length < 2) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Currency Dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Income vs Expense",
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
                    await _updateTransactions();
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
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: (_dailyViewDates.length - 1).toDouble(),
                    lineBarsData: [
                      LineChartBarData(
                        preventCurveOverShooting: true,
                        spots: _incomeSpots,
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 2,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.green.withAlpha(25),
                        ),
                      ),
                      LineChartBarData(
                        preventCurveOverShooting: true,
                        spots: _expenseSpots,
                        isCurved: true,
                        color: Colors.red,
                        barWidth: 2,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.red.withAlpha(25),
                        ),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < _dailyViewDates.length) {
                              final date = _dailyViewDates[index];
                              final formattedDate = DateFormat(
                                'MM/dd',
                              ).format(date);
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: SideTitleWidget(
                                  meta: meta,
                                  angle: -45,
                                  child: Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return Container();
                          },
                        ),
                      ),
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
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine:
                          (value) => FlLine(
                            color: Colors.grey.withAlpha(40),
                            strokeWidth: 1,
                          ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        tooltipPadding: const EdgeInsets.all(8),
                        tooltipBorderRadius: BorderRadius.circular(8),
                        getTooltipItems:
                            (spots) =>
                                spots.map((t) {
                                  final type =
                                      t.barIndex == 0 ? "Income" : "Expense";
                                  final value = formatNumber(
                                    t.y,
                                    currency: _selectedCurrency ?? 'PHP',
                                  );
                                  return LineTooltipItem(
                                    "$type\n$value",
                                    const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }).toList(),
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
            children: [
              _buildLegend("Income", Colors.green),
              _buildLegend("Expense", Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
