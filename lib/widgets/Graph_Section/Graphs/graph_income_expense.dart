import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mywallet/models/transaction.dart';
import 'package:mywallet/services/db_service.dart';
import 'package:mywallet/services/forex_service.dart';
import 'package:mywallet/utils/formatters.dart';

class IncomeExpenseTrendGraph extends StatefulWidget {
  final List<TransactionModel> transactions;

  const IncomeExpenseTrendGraph({super.key, required this.transactions});

  @override
  State<IncomeExpenseTrendGraph> createState() =>
      _IncomeExpenseTrendGraphState();
}

class _IncomeExpenseTrendGraphState extends State<IncomeExpenseTrendGraph> {
  String? _selectedCurrency;
  List<String> _currencies = [];
  Map<int, String> _accountCurrencyMap = {};
  Map<int, double> _incomeByWeek = {};
  Map<int, double> _expenseByWeek = {};
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
      await _convertTransactions(_selectedCurrency!);
    }

    setState(() => _loading = false);
  }

  Future<void> _convertTransactions(String targetCurrency) async {
    setState(() => _loading = true);

    Map<int, double> incomeTotals = {};
    Map<int, double> expenseTotals = {};

    for (var tx in widget.transactions) {
      final week = ((tx.date.day - 1) ~/ 7) + 1;
      final accountCurrency = _accountCurrencyMap[tx.accountId] ?? 'PHP';
      double amount = tx.amount;

      if (accountCurrency != targetCurrency) {
        final rate = await ForexService.getRate(
          accountCurrency,
          targetCurrency,
        );
        if (rate != null) amount *= rate;
      }

      if (tx.type == 'income') {
        incomeTotals[week] = (incomeTotals[week] ?? 0) + amount;
      } else if (tx.type == 'expense') {
        expenseTotals[week] = (expenseTotals[week] ?? 0) + amount;
      }
    }

    setState(() {
      _incomeByWeek = incomeTotals;
      _expenseByWeek = expenseTotals;
      _loading = false;
    });
  }

  List<FlSpot> getIncomeSpots() {
    final weeks =
        {..._incomeByWeek.keys, ..._expenseByWeek.keys}.toList()..sort();
    return weeks
        .map((w) => FlSpot(w.toDouble(), _incomeByWeek[w] ?? 0))
        .toList();
  }

  List<FlSpot> getExpenseSpots() {
    final weeks =
        {..._incomeByWeek.keys, ..._expenseByWeek.keys}.toList()..sort();
    return weeks
        .map((w) => FlSpot(w.toDouble(), _expenseByWeek[w] ?? 0))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final incomeSpots = getIncomeSpots();
    final expenseSpots = getExpenseSpots();

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
                  "Income vs Expense",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                if (_currencies.length > 1)
                  DropdownButton<String>(
                    value: _selectedCurrency,
                    onChanged: (value) async {
                      if (value == null) return;
                      setState(() => _selectedCurrency = value);
                      await _convertTransactions(value);
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
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: incomeSpots,
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
                          spots: expenseSpots,
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
                            reservedSize: 30,
                            interval: 1,
                            getTitlesWidget:
                                (value, meta) => Text(
                                  'W${value.toInt()}',
                                  style: const TextStyle(fontSize: 12),
                                ),
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
                          getTooltipItems: (spots) {
                            return spots.map((t) {
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
                            }).toList();
                          },
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
