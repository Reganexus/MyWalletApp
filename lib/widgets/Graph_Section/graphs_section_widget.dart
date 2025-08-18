import 'package:flutter/material.dart';

class GraphsSectionWidget extends StatelessWidget {
  const GraphsSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: Text("📊 Graph: Overall Balance Trend")),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: Text("Graph: Top 3 Expense Categories")),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: Text("Graph: Balance by Currencies")),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: Text("Graph: Income vs Expense")),
          ),
        ),
      ],
    );
  }
}
