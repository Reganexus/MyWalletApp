import 'package:flutter/material.dart';
import 'package:mywallet/models/goal.dart';
import 'package:mywallet/utils/Design/formatters.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final bool compact;

  const GoalCard({super.key, required this.goal, this.compact = false});

  double get progress => (goal.savedAmount / goal.targetAmount).clamp(0, 1);

  bool get isCompleted => progress >= 1.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            goal.color.withValues(alpha: 0.8),
            goal.color.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: goal.color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: compact ? _buildCompact() : _buildList(),
    );
  }

  /// Compact layout (used for grids / smaller cards)
  Widget _buildCompact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Name + check icon
        Row(
          children: [
            Expanded(
              child: Text(
                goal.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isCompleted)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: goal.color.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 14, color: Colors.white),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // ✅ Balance (same as list mode to prevent overflow)
        Text(
          formatBalance(goal.currency, goal.savedAmount),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          "of ${formatBalance(goal.currency, goal.targetAmount)}",
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),

        const SizedBox(height: 16),

        // Progress bar
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          color: Colors.white,
          minHeight: 6,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  /// List layout (used in goal list view)
  Widget _buildList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Name + Completed badge
        Row(
          children: [
            Expanded(
              child: Text(
                goal.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: goal.color.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.check, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      "Completed",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // ✅ Balance
        Text(
          formatBalance(goal.currency, goal.savedAmount),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          "of ${formatBalance(goal.currency, goal.targetAmount)}",
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),

        const SizedBox(height: 12),

        // Progress bar
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          color: Colors.white,
          minHeight: 8,
          borderRadius: BorderRadius.circular(6),
        ),

        if (goal.deadline != null) ...[
          const SizedBox(height: 8),
          Text(
            "Deadline: ${formatFullDate(goal.deadline!)}",
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ],
    );
  }
}
