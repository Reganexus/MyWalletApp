import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mywallet/models/transaction.dart';

class TopExpenseGraph extends StatelessWidget {
  final List<TransactionModel> transactions;

  const TopExpenseGraph({super.key, required this.transactions});

  List<BarChartGroupData> get topExpenseBars {
    Map<String, double> categorySums = {};
    for (var tx in transactions) {
      if (tx.type == 'expense') {
        categorySums[tx.category] =
            (categorySums[tx.category] ?? 0) + tx.amount;
      }
    }
    final sorted =
        categorySums.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sorted.take(5).toList();

    return top5.asMap().entries.map((entry) {
      final i = entry.key;
      final e = entry.value;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: e.value,
            color: Colors.primaries[i % Colors.primaries.length].withAlpha(204),
            width: 40,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  List<String> get topExpenseLabels {
    Map<String, double> categorySums = {};
    for (var tx in transactions) {
      if (tx.type == 'expense') {
        categorySums[tx.category] =
            (categorySums[tx.category] ?? 0) + tx.amount;
      }
    }
    final sorted =
        categorySums.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).map((e) => e.key).toList();
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
    final bars = topExpenseBars;
    final labels = topExpenseLabels;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Top 5 Expense Categories",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: bars,
                  titlesData: FlTitlesData(
                    show: true,
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
            const SizedBox(height: 16),
            // Legend
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children:
                  labels.asMap().entries.map((entry) {
                    final index = entry.key;
                    final label = entry.value;
                    final color = Colors
                        .primaries[index % Colors.primaries.length]
                        .withAlpha(204);
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 16, height: 16, color: color),
                        const SizedBox(width: 8),
                        Text(label, style: const TextStyle(fontSize: 14)),
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
