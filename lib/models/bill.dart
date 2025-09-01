// mywallet/models/bill.dart

import 'package:flutter/material.dart';
import 'package:mywallet/utils/Design/color_utils.dart';

enum BillStatus { paid, pending }

class Bill {
  final int? id; // Changed from String? to int?
  final String name;
  final double amount;
  final String currency;
  final DateTime dueDate;
  final BillStatus status;
  final DateTime? datePaid;
  final String colorHex;

  Bill({
    this.id,
    required this.name,
    required this.amount,
    this.currency = "PHP",
    required this.dueDate,
    this.status = BillStatus.pending,
    this.datePaid,
    this.colorHex = "#4285F4",
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id, // The database will handle this if it's null
      'name': name,
      'amount': amount,
      'currency': currency,
      'dueDate': dueDate.toIso8601String(),
      'status': status.name,
      'datePaid': datePaid?.toIso8601String(),
      'colorHex': colorHex,
    };
  }

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['id'] as int?, // Changed to read as an int?
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String? ?? "PHP",
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
    int? id,
    String? name,
    double? amount,
    String? currency,
    DateTime? dueDate,
    BillStatus? status,
    DateTime? datePaid,
    String? colorHex,
  }) {
    return Bill(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      datePaid: datePaid ?? this.datePaid,
      colorHex: colorHex ?? this.colorHex,
    );
  }
}
