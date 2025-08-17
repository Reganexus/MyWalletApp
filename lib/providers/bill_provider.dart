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

  Future<void> deleteBill(String id) async {
    await db.deleteBill(id);
    await loadBills();
  }
}
