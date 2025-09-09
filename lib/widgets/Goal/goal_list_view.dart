import 'package:flutter/material.dart';
import 'package:mywallet/models/goal.dart';
import 'package:mywallet/widgets/Goal/goal_card.dart';

class GoalListView extends StatelessWidget {
  final List<Goal> goals;
  final bool isGrid;

  const GoalListView({super.key, required this.goals, this.isGrid = false});

  @override
  Widget build(BuildContext context) {
    if (isGrid) {
      return GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children:
            goals.map((goal) => GoalCard(goal: goal, compact: true)).toList(),
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return GoalCard(goal: goal);
      },
      separatorBuilder: (_, _) => const SizedBox(height: 16),
    );
  }
}
