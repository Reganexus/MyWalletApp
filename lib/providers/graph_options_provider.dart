import 'package:flutter/material.dart';

class GraphOptionsProvider extends ChangeNotifier {
  final Map<String, bool> _graphVisibility = {
    'weeklySpending': true,
    'topExpense': true,
    'balanceByCurrency': true,
    'incomeExpense': true,
    'accountDistribution': true,
  };

  bool isGraphVisible(String key) => _graphVisibility[key] ?? false;

  void toggleGraph(String key) {
    _graphVisibility[key] = !(_graphVisibility[key] ?? false);
    notifyListeners();
  }

  Map<String, bool> get graphVisibility => Map.unmodifiable(_graphVisibility);
}
