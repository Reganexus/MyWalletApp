import 'package:flutter/material.dart';
import 'package:mywallet/utils/add_modal.dart';
import 'package:mywallet/widgets/Add_Transaction/add_transaction_button.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
  final formatter = DateFormat("yyyy-MM-dd");

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

  void _handlePayBill() {
    showDraggableModal(
      context: context,
      child: const AddTransactionForm(initialTabIndex: 1),
    );
  }

  bool isPaidThisMonth(Bill bill) {
    if (bill.status != BillStatus.paid || bill.datePaid == null) return false;
    final now = DateTime.now();
    return bill.datePaid!.year == now.year && bill.datePaid!.month == now.month;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BillProvider>(
      builder: (context, provider, _) {
        final bills = provider.bills;

        return Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Upcoming Bills",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _handlePayBill,
                      icon: const Icon(Icons.payment),
                      label: const Text("Pay Bill"),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
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
                  ...bills.map(
                    (bill) => SizedBox(
                      width: double.infinity,
                      child: _BillCard(
                        bill: bill,
                        formatter: formatter,
                        isPaidThisMonth: isPaidThisMonth(bill),
                      ),
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
          ),
        );
      },
    );
  }
}

class _BillCard extends StatelessWidget {
  final Bill bill;
  final bool isPaidThisMonth;
  final DateFormat formatter;

  const _BillCard({
    required this.bill,
    required this.isPaidThisMonth,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    String subtitle;
    String statusText;
    Color statusColor;

    if (isPaidThisMonth) {
      subtitle = "Paid on ${formatter.format(bill.datePaid!)}";
      statusText = "Good for this month";
      statusColor = Colors.green;
    } else {
      subtitle = "Every ${bill.dueDate.day}";
      statusText = "Pending";
      statusColor = Colors.orange;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      color: bill.color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
