import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mywallet/models/transaction.dart';

class IncomeExpenseTrendGraph extends StatelessWidget {
  final List<TransactionModel> transactions;

  const IncomeExpenseTrendGraph({super.key, required this.transactions});

  String _formatNumber(double value) {
    if (value >= 1e6) {
      return "${(value / 1e6).toStringAsFixed(1)}M";
    } else if (value >= 1e3) {
      return "${(value / 1e3).toStringAsFixed(1)}K";
    }
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final Map<int, double> incomeByWeek = {};
    final Map<int, double> expenseByWeek = {};

    for (var tx in transactions) {
      // Group by week number of year
      final week = ((tx.date.day - 1) ~/ 7) + 1;
      if (tx.type == 'income') {
        incomeByWeek[week] = (incomeByWeek[week] ?? 0) + tx.amount;
      } else if (tx.type == 'expense') {
        expenseByWeek[week] = (expenseByWeek[week] ?? 0) + tx.amount;
      }
    }

    final sortedWeeks =
        {...incomeByWeek.keys, ...expenseByWeek.keys}.toList()..sort();

    final incomeData =
        sortedWeeks
            .map((w) => FlSpot(w.toDouble(), incomeByWeek[w] ?? 0))
            .toList();

    final expenseData =
        sortedWeeks
            .map((w) => FlSpot(w.toDouble(), expenseByWeek[w] ?? 0))
            .toList();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Weekly Income vs Expense Trend",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: incomeData,
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
                      spots: expenseData,
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
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            'W${value.toInt()}',
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
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
                  borderData: FlBorderData(show: false),
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
          ],
        ),
      ),
    );
  }
}
