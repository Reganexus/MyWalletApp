import 'package:flutter/material.dart';
import 'package:mywallet/utils/color_utils.dart';

enum BillStatus { paid, pending }

class Bill {
  final String? id;
  final String name;
  final double amount;
  final DateTime dueDate;
  final BillStatus status;
  final DateTime? datePaid;
  final String colorHex;

  Bill({
    this.id,
    required this.name,
    required this.amount,
    required this.dueDate,
    this.status = BillStatus.pending,
    this.datePaid,
    this.colorHex = "#4285F4",
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id!,
      'name': name,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'status': status.name,
      'datePaid': datePaid?.toIso8601String(),
      'colorHex': colorHex,
    };
  }

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['id'] as String?,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      dueDate: DateTime.parse(map['dueDate']),
      status: BillStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BillStatus.pending,
      ),
      datePaid:
          map['datePaid'] != null ? DateTime.parse(map['datePaid']) : null,
      colorHex: map['colorHex'] as String? ?? "#4285F4",
    );
  }

  Color get color => ColorUtils.fromHex(colorHex);

  Bill copyWith({
    String? id,
    String? name,
    double? amount,
    DateTime? dueDate,
    BillStatus? status,
    DateTime? datePaid,
    String? colorHex,
  }) {
    return Bill(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      datePaid: datePaid ?? this.datePaid,
      colorHex: colorHex ?? this.colorHex,
    );
  }
}
