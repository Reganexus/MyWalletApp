// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:mywallet/models/goal.dart';
import 'package:mywallet/services/db_service.dart';

class GoalProvider extends ChangeNotifier {
  final DBService db;
  GoalProvider({required this.db});

  List<Goal> _goals = [];
  List<Goal> get goals => _goals;

  /// Load all goals from database
  Future<void> loadGoals() async {
    try {
      final goals = await db.getGoals();
      _goals = goals;
      notifyListeners();
    } catch (e) {
      print("❌ Failed to load goals: $e");
    }
  }

  /// Add a new goal
  Future<void> addGoal(Goal goal) async {
    try {
      final inserted = await db.insertGoal(goal);
      _goals.add(inserted); // ✅ add directly
      notifyListeners();
    } catch (e) {
      print("❌ Failed to add goal: $e");
      rethrow;
    }
  }

  /// Update an existing goal
  Future<void> updateGoal(Goal goal) async {
    try {
      await db.updateGoal(goal);
      final index = _goals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        _goals[index] = goal;
      }
      notifyListeners();
    } catch (e) {
      print("❌ Failed to update goal: $e");
      rethrow;
    }
  }

  /// Delete a goal
  Future<void> deleteGoal(int id) async {
    try {
      await db.deleteGoal(id);
      _goals.removeWhere((g) => g.id == id); // ✅ update memory
      notifyListeners();
    } catch (e) {
      print("❌ Failed to delete goal: $e");
      rethrow;
    }
  }

  /// Contribute to a goal
  Future<void> contributeToGoal(int goalId, double amount) async {
    try {
      final index = _goals.indexWhere((g) => g.id == goalId);
      if (index == -1) throw Exception("Goal not found");

      final goal = _goals[index];
      final newSaved = goal.savedAmount + amount;
      final isCompleted = newSaved >= goal.targetAmount;

      final updatedGoal = goal.copyWith(
        savedAmount: newSaved.clamp(0, goal.targetAmount),
        status: isCompleted ? GoalStatus.completed : GoalStatus.active,
        updatedAt: DateTime.now(),
      );

      await db.updateGoal(updatedGoal);
      _goals[index] = updatedGoal; // ✅ update memory
      notifyListeners();
    } catch (e) {
      print("❌ Failed to contribute to goal: $e");
      rethrow;
    }
  }

  /// Get goal by ID
  Goal? getGoalById(int goalId) {
    try {
      return _goals.firstWhere((g) => g.id == goalId);
    } catch (_) {
      return null;
    }
  }
}
