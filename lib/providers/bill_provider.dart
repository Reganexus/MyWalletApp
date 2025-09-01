// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:mywallet/models/bill.dart';
import 'package:mywallet/services/db_service.dart';

class BillProvider extends ChangeNotifier {
  final DBService db;
  BillProvider({required this.db});

  List<Bill> _bills = [];

  List<Bill> get bills => _bills;

  Future<void> loadBills() async {
    try {
      final bills = await db.getBills();
      _bills = bills;
    } catch (e) {
      print("❌ Failed to load bills: $e");
    }
    notifyListeners();
  }

  Future<void> addBill(Bill bill) async {
    await db.insertBill(bill);
    await loadBills();
  }

  Future<void> updateBill(Bill bill) async {
    await db.updateBill(bill);
    await loadBills();
  }

  Future<void> deleteBill(int id) async {
    // Also update this to take an int
    await db.deleteBill(id);
    await loadBills();
  }

  // Updated method to pay a bill
  Future<void> payBill(int billId) async {
    // Changed parameter type from String to int
    try {
      final billToUpdate = _bills.firstWhere((bill) => bill.id == billId);
      final updatedBill = billToUpdate.copyWith(
        status: BillStatus.paid,
        datePaid: DateTime.now(),
      );
      await db.updateBill(updatedBill);
      await loadBills();
    } catch (e) {
      print("❌ Failed to pay bill: $e");
      rethrow;
    }
  }
}
