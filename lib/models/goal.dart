import 'package:flutter/material.dart';
import 'package:mywallet/utils/Design/color_utils.dart';

enum GoalStatus { active, completed }

class Goal {
  final int? id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final String currency;
  final DateTime? deadline;
  final String? customDeadline;
  final String colorHex;
  final DateTime dateCreated;
  final DateTime updatedAt;
  final GoalStatus status;

  Goal({
    this.id,
    required this.name,
    required this.targetAmount,
    this.savedAmount = 0,
    required this.currency,
    this.deadline,
    this.customDeadline,
    this.colorHex = "#4285F4",
    required this.dateCreated,
    required this.updatedAt,
    this.status = GoalStatus.active,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id!,
      'name': name,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'currency': currency,
      'deadline': deadline?.toIso8601String(),
      'customDeadline': customDeadline,
      'colorHex': colorHex,
      'dateCreated': dateCreated.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'status': status.name,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] as int?,
      name: map['name'] as String,
      targetAmount: (map['targetAmount'] as num).toDouble(),
      savedAmount: (map['savedAmount'] as num).toDouble(),
      currency: map['currency'] as String,
      deadline:
          map['deadline'] != null ? DateTime.tryParse(map['deadline']) : null,
      customDeadline: map['customDeadline'] as String?,
      colorHex: map['colorHex'] as String? ?? "#4285F4",
      dateCreated: DateTime.parse(map['dateCreated']),
      updatedAt: DateTime.parse(map['updatedAt']),
      status: GoalStatus.values.firstWhere(
        (s) => s.name == (map['status'] ?? 'active'),
        orElse: () => GoalStatus.active,
      ),
    );
  }

  Color get color => ColorUtils.fromHex(colorHex);

  double get progress => targetAmount == 0 ? 0 : savedAmount / targetAmount;

  Goal copyWith({
    int? id,
    String? name,
    double? targetAmount,
    double? savedAmount,
    String? currency,
    DateTime? deadline,
    String? customDeadline,
    String? colorHex,
    DateTime? dateCreated,
    DateTime? updatedAt,
    GoalStatus? status,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      currency: currency ?? this.currency,
      deadline: deadline ?? this.deadline,
      customDeadline: customDeadline ?? this.customDeadline,
      colorHex: colorHex ?? this.colorHex,
      dateCreated: dateCreated ?? this.dateCreated,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }
}
