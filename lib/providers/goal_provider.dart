// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:mywallet/models/goal.dart';
import 'package:mywallet/services/db_service.dart';

class GoalProvider extends ChangeNotifier {
  final DBService db;
  GoalProvider({required this.db});

  List<Goal> _goals = [];

  List<Goal> get goals => _goals;

  /// Load all goals from DB
  Future<void> loadGoals() async {
    try {
      final data = await db.getGoals();
      _goals = data;
    } catch (e) {
      print("❌ Failed to load goals: $e");
    }
    notifyListeners();
  }

  /// Add new goal
  Future<void> addGoal(Goal goal) async {
    try {
      await db.insertGoal(goal);
      await loadGoals();
    } catch (e) {
      print("❌ Failed to add goal: $e");
    }
  }

  /// Update existing goal
  Future<void> updateGoal(Goal goal) async {
    try {
      await db.updateGoal(goal);
      await loadGoals();
    } catch (e) {
      print("❌ Failed to update goal: $e");
    }
  }

  /// Delete goal by ID
  Future<void> deleteGoal(int id) async {
    try {
      await db.deleteGoal(id);
      await loadGoals();
    } catch (e) {
      print("❌ Failed to delete goal: $e");
    }
  }

  Future<void> contributeToGoal(int goalId, double amount) async {
    try {
      final goal = _goals.firstWhere((g) => g.id == goalId);

      // Update goal progress
      final updatedGoal = goal.copyWith(
        savedAmount: goal.savedAmount + amount,
        updatedAt: DateTime.now(),
      );

      await db.updateGoal(updatedGoal);
      await loadGoals(); // will call notifyListeners()

      // Optionally, check if goal is completed
      if (updatedGoal.savedAmount >= updatedGoal.targetAmount) {
        final completedGoal = updatedGoal.copyWith(
          savedAmount: updatedGoal.targetAmount,
          updatedAt: DateTime.now(),
        );
        await db.updateGoal(completedGoal);
        await loadGoals();
      }
    } catch (e) {
      print("❌ Failed to contribute to goal: $e");
      rethrow;
    }
  }

  /// Quick access: total saved across all goals
  double get totalSaved => _goals.fold(0, (sum, g) => sum + g.savedAmount);

  /// Quick access: total target across all goals
  double get totalTarget => _goals.fold(0, (sum, g) => sum + g.targetAmount);
}
