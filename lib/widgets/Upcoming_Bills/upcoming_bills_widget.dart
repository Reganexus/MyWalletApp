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

        if (bills.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16), // like AccountBalanceWidget
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Text(
                    "Upcoming Bills",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _handlePayBill,
                    icon: const Icon(Icons.payment),
                    label: const Text("Pay Bill"),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Show bills
              ...bills.map(
                (bill) => _BillCard(
                  bill: bill,
                  formatter: formatter,
                  isPaidThisMonth: isPaidThisMonth(bill),
                ),
              ),

              const SizedBox(height: 16),

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

    if (isPaidThisMonth) {
      subtitle = "Paid on ${formatter.format(bill.datePaid!)}";
      statusText = "Paid for this month";
    } else {
      subtitle = "Every ${bill.dueDate.day}";
      statusText = "Pending";
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            bill.color.withValues(alpha: 0.9),
            bill.color.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: bill.color.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long,
                size: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),

            // Bill details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bill.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "₱${bill.amount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Status tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: bill.color.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                statusText,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // always white for contrast
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
