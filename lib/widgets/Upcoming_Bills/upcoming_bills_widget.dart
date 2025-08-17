import 'package:flutter/material.dart';
import 'package:mywallet/utils/add_modal.dart';
import 'package:provider/provider.dart';
import 'package:mywallet/models/bill.dart';
import 'package:mywallet/providers/bill_provider.dart';
import 'package:mywallet/widgets/Upcoming_Bills/add_bill_modal.dart';
import 'package:mywallet/widgets/Upcoming_Bills/manage_bills.dart';

class UpcomingBillsWidget extends StatefulWidget {
  const UpcomingBillsWidget({super.key});

  @override
  State<UpcomingBillsWidget> createState() => _UpcomingBillsWidgetState();
}

class _UpcomingBillsWidgetState extends State<UpcomingBillsWidget> {
  void _handleAddBill() {
    showDraggableModal(
      context: context,
      child: AddBillForm(existingBill: null),
    );
  }

  Future<void> _handleManageBills() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ManageBillsScreen()),
    );

    if (!mounted) return;

    if (updated == true) {
      context.read<BillProvider>().loadBills();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BillProvider>(
      builder: (context, provider, _) {
        final bills = provider.bills;

        return Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (bills.isEmpty) ...[
                const SizedBox(height: 50),
                const Text(
                  "No upcoming bills",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextButton.icon(
                  onPressed: _handleAddBill,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Bill"),
                ),
              ] else ...[
                // Show bills
                ...bills.map(
                  (bill) => SizedBox(
                    width: double.infinity,
                    child: _BillCard(bill: bill),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: _handleAddBill,
                      icon: const Icon(Icons.add),
                      label: const Text("Add Bill"),
                    ),
                    const SizedBox(width: 16),
                    TextButton.icon(
                      onPressed: _handleManageBills,
                      icon: const Icon(Icons.settings),
                      label: const Text("Manage Bills"),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _BillCard extends StatelessWidget {
  final Bill bill;

  const _BillCard({required this.bill});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      color: bill.color,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bill.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              "₱${bill.amount.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            Text(
              "Due: ${bill.dueDate.toString().split(" ")[0]}",
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
