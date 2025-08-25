import 'package:flutter/material.dart';
import 'package:mywallet/models/transaction.dart';

class WeeklySpendingHeatmap extends StatelessWidget {
  final List<TransactionModel> transactions;

  const WeeklySpendingHeatmap({super.key, required this.transactions});

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
    // Prepare spending data for 4 weeks (7 days each)
    List<List<double>> weeklySpending = List.generate(
      4,
      (_) => List.filled(7, 0.0),
    );

    // Fill the matrix
    for (var tx in transactions) {
      if (tx.type == "expense") {
        int week = (tx.date.day - 1) ~/ 7;
        int day = tx.date.weekday - 1;

        if (week < weeklySpending.length && day < 7) {
          weeklySpending[week][day] += tx.amount;
        }
      }
    }

    // Find the max spending to normalize alpha
    double maxSpending = weeklySpending
        .expand((week) => week)
        .fold(0.0, (prev, amount) => amount > prev ? amount : prev);

    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Weekly Spending Heatmap",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                double cellSize = (constraints.maxWidth - 6 * 4) / 7;

                return Column(
                  children: [
                    // Day labels row
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
                    const SizedBox(height: 8),

                    // Heatmap grid
                    SizedBox(
                      height: cellSize * 4 + 12,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                          childAspectRatio: 1,
                        ),
                        itemCount: 28, // 4 weeks * 7 days
                        itemBuilder: (context, index) {
                          int week = index ~/ 7;
                          int day = index % 7;
                          double value = weeklySpending[week][day];

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
                              color: Colors.red.withAlpha(alpha),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                _formatNumber(value),
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
