// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:mywallet/models/bill.dart';
import 'package:mywallet/services/db_service.dart';
import 'package:mywallet/services/bill_scheduler.dart';

class BillProvider extends ChangeNotifier {
  final DBService db;
  BillProvider({required this.db});

  List<Bill> _bills = [];

  List<Bill> get bills => _bills;

  Future<void> loadBills() async {
    try {
      _bills = await db.getBills();
    } catch (e) {
      print("❌ Failed to load bills: $e");
    }
    notifyListeners();
  }

  Future<void> addBill(Bill bill) async {
    await db.insertBill(bill);
    await loadBills();
    await BillScheduler.handleBillScheduling(bill, action: 'add');
  }

  Future<void> updateBill(Bill bill) async {
    await db.updateBill(bill);
    await loadBills();
    await BillScheduler.handleBillScheduling(bill, action: 'update');
  }

  Future<void> deleteBill(int id) async {
    try {
      final billToDelete = _bills.firstWhere((bill) => bill.id == id);
      await BillScheduler.cancelBillNotifications(billToDelete);
      await db.deleteBill(id);
      await loadBills();
    } catch (e) {
      print("❌ Failed to delete bill: $e");
      rethrow;
    }
  }

  Future<void> payBill(int billId) async {
    try {
      final bill = _bills.firstWhere((b) => b.id == billId);
      await BillScheduler.cancelBillNotifications(bill);

      final updatedBill = bill.copyWith(
        status: BillStatus.paid, // mark as paid
        datePaid: DateTime.now(), // mark payment date
      );

      // Update DB with paid status
      await db.updateBill(updatedBill);
      await loadBills(); // notifyListeners() called inside loadBills()

      // Schedule next due date notifications
      final nextDueDate = DateTime(
        bill.dueDate.year,
        bill.dueDate.month + 1,
        bill.dueDate.day,
      );

      final nextBillCycle = updatedBill.copyWith(
        status: BillStatus.pending,
        dueDate: nextDueDate,
        datePaid: null, // reset for next cycle
      );

      await BillScheduler.handleBillScheduling(nextBillCycle, action: 'pay');
    } catch (e) {
      print("❌ Failed to pay bill: $e");
      rethrow;
    }
  }
}
